import type { SupabaseClient, User } from '@supabase/supabase-js';
import QRCode from 'qrcode';
import { acceptInvite, createInvite, currentCouple, decryptMessage, inviteUrlFromSecret, listMessages, loadPairSecret, removeLocalPairSecret, sendMedia, sendText, subscribeForPush, type ChatMessage, type Couple } from './chat';
import { backendConfigured, supabase, webPushPublicKey } from './backend';
import { asArrayBuffer } from './crypto';
import { importFile, permanentlyDelete } from './vault';

type Notice = (message: string) => void;

let activeChannel: ReturnType<SupabaseClient['channel']> | undefined;
let activeCoupleId: string | undefined;
let refreshTimer: number | undefined;
let expiryTimer: number | undefined;
let visibilityHandler: (() => void) | undefined;
let conversationRenderGeneration = 0;
let activeUrls = new Map<string, string>();
let activeMessageExpiries = new Map<string, number>();
let activeRecorder: { recorder: MediaRecorder; stream: MediaStream; chunks: Blob[]; discard: boolean } | undefined;

function clearActiveMediaUrls(): void {
  for (const url of activeUrls.values()) URL.revokeObjectURL(url);
  activeUrls.clear();
}

function discardMessageContent(messageId: string): void {
  activeMessageExpiries.delete(messageId);
  const url = activeUrls.get(messageId);
  if (url) { URL.revokeObjectURL(url); activeUrls.delete(messageId); }
}

function removeExpiredVisibleMessages(panel: HTMLElement): void {
  const now = Date.now();
  for (const [messageId, expiresAt] of activeMessageExpiries) {
    if (expiresAt > now) continue;
    discardMessageContent(messageId);
    panel.querySelector<HTMLElement>(`[data-message-id="${CSS.escape(messageId)}"]`)?.remove();
  }
}

function escape(value: string): string {
  return value.replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]!);
}

export function stopChatPage(): void {
  conversationRenderGeneration++;
  if (refreshTimer !== undefined) window.clearInterval(refreshTimer);
  refreshTimer = undefined;
  if (expiryTimer !== undefined) window.clearTimeout(expiryTimer);
  expiryTimer = undefined;
  if (visibilityHandler) document.removeEventListener('visibilitychange', visibilityHandler);
  visibilityHandler = undefined;
  if (activeChannel && supabase) void supabase.removeChannel(activeChannel);
  activeChannel = undefined;
  activeCoupleId = undefined;
  if (activeRecorder) { activeRecorder.discard = true; activeRecorder.recorder.stop(); activeRecorder.stream.getTracks().forEach((track) => track.stop()); activeRecorder = undefined; }
  clearActiveMediaUrls();
  activeMessageExpiries.clear();
}

export async function renderChatPage(panel: HTMLElement, vaultKey: CryptoKey, notify: Notice, errorMessage = ''): Promise<void> {
  stopChatPage();
  const heading = `<div class="section-heading"><div><p class="eyebrow">PRIVADO ENTRE VOCÊS</p><h2>Chat</h2><p class="muted">Mensagens e fotos expiram uma hora após o envio.</p></div></div>`;
  if (!backendConfigured || !supabase) {
    panel.innerHTML = `${heading}<div class="chat-empty"><div class="empty-symbol">♡</div><h3>Mensagens privadas</h3><p>Configure o backend para entregar o chat. O serviço guarda apenas mensagens e arquivos cifrados e os remove depois de uma hora.</p><div class="chat-contract"><span>01</span><p>Quem recebe decide se salva a foto.</p><span>02</span><p>Salvar cria uma cópia cifrada no cofre deste iPhone.</p><span>03</span><p>Sem salvar, a mensagem expira após uma hora.</p></div><span class="notice">Defina as variáveis de <code>pwa/.env</code> e publique o backend Supabase.</span></div>`;
    return;
  }

  const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
  if (sessionError) return errorPanel(panel, heading, sessionError.message, vaultKey, notify);
  const user = sessionData.session?.user;
  if (!user) return authPanel(panel, heading, vaultKey, notify, errorMessage);

  let couple: Couple | null;
  try { couple = await currentCouple(supabase, user); }
  catch (error) { return errorPanel(panel, heading, error, vaultKey, notify); }

  const pairToken = new URLSearchParams(location.hash.replace(/^#/, '')).get('pair');
  if (!couple && pairToken) return noPartnerPanel(panel, heading, vaultKey, notify, user);

  if (!couple) return noPartnerPanel(panel, heading, vaultKey, notify, user);

  if (!couple.member_two) {
    let secret: Uint8Array | undefined;
    try { secret = await loadPairSecret(supabase, couple.id, vaultKey); }
    catch (error) { return errorPanel(panel, heading, error, vaultKey, notify); }
    return pendingPartnerPanel(panel, heading, couple, secret, vaultKey, notify, user);
  }

  let secret: Uint8Array | undefined;
  try { secret = await loadPairSecret(supabase, couple.id, vaultKey); }
  catch (error) { return errorPanel(panel, heading, error, vaultKey, notify); }
  if (!secret) {
    panel.innerHTML = `${heading}<div class="chat-empty"><h3>Chave de pareamento indisponível</h3><p>O chat não pode ser recuperado só com a conta: a chave privada fica cifrada neste aparelho. Não limpe os dados do site sem exportar uma recuperação.</p></div>`;
    return;
  }
  await conversationPanel(panel, heading, couple, user, secret, vaultKey, notify);
}

function errorPanel(panel: HTMLElement, heading: string, error: unknown, vaultKey: CryptoKey, notify: Notice): void {
  panel.innerHTML = `${heading}<div class="notice error">${escape(error instanceof Error ? error.message : String(error))}</div><button id="retry-chat" class="secondary">Tentar novamente</button>`;
  panel.querySelector<HTMLButtonElement>('#retry-chat')?.addEventListener('click', () => void renderChatPage(panel, vaultKey, notify));
}

function authPanel(panel: HTMLElement, heading: string, vaultKey: CryptoKey, notify: Notice, errorMessage = ''): void {
  panel.innerHTML = `${heading}<div class="auth-card"><form id="chat-auth-form" class="stack"><label for="chat-email">E-mail</label><input id="chat-email" name="email" type="email" autocomplete="email" required /><label for="chat-password">Senha da conta de mensagens</label><input id="chat-password" name="password" type="password" minlength="10" autocomplete="current-password" required /><div class="auth-buttons"><button class="primary" name="action" value="login">Entrar</button><button class="secondary" name="action" value="signup">Criar conta</button></div></form>${errorMessage ? `<div class="notice error">${escape(errorMessage)}</div>` : ''}<p class="small">A conta serve para encontrar a outra pessoa. O conteúdo e a senha do cofre não são enviados junto.</p></div>`;
  panel.querySelector<HTMLFormElement>('#chat-auth-form')?.addEventListener('submit', async (event) => {
    event.preventDefault();
    if (!supabase) return;
    const submitter = (event as SubmitEvent).submitter as HTMLButtonElement | null;
    const values = new FormData(event.currentTarget as HTMLFormElement);
    const email = String(values.get('email') ?? '').trim();
    const password = String(values.get('password') ?? '');
    if (!submitter) return;
    try {
      const result = submitter.value === 'signup'
        ? await supabase.auth.signUp({ email, password })
        : await supabase.auth.signInWithPassword({ email, password });
      if (result.error) throw result.error;
      if (submitter.value === 'signup' && !result.data.session) {
        return authPanel(panel, heading, vaultKey, notify, 'Confirme o cadastro pelo e-mail e depois entre no chat.');
      }
      await renderChatPage(panel, vaultKey, notify);
    } catch (error) { authPanel(panel, heading, vaultKey, notify, error instanceof Error ? error.message : 'Não foi possível entrar.'); }
  });
}

function noPartnerPanel(panel: HTMLElement, heading: string, vaultKey: CryptoKey, notify: Notice, user: User): void {
  const token = new URLSearchParams(location.hash.replace(/^#/, '')).get('pair');
  panel.innerHTML = `${heading}<div class="chat-empty"><div class="empty-symbol">♡</div><h3>${token ? 'Convite de pareamento' : 'Conecte os dois cofres'}</h3><p>${token ? 'Este convite vincula esta conta ao cofre de quem enviou.' : 'Crie um convite de uso único ou cole aqui o link recebido.'}</p>${token ? '<button id="accept-pair" class="primary">Aceitar convite</button>' : '<div class="pairing-actions"><button id="create-pair" class="primary">Criar convite privado</button><form id="paste-pair-form" class="stack"><label for="paste-pair-link">Já recebeu um convite?</label><input id="paste-pair-link" type="url" inputmode="url" autocomplete="off" placeholder="Cole o link do convite" required/><button class="secondary" type="submit">Usar convite</button></form></div>'}<div class="auth-footer"><button id="sign-out" class="text-button">Sair da conta</button></div></div>`;
  panel.querySelector<HTMLButtonElement>('#accept-pair')?.addEventListener('click', async () => {
    try { await acceptInvite(supabase!, token!, vaultKey); await renderChatPage(panel, vaultKey, notify); }
    catch (error) { await renderChatPage(panel, vaultKey, notify, error instanceof Error ? error.message : 'Convite inválido ou expirado.'); }
  });
  panel.querySelector<HTMLButtonElement>('#create-pair')?.addEventListener('click', async () => {
    try { await createInvite(supabase!, vaultKey); await renderChatPage(panel, vaultKey, notify); }
    catch (error) { await renderChatPage(panel, vaultKey, notify, error instanceof Error ? error.message : 'Não foi possível criar o convite.'); }
  });
  panel.querySelector<HTMLFormElement>('#paste-pair-form')?.addEventListener('submit', (event) => {
    event.preventDefault();
    const field = panel.querySelector<HTMLInputElement>('#paste-pair-link');
    const tokenFromLink = field ? extractPairToken(field.value) : undefined;
    if (!tokenFromLink) return notify('Não encontrei um convite válido nesse link.');
    location.hash = `pair=${tokenFromLink}`;
    void renderChatPage(panel, vaultKey, notify);
  });
  panel.querySelector<HTMLButtonElement>('#sign-out')?.addEventListener('click', async () => { await supabase!.auth.signOut(); await renderChatPage(panel, vaultKey, notify); });
  if (token && !user) authPanel(panel, heading, vaultKey, notify);
}

function extractPairToken(value: string): string | undefined {
  try {
    const url = new URL(value.trim());
    const token = new URLSearchParams(url.hash.replace(/^#/, '')).get('pair');
    return token && /^[A-Za-z0-9_-]{40,50}$/.test(token) ? token : undefined;
  } catch { return undefined; }
}

function pendingPartnerPanel(panel: HTMLElement, heading: string, couple: Couple, secret: Uint8Array | undefined, vaultKey: CryptoKey, notify: Notice, user: User): void {
  panel.innerHTML = `${heading}<div class="chat-empty"><div class="empty-symbol">♡</div><h3>Convite enviado</h3><p>Quando ela abrir o convite e entrar na conta dela, o chat será ativado. O convite vence em 24 horas.</p>${secret ? '<canvas id="pair-qr" class="pair-qr" aria-label="QR Code do convite privado"></canvas><div class="pair-actions"><button id="copy-pair" class="primary">Copiar link</button><button id="share-pair" class="secondary">Compartilhar</button></div><p class="small">Este QR dá acesso ao convite. Mostre apenas para sua esposa.</p>' : '<div class="notice error">Não encontrei a chave local do convite.</div>'}<div class="auth-footer"><button id="cancel-pair" class="text-button">Cancelar convite</button><button id="sign-out" class="text-button">Sair da conta</button></div></div>`;
  const inviteLink = secret ? inviteUrlFromSecret(secret) : '';
  const canvas = panel.querySelector<HTMLCanvasElement>('#pair-qr');
  if (canvas) void QRCode.toCanvas(canvas, inviteLink, { width: 224, margin: 2, errorCorrectionLevel: 'M', color: { dark: '#342b28', light: '#fffdfa' } }).catch(() => notify('Não foi possível gerar o QR Code neste aparelho.'));
  panel.querySelector<HTMLButtonElement>('#copy-pair')?.addEventListener('click', async () => {
    try { await navigator.clipboard.writeText(inviteLink); notify('Link do convite copiado. Envie apenas para sua esposa.'); }
    catch { notify('Não foi possível copiar o convite. Use a opção Compartilhar.'); }
  });
  panel.querySelector<HTMLButtonElement>('#share-pair')?.addEventListener('click', async () => {
    try {
      if (navigator.share) await navigator.share({ title: 'Convite privado · Vault of Us', text: 'Convite para parear nossos cofres. Válido por 24 horas.', url: inviteLink });
      else { await navigator.clipboard.writeText(inviteLink); notify('Link do convite copiado. Envie apenas para sua esposa.'); }
    } catch (error) { if (error instanceof Error && error.name !== 'AbortError') notify('Não foi possível compartilhar o convite.'); }
  });
  panel.querySelector<HTMLButtonElement>('#cancel-pair')?.addEventListener('click', async () => {
    const { error } = await supabase!.rpc('cancel_partner_invite', { couple_id_to_cancel: couple.id });
    if (error) return notify(error.message);
    await removeLocalPairSecret(couple.id);
    await renderChatPage(panel, vaultKey, notify);
  });
  panel.querySelector<HTMLButtonElement>('#sign-out')?.addEventListener('click', async () => { await supabase!.auth.signOut(); await renderChatPage(panel, vaultKey, notify); });
  void user;
}

async function conversationPanel(panel: HTMLElement, heading: string, couple: Couple, user: User, secret: Uint8Array, vaultKey: CryptoKey, notify: Notice): Promise<void> {
  if (!supabase) return;
  const generation = ++conversationRenderGeneration;
  const client = supabase;
  let messages: ChatMessage[];
  try { messages = await listMessages(client, couple.id); }
  catch (error) {
    if (generation !== conversationRenderGeneration || !panel.isConnected) return;
    clearActiveMediaUrls();
    return errorPanel(panel, heading, error, vaultKey, notify);
  }
  if (generation !== conversationRenderGeneration || !panel.isConnected) return;
  const visibleMessageIds = new Set(messages.map((message) => message.id));
  for (const [messageId, url] of activeUrls) {
    if (visibleMessageIds.has(messageId)) continue;
    URL.revokeObjectURL(url);
    activeUrls.delete(messageId);
  }
  for (const messageId of activeMessageExpiries.keys()) {
    if (!visibleMessageIds.has(messageId)) activeMessageExpiries.delete(messageId);
  }
  const rows: string[] = [];
  const now = Date.now();
  for (const message of messages) {
    const expiresAt = Date.parse(message.expires_at);
    if (expiresAt <= Date.now()) { discardMessageContent(message.id); continue; }
    activeMessageExpiries.set(message.id, expiresAt);
    const mine = message.sender_id === user.id;
    if (!mine && !message.read_at) void client.rpc('mark_chat_message_read', { message_id_to_mark: message.id });
    const minutes = Math.max(0, Math.ceil((Date.parse(message.expires_at) - now) / 60_000));
    const clock = `${new Date(message.sent_at).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })} · ${minutes} min${mine && message.read_at ? ' · lida' : ''}`;
    if (message.message_type === 'text') {
      try {
        const plaintext = await decryptMessage(client, couple.id, secret, message);
        if (generation !== conversationRenderGeneration || !panel.isConnected) return;
        if (Date.parse(message.expires_at) <= Date.now()) { discardMessageContent(message.id); continue; }
        rows.push(`<article class="bubble-row ${mine ? 'mine' : ''}" data-message-id="${message.id}"><div class="chat-bubble"><p>${escape(new TextDecoder().decode(plaintext))}</p><time>${clock}</time></div></article>`);
      } catch {
        if (Date.parse(message.expires_at) <= Date.now()) { discardMessageContent(message.id); continue; }
        rows.push(`<article class="bubble-row" data-message-id="${message.id}"><div class="chat-bubble"><p>Mensagem indisponível.</p></div></article>`);
      }
      continue;
    }
    try {
      let url = activeUrls.get(message.id);
      if (!url) {
        const plaintext = await decryptMessage(client, couple.id, secret, message);
        if (generation !== conversationRenderGeneration || !panel.isConnected) return;
        if (Date.parse(message.expires_at) <= Date.now()) { discardMessageContent(message.id); continue; }
        url = URL.createObjectURL(new Blob([asArrayBuffer(plaintext)], { type: message.media_type || 'application/octet-stream' }));
        activeUrls.set(message.id, url);
      }
      const media = message.message_type === 'video'
        ? `<video src="${url}" controls playsinline></video>`
        : message.message_type === 'audio'
          ? `<audio src="${url}" controls></audio>`
          : `<img src="${url}" alt="Foto recebida" loading="lazy" />`;
      rows.push(`<article class="bubble-row ${mine ? 'mine' : ''}" data-message-id="${message.id}"><div class="chat-bubble media-bubble">${media}${mine ? '' : `<button class="save-chat-media" data-save-media="${message.id}">Salvar no meu cofre</button>`}<time>${clock}</time></div></article>`);
    } catch {
      if (Date.parse(message.expires_at) <= Date.now()) { discardMessageContent(message.id); continue; }
      rows.push(`<article class="bubble-row" data-message-id="${message.id}"><div class="chat-bubble"><p>Esta mídia já expirou ou não pode ser aberta.</p></div></article>`);
    }
  }
  if (generation !== conversationRenderGeneration || !panel.isConnected) return;
  panel.innerHTML = `${heading}<div class="conversation-top"><span>Conversa pareada</span><div>${webPushPublicKey() ? '<button id="enable-chat-push" class="text-button">Ativar avisos</button>' : ''}<button id="sign-out" class="text-button">Sair</button></div></div><div class="message-list" id="message-list">${rows.length ? rows.join('') : '<div class="empty-inline">Ainda não há mensagens. Envie um oi.</div>'}</div><form id="chat-compose" class="chat-compose"><button type="button" id="attach-media" class="attach-button" aria-label="Enviar foto, vídeo ou áudio">＋</button><input id="chat-file" type="file" accept="image/*,video/*,audio/*" hidden /><button type="button" id="record-audio" class="attach-button ${activeRecorder ? 'recording' : ''}" aria-label="${activeRecorder ? 'Encerrar gravação' : 'Gravar áudio'}">${activeRecorder ? '■' : '🎙'}</button><input name="text" maxlength="4000" autocomplete="off" placeholder="Escreva uma mensagem…" /><button type="submit" class="send-button" aria-label="Enviar mensagem">➤</button></form><p class="chat-expiry-note">Mensagens, áudios e mídias expiram após 1 hora. Quem recebe pode salvar antes do vencimento.</p>`;
  const messageList = panel.querySelector<HTMLElement>('#message-list');
  if (messageList) messageList.scrollTop = messageList.scrollHeight;
  if (expiryTimer !== undefined) window.clearTimeout(expiryTimer);
  const nextExpiry = Math.min(...messages.map((message) => Date.parse(message.expires_at)).filter((expiry) => expiry > Date.now()));
  if (Number.isFinite(nextExpiry)) {
    expiryTimer = window.setTimeout(() => {
      if (!panel.isConnected) return;
      removeExpiredVisibleMessages(panel);
      if (document.visibilityState === 'visible') void conversationPanel(panel, heading, couple, user, secret, vaultKey, notify);
    }, Math.max(0, nextExpiry - Date.now() + 5));
  }

  panel.querySelector<HTMLFormElement>('#chat-compose')?.addEventListener('submit', async (event) => {
    event.preventDefault();
    const input = (event.currentTarget as HTMLFormElement).elements.namedItem('text') as HTMLInputElement;
    const text = input.value.trim();
    if (!text) return;
    input.disabled = true;
    try { await sendText(client, couple.id, user, secret, text); await conversationPanel(panel, heading, couple, user, secret, vaultKey, notify); }
    catch (error) { input.disabled = false; notify(error instanceof Error ? error.message : 'Não foi possível enviar.'); }
  });
  panel.querySelector<HTMLButtonElement>('#attach-media')?.addEventListener('click', () => panel.querySelector<HTMLInputElement>('#chat-file')?.click());
  panel.querySelector<HTMLInputElement>('#chat-file')?.addEventListener('change', async (event) => {
    const input = event.currentTarget as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    if (file.size > 50 * 1024 * 1024 - 16) { notify('Cada mídia do chat pode ter até 50 MB antes da cifragem.'); input.value = ''; return; }
    try { await sendMedia(client, couple.id, user, secret, file); await conversationPanel(panel, heading, couple, user, secret, vaultKey, notify); }
    catch (error) { notify(error instanceof Error ? error.message : 'Não foi possível enviar a mídia.'); }
    input.value = '';
  });
  panel.querySelector<HTMLButtonElement>('#record-audio')?.addEventListener('click', async (event) => {
    const button = event.currentTarget as HTMLButtonElement;
    if (activeRecorder) { activeRecorder.recorder.stop(); button.textContent = '🎙'; button.classList.remove('recording'); return; }
    if (!navigator.mediaDevices?.getUserMedia || !('MediaRecorder' in window)) { notify('Este navegador não oferece gravação de áudio.'); return; }
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mimeType = ['audio/mp4', 'audio/webm;codecs=opus', 'audio/webm'].find((mime) => MediaRecorder.isTypeSupported(mime));
      const recorder = new MediaRecorder(stream, mimeType ? { mimeType } : undefined);
      const chunks: Blob[] = [];
      recorder.ondataavailable = (data) => { if (data.data.size) chunks.push(data.data); };
      recorder.onstop = async () => {
        stream.getTracks().forEach((track) => track.stop());
        const discard = activeRecorder?.recorder !== recorder || activeRecorder.discard;
        if (activeRecorder?.recorder === recorder) activeRecorder = undefined;
        if (discard) return;
        const type = recorder.mimeType || 'audio/webm';
        const audio = new File(chunks, `audio-${Date.now()}.${type.includes('mp4') ? 'm4a' : 'webm'}`, { type });
        if (audio.size > 50 * 1024 * 1024 - 16) { notify('O áudio ultrapassou o limite de 50 MB.'); return; }
        try { await sendMedia(client, couple.id, user, secret, audio); await conversationPanel(panel, heading, couple, user, secret, vaultKey, notify); }
        catch (error) { notify(error instanceof Error ? error.message : 'Não foi possível enviar o áudio.'); }
      };
      activeRecorder = { recorder, stream, chunks, discard: false };
      recorder.start(); button.textContent = '■'; button.classList.add('recording'); notify('Gravando áudio. Toque no botão para encerrar e enviar.');
    } catch (error) { notify(error instanceof Error ? error.message : 'Permita o microfone para gravar áudio.'); }
  });
  panel.querySelectorAll<HTMLButtonElement>('[data-save-media]').forEach((button) => button.addEventListener('click', async () => {
    const message = messages.find((item) => item.id === button.dataset.saveMedia);
    if (!message || !message.media_type) return;
    button.disabled = true;
    try {
      if (Date.parse(message.expires_at) <= Date.now()) throw new Error('Esta mídia expirou e não pode mais ser salva.');
      const plaintext = await decryptMessage(client, couple.id, secret, message);
      if (Date.parse(message.expires_at) <= Date.now()) throw new Error('Esta mídia expirou antes de terminar de baixar.');
      const extension = message.media_type.split('/').at(-1)?.replace(/[^a-z0-9]/gi, '') || 'bin';
      const file = new File([asArrayBuffer(plaintext)], `recebido-${message.id}.${extension}`, { type: message.media_type });
      const result = await importFile(file, vaultKey);
      if (Date.parse(message.expires_at) <= Date.now() && !result.duplicate) {
        await permanentlyDelete(result.record);
        throw new Error('Esta mídia expirou antes de terminar de salvar.');
      }
      button.textContent = result.duplicate ? 'Já está no cofre' : 'Salva no cofre';
      button.disabled = result.duplicate;
      notify(result.duplicate ? 'Esta mídia já existe no cofre deste aparelho.' : 'Cópia cifrada salva no cofre deste aparelho.');
    } catch (error) { button.disabled = false; notify(error instanceof Error ? error.message : 'Não foi possível salvar.'); }
  }));
  panel.querySelector<HTMLButtonElement>('#enable-chat-push')?.addEventListener('click', async () => {
    try { await subscribeForPush(client, user, webPushPublicKey()!); notify('Avisos ativados. O conteúdo da conversa não aparecerá na notificação.'); }
    catch (error) { notify(error instanceof Error ? error.message : 'Não foi possível ativar os avisos.'); }
  });
  panel.querySelector<HTMLButtonElement>('#sign-out')?.addEventListener('click', async () => { await client.auth.signOut(); await renderChatPage(panel, vaultKey, notify); });

  if (activeCoupleId !== couple.id) {
    if (activeChannel) void client.removeChannel(activeChannel);
    activeCoupleId = couple.id;
    visibilityHandler = () => {
      if (document.visibilityState !== 'visible') return;
      removeExpiredVisibleMessages(panel);
      void conversationPanel(panel, heading, couple, user, secret, vaultKey, notify);
    };
    document.addEventListener('visibilitychange', visibilityHandler);
    activeChannel = client.channel(`chat:${couple.id}`).on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'chat_messages', filter: `couple_id=eq.${couple.id}` },
      () => { if (document.visibilityState === 'visible') void conversationPanel(panel, heading, couple, user, secret, vaultKey, notify); },
    ).subscribe();
    refreshTimer = window.setInterval(() => {
      if (document.visibilityState === 'visible') void conversationPanel(panel, heading, couple, user, secret, vaultKey, notify);
    }, 20_000);
  }
}
