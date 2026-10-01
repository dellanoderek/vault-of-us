import './style.css';
import { createSecretModeCredential, createVault, decryptBytes, encryptBytes, sha256, unlockVault, verifySecretModeCredential, type SecretModeCredential } from './crypto';
import { deleteRecord, getAll, getRecord, openDb, putRecord, type MediaRecord } from './db';
import { createAlbum, deleteAlbum, getSettings, importFile, listAlbums, listMedia, originalBlob, permanentlyDelete, purgeExpiredTrash, saveSettings, settingsExist, thumbnailUrl, updateMedia } from './vault';
import { renderChatPage, stopChatPage } from './chat_ui';
import { syncSharedRecords, type SyncState } from './shared_sync';

type Page = 'vault' | 'chat' | 'memories' | 'together' | 'settings';
type Filter = 'all' | 'favorites' | 'trash' | 'secret';

const root = document.querySelector<HTMLDivElement>('#app')!;
let vaultKey: CryptoKey | undefined;
let page: Page = location.hash === '#chat' ? 'chat' : 'vault';
let filter: Filter = 'all';
let secretModeUnlocked = false;
let selectedAlbum = '';
let urls: string[] = [];
let busy = false;
let lockTimeoutMs = 0;
let backgroundAt: number | undefined;
let lockTimer: number | undefined;
let capsuleTimer: number | undefined;
let cancelSecureInput: (() => void) | undefined;
const MAX_IMPORT_BYTES = 200 * 1024 * 1024;

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.addEventListener('message', (event: MessageEvent<{ type?: string }>) => {
    if (event.data?.type !== 'open-chat') return;
    page = 'chat';
    if (vaultKey) void renderApp();
  });
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]!);
}

function formatSize(bytes: number): string {
  if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function requestSecureInput(title: string, description: string, label: string, minLength = 8): Promise<string | undefined> {
  return new Promise((resolve) => {
    const dialog = document.createElement('dialog');
    dialog.className = 'secret-pin-dialog';
    dialog.innerHTML = `<form method="dialog" class="stack"><h2>${escapeHtml(title)}</h2><p class="muted">${escapeHtml(description)}</p><label for="secure-input">${escapeHtml(label)}</label><input id="secure-input" type="password" minlength="${minLength}" autocomplete="off" required/><div class="button-row"><button type="button" class="text-button" data-cancel>Cancelar</button><button class="primary" type="submit">Continuar</button></div></form>`;
    document.body.append(dialog);
    const finish = (value?: string) => { dialog.close(); dialog.remove(); if (cancelSecureInput === cancel) cancelSecureInput = undefined; resolve(value); };
    const cancel = () => finish();
    cancelSecureInput = cancel;
    dialog.querySelector<HTMLFormElement>('form')?.addEventListener('submit', (event) => { event.preventDefault(); const value = dialog.querySelector<HTMLInputElement>('#secure-input')?.value; finish(value); });
    dialog.querySelector<HTMLButtonElement>('[data-cancel]')?.addEventListener('click', () => finish());
    dialog.addEventListener('cancel', (event) => { event.preventDefault(); finish(); }, { once: true });
    dialog.showModal();
    dialog.querySelector<HTMLInputElement>('#secure-input')?.focus();
  });
}

function revokeUrls(): void {
  urls.forEach((url) => URL.revokeObjectURL(url));
  urls = [];
}

function mountLock(isNew: boolean, message = ''): void {
  cancelSecureInput?.();
  stopChatPage();
  revokeUrls();
  if (lockTimer !== undefined) window.clearTimeout(lockTimer);
  lockTimer = undefined;
  backgroundAt = undefined;
  vaultKey = undefined;
  secretModeUnlocked = false;
  filter = 'all';
  root.innerHTML = `
    <main class="lock-page">
      <div class="lock-card">
        <div class="brand-mark">v<span>♡</span></div>
        <p class="eyebrow">UM LUGAR SÓ DE VOCÊS</p>
        <h1>${isNew ? 'Crie seu cofre' : 'Desbloqueie seu cofre'}</h1>
        <p class="muted">Suas fotos ficam cifradas neste aparelho e não aparecem na Galeria.</p>
        ${message ? `<div class="notice error">${escapeHtml(message)}</div>` : ''}
        <form id="unlock-form" class="stack">
          <label for="passphrase">${isNew ? 'Crie uma senha longa para o cofre' : 'Senha do cofre'}</label>
          <input id="passphrase" name="passphrase" type="password" minlength="12" autocomplete="${isNew ? 'new-password' : 'current-password'}" placeholder="Use pelo menos 12 caracteres" required />
          ${isNew ? '<label for="passphrase-again">Confirme a senha</label><input id="passphrase-again" name="passphraseAgain" type="password" minlength="12" autocomplete="new-password" placeholder="Digite novamente" required />' : ''}
          <button class="primary" type="submit" ${busy ? 'disabled' : ''}>${busy ? 'Preparando cofre…' : isNew ? 'Criar cofre local' : 'Desbloquear'}</button>
        </form>
        <p class="security-note">A senha não é enviada ao servidor. Se você esquecê-la, este cofre não poderá ser recuperado sem um backup.</p>
      </div>
    </main>`;
  
  if (!isNew) {
    getRecord<{ credentialId: string; rawKey: string }>('preferences', 'biometric-vault-key').then((bioPref) => {
      if (!bioPref) return;
      const form = root.querySelector('#unlock-form');
      if (!form) return;
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'secondary';
      btn.style.marginBottom = '0.5rem';
      btn.innerHTML = 'Desbloquear com Biometria';
      btn.onclick = async () => {
        try {
          btn.disabled = true;
          btn.textContent = 'Verificando...';
          const challenge = crypto.getRandomValues(new Uint8Array(32));
          const assertion = await navigator.credentials.get({
            publicKey: {
              challenge,
              allowCredentials: [{ type: 'public-key', id: asBuffer(fromBase64(bioPref.credentialId)) }],
              userVerification: 'required'
            }
          });
          if (assertion) {
            vaultKey = await crypto.subtle.importKey('raw', asBuffer(fromBase64(bioPref.rawKey)), 'AES-GCM', false, ['encrypt', 'decrypt']);
            const lockPreference = await getRecord<{ key: string; value: number }>('preferences', 'lock-timeout');
            lockTimeoutMs = lockPreference?.value ?? 0;
            await requestPersistentStorage();
            const purged = await purgeExpiredTrash(vaultKey);
            renderApp();
            if (purged) showToast(`${purged} ${purged === 1 ? 'item removido' : 'itens removidos'} da lixeira.`);
          }
        } catch (e) {
          btn.disabled = false;
          btn.innerHTML = 'Desbloquear com Biometria';
          showToast('Biometria falhou ou foi cancelada.');
        }
      };
      form.insertBefore(btn, form.firstChild);
    });
  }

  document.querySelector<HTMLFormElement>('#unlock-form')?.addEventListener('submit', async (event) => {
    event.preventDefault();
    const form = new FormData(event.currentTarget as HTMLFormElement);
    const passphrase = String(form.get('passphrase') ?? '');
    if (passphrase.length < 12) return mountLock(isNew, 'Use uma senha com pelo menos 12 caracteres.');
    if (isNew && passphrase !== String(form.get('passphraseAgain') ?? '')) return mountLock(true, 'As senhas não conferem.');
    busy = true;
    mountLock(isNew);
    try {
      if (isNew) {
        const created = await createVault(passphrase);
        await saveSettings(created.settings);
        vaultKey = created.key;
      } else {
        const settings = await getSettings();
        if (!settings) return mountLock(true);
        vaultKey = await unlockVault(passphrase, settings);
      }
      busy = false;
      const lockPreference = await getRecord<{ key: string; value: number }>('preferences', 'lock-timeout');
      lockTimeoutMs = lockPreference?.value ?? 0;
      await requestPersistentStorage();
      const purged = await purgeExpiredTrash(vaultKey);
      renderApp();
      if (purged) showToast(`${purged} ${purged === 1 ? 'item removido' : 'itens removidos'} da lixeira após 30 dias.`);
    } catch {
      busy = false;
      mountLock(isNew, isNew ? 'Não foi possível criar o cofre neste navegador.' : 'Senha incorreta ou dados locais indisponíveis.');
    }
  });
}

async function requestPersistentStorage(): Promise<boolean | undefined> {
  if (!navigator.storage?.persist) return undefined;
  try { return await navigator.storage.persist(); } catch { return false; }
}

async function renderApp(): Promise<void> {
  if (!vaultKey) return mountLock(await settingsExist());
  revokeUrls();
  const appName = 'Vault of Us';
  root.innerHTML = `
    <div class="app-shell">
      <header class="topbar">
        <a class="wordmark" href="#vault"><span class="brand-dot">v</span><span>${appName}</span></a>
        <div class="top-actions"><span class="local-badge"><i></i> COFRE NESTE APARELHO</span><button class="icon-button" id="lock-button" aria-label="Bloquear cofre" title="Bloquear">⌑</button></div>
      </header>
      <main class="main-content">
        <div class="mobile-greeting"><p class="eyebrow">O QUE É DE VOCÊS</p><h1>Um lugar para guardar<br/>o que importa.</h1></div>
        <nav class="tabs" aria-label="Navegação principal">
          ${navButton('vault', 'Cofre', '⌂')}${navButton('chat', 'Chat', '♡')}${navButton('memories', 'Memórias', '✳')}${navButton('together', 'A dois', '☼')}${navButton('settings', 'Ajustes', '⚙')}
        </nav>
        <section id="page-content" aria-live="polite"></section>
      </main>
      <footer class="bottom-note">As fotos do cofre são cifradas neste aparelho.</footer>
    </div>`;
  root.querySelectorAll<HTMLButtonElement>('[data-page]').forEach((button) => button.addEventListener('click', () => {
    page = button.dataset.page as Page;
    renderPage();
  }));
  document.querySelector<HTMLButtonElement>('#lock-button')?.addEventListener('click', () => mountLock(false));
  await renderPage();
}

function navButton(target: Page, label: string, icon: string): string {
  return `<button class="tab ${page === target ? 'active' : ''}" data-page="${target}"><span class="tab-icon">${icon}</span><span>${label}</span></button>`;
}

async function renderPage(): Promise<void> {
  const panel = document.querySelector<HTMLElement>('#page-content');
  if (!panel || !vaultKey) return;
  if (page !== 'chat') stopChatPage();
  if (page !== 'together' && capsuleTimer !== undefined) { window.clearTimeout(capsuleTimer); capsuleTimer = undefined; }
  root.querySelectorAll<HTMLButtonElement>('.tab').forEach((button) => button.classList.toggle('active', button.dataset.page === page));
  if (page === 'vault') return renderVault(panel);
  if (page === 'settings') return renderSettings(panel);
  if (page === 'chat') return renderChat(panel);
  if (page === 'memories') return renderMemories(panel);
  renderTogether(panel);
}

async function renderVault(panel: HTMLElement): Promise<void> {
  const key = vaultKey;
  if (!key) return;
  const albums = await listAlbums(key);
  const secretCredential = await getRecord<SecretModeCredential>('preferences', 'secret-mode-pin');
  panel.innerHTML = `
    <div class="section-heading"><div><p class="eyebrow">SEU ESPAÇO PRIVADO</p><h2>Meu cofre</h2><p class="muted">Só aparece aqui, dentro do Vault of Us.</p></div>
      <button class="primary add-button" id="add-media">＋ <span>Adicionar fotos</span></button>
    </div>
    <div class="filter-row">
      <div class="segmented">
        <button data-filter="all" class="${filter === 'all' ? 'selected' : ''}">Tudo</button>
        <button data-filter="favorites" class="${filter === 'favorites' ? 'selected' : ''}">Favoritos</button>
        <button data-filter="trash" class="${filter === 'trash' ? 'selected' : ''}">Lixeira</button>
        ${secretCredential ? `<button data-filter="secret" class="${filter === 'secret' ? 'selected' : ''}">🔒 Secreto</button>` : ''}
      </div>
      <div class="album-tools"><select id="album-filter" aria-label="Filtrar por álbum"><option value="">Todos os álbuns</option>${albums.map((album) => `<option value="${album.id}" ${selectedAlbum === album.id ? 'selected' : ''}>${escapeHtml(album.name)}</option>`).join('')}</select><button id="create-album" class="secondary">＋ Álbum</button>${selectedAlbum ? '<button id="delete-album" class="text-button">Apagar álbum</button>' : ''}</div>
      <label class="visually-hidden" for="media-input">Escolha fotos ou vídeos</label>
      <input id="media-input" type="file" accept="image/*,video/*" multiple hidden />
    </div>
    <div id="media-grid" class="media-grid"><div class="loading">Abrindo seu cofre…</div></div>`;
  panel.querySelector<HTMLButtonElement>('#add-media')?.addEventListener('click', () => panel.querySelector<HTMLInputElement>('#media-input')?.click());
  panel.querySelector<HTMLInputElement>('#media-input')?.addEventListener('change', async (event) => {
    const files = [...((event.currentTarget as HTMLInputElement).files ?? [])];
    if (!files.length || !vaultKey) return;
    const oversized = files.find((file) => file.size > MAX_IMPORT_BYTES);
    if (oversized) { showToast(`${oversized.name} excede o limite de 200 MB desta versão.`); return; }
    if (filter === 'trash') filter = 'all';
    const button = panel.querySelector<HTMLButtonElement>('#add-media');
    if (button) { button.disabled = true; button.innerHTML = '<span>Importando…</span>'; }
    try {
      let added = 0;
      let duplicates = 0;
      for (const file of files) {
        const result = await importFile(file, key);
        const updated = { ...result.record, ...(selectedAlbum ? { albumId: selectedAlbum } : {}), ...(filter === 'secret' ? { secret: true } : {}) };
        if ((selectedAlbum && result.record.albumId !== selectedAlbum) || (filter === 'secret' && !result.record.secret)) await updateMedia(updated, key);
        result.duplicate ? duplicates++ : added++;
      }
      await renderVault(panel);
      showToast(`${added} ${added === 1 ? 'arquivo importado' : 'arquivos importados'}${duplicates ? ` · ${duplicates} duplicado(s) ignorado(s)` : ''}.`);
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Não foi possível importar o arquivo.');
      await renderVault(panel);
    }
  });
  panel.querySelectorAll<HTMLButtonElement>('[data-filter]').forEach((button) => button.addEventListener('click', async () => {
    const nextFilter = button.dataset.filter as Filter;
    if (nextFilter === 'secret' && !secretModeUnlocked) {
      const credential = await getRecord<SecretModeCredential>('preferences', 'secret-mode-pin');
      if (!credential) return showToast('Configure primeiro o PIN do Modo Secreto em Ajustes.');
      const pin = await requestSecureInput('Modo Secreto', 'Digite o PIN secundário para mostrar as mídias ocultas.', 'PIN secundário');
      if (!pin) return;
      const verified = await verifySecretModeCredential(pin, credential);
      if (vaultKey !== key || !panel.isConnected) return;
      if (!verified) return showToast('PIN incorreto.');
      secretModeUnlocked = true;
    }
    filter = nextFilter;
    void renderVault(panel);
  }));
  panel.querySelector<HTMLSelectElement>('#album-filter')?.addEventListener('change', (event) => { selectedAlbum = (event.currentTarget as HTMLSelectElement).value; void renderVault(panel); });
  panel.querySelector<HTMLButtonElement>('#create-album')?.addEventListener('click', async () => {
    const name = prompt('Nome do novo álbum:')?.trim();
    if (!name) return;
    if (name.length > 60) return showToast('O nome do álbum pode ter até 60 caracteres.');
    await createAlbum(name, key);
    await renderVault(panel);
  });
  panel.querySelector<HTMLButtonElement>('#delete-album')?.addEventListener('click', async () => {
    const album = albums.find((item) => item.id === selectedAlbum);
    if (!album || !confirm(`Apagar o álbum “${album.name}”? As mídias continuarão no cofre sem álbum.`)) return;
    await deleteAlbum(album.id, key); selectedAlbum = ''; await renderVault(panel);
  });
  const grid = panel.querySelector<HTMLElement>('#media-grid')!;
  const rows = (await listMedia(key, filter, secretModeUnlocked)).filter((item) => !selectedAlbum || item.albumId === selectedAlbum);
  if (!rows.length) {
    grid.innerHTML = `<div class="empty-state"><div class="empty-symbol">✧</div><h3>${filter === 'trash' ? 'Lixeira vazia' : filter === 'secret' ? 'Área secreta vazia' : selectedAlbum ? 'Nenhuma mídia neste álbum' : 'Seu cofre começa aqui'}</h3><p>${filter === 'trash' ? 'Os itens apagados aparecerão aqui.' : filter === 'secret' ? 'Mídias adicionadas daqui serão ocultadas das telas normais do cofre e das Memórias.' : 'Adicione uma foto ou vídeo. A cópia do cofre fica cifrada no armazenamento local deste aparelho.'}</p>${filter !== 'trash' ? '<button class="secondary" id="empty-add">Escolher fotos</button>' : ''}</div>`;
    grid.querySelector<HTMLButtonElement>('#empty-add')?.addEventListener('click', () => panel.querySelector<HTMLInputElement>('#media-input')?.click());
    return;
  }
  grid.innerHTML = rows.map((record) => `<article class="media-card" data-id="${record.id}"><button class="media-open" data-open="${record.id}" aria-label="Abrir ${escapeHtml(record.name)}"><span class="media-preview" id="preview-${record.id}">${record.type.startsWith('video/') ? '<span class="video-glyph">▶</span>' : record.type.startsWith('audio/') ? '<span class="audio-glyph">♫</span>' : '<span class="image-glyph">✧</span>'}</span></button><div class="media-info"><div><strong>${escapeHtml(record.name)}</strong><span>${formatSize(record.size)}${record.width && record.height ? ` · ${record.width}×${record.height}` : ''}</span></div><button class="favorite-toggle ${record.favorite ? 'is-favorite' : ''}" data-favorite="${record.id}" aria-label="${record.favorite ? 'Remover dos' : 'Adicionar aos'} favoritos">${record.favorite ? '♥' : '♡'}</button></div><label class="album-assignment"><span>Álbum</span><select data-album="${record.id}" aria-label="Álbum de ${escapeHtml(record.name)}"><option value="">Sem álbum</option>${albums.map((album) => `<option value="${album.id}" ${record.albumId === album.id ? 'selected' : ''}>${escapeHtml(album.name)}</option>`).join('')}</select></label><div class="media-menu">${filter !== 'trash' ? `<button data-secret="${record.id}">${filter === 'secret' ? 'Tirar do Modo Secreto' : 'Mover para o Modo Secreto'}</button>` : ''}<button data-trash="${record.id}">${filter === 'trash' ? 'Apagar para sempre' : 'Mover para lixeira'}</button>${filter === 'trash' ? `<button data-restore="${record.id}">Restaurar</button>` : ''}</div></article>`).join('');
  for (const record of rows) {
    const url = await thumbnailUrl(record, key);
    if (url) {
      urls.push(url);
      const preview = panel.querySelector<HTMLElement>(`#preview-${CSS.escape(record.id)}`);
      if (preview) preview.innerHTML = `<img src="${url}" alt="${escapeHtml(record.name)}" loading="lazy" />`;
    }
  }
  panel.querySelectorAll<HTMLButtonElement>('[data-favorite]').forEach((button) => button.addEventListener('click', async () => {
    const record = rows.find((item) => item.id === button.dataset.favorite);
    if (!record) return;
    await updateMedia({ ...record, favorite: !record.favorite }, key);
    await renderVault(panel);
  }));
  panel.querySelectorAll<HTMLButtonElement>('[data-secret]').forEach((button) => button.addEventListener('click', async () => {
    const record = rows.find((item) => item.id === button.dataset.secret);
    if (!record) return;
    await updateMedia({ ...record, secret: filter !== 'secret' }, key);
    await renderVault(panel);
    showToast(filter === 'secret' ? 'Mídia removida do Modo Secreto.' : 'Mídia ocultada das telas normais e das Memórias.');
  }));
  panel.querySelectorAll<HTMLSelectElement>('[data-album]').forEach((select) => select.addEventListener('change', async () => {
    const record = rows.find((item) => item.id === select.dataset.album);
    if (!record) return;
    const { albumId: _oldAlbum, ...withoutAlbum } = record;
    const updated = select.value ? { ...record, albumId: select.value } : withoutAlbum;
    await updateMedia(updated, key);
    if (selectedAlbum) await renderVault(panel);
  }));
  panel.querySelectorAll<HTMLButtonElement>('[data-trash]').forEach((button) => button.addEventListener('click', async () => {
    const record = rows.find((item) => item.id === button.dataset.trash);
    if (!record) return;
    if (filter === 'trash') {
      if (!confirm('Apagar definitivamente esta cópia local? Esta ação não pode ser desfeita.')) return;
      await permanentlyDelete(record);
    } else {
      await updateMedia({ ...record, deletedAt: new Date().toISOString() }, key);
    }
    await renderVault(panel);
  }));
  panel.querySelectorAll<HTMLButtonElement>('[data-restore]').forEach((button) => button.addEventListener('click', async () => {
    const record = rows.find((item) => item.id === button.dataset.restore);
    if (!record) return;
    const { deletedAt: _deletedAt, ...restored } = record;
    await updateMedia(restored, key);
    await renderVault(panel);
  }));
  panel.querySelectorAll<HTMLButtonElement>('[data-open]').forEach((button) => button.addEventListener('click', async () => {
    const record = rows.find((item) => item.id === button.dataset.open);
    if (!record) return;
    const blob = await originalBlob(record, key);
    const url = URL.createObjectURL(blob);
    urls.push(url);
    openMedia(record, url);
  }));
}

async function renderSettings(panel: HTMLElement): Promise<void> {
  const key = vaultKey;
  if (!key) return;
  const secretCredential = await getRecord<SecretModeCredential>('preferences', 'secret-mode-pin');
  const bioPref = await getRecord<{ credentialId: string; rawKey: string }>('preferences', 'biometric-vault-key');
  const biometricSupported = window.PublicKeyCredential !== undefined;
  const estimate = await navigator.storage?.estimate().catch(() => undefined);
  const persisted = await navigator.storage?.persisted().catch(() => false);
  const used = estimate?.usage ?? 0;
  const quota = estimate?.quota ?? 0;
  const media = await listMedia(key, 'all');
  const permanentCount = media.length;
  panel.innerHTML = `<div class="section-heading"><div><p class="eyebrow">CONTROLE DO APARELHO</p><h2>Ajustes do cofre</h2><p class="muted">Os dados abaixo pertencem ao armazenamento deste iPhone.</p></div></div>
    <div class="settings-grid">
      <section class="settings-card"><p class="eyebrow">DESBLOQUEIO RÁPIDO</p><h3>Face ID ou Digital</h3><p class="muted">${bioPref ? 'A biometria está ativada neste aparelho.' : 'Use biometria para abrir o cofre sem digitar a senha.'}</p>${biometricSupported ? `<button id="toggle-biometric" class="secondary">${bioPref ? 'Desativar Biometria' : 'Ativar Biometria'}</button>` : '<p class="small">Biometria não suportada neste navegador.</p>'}<p class="small">Se você remover os dados do site no sistema, a biometria e o cofre local serão desvinculados.</p></section>
      <section class="settings-card"><p class="eyebrow">ARMAZENAMENTO LOCAL</p><h3>${formatSize(used)} usados</h3><p class="muted">${quota ? `Estimativa disponível para este site: ${formatSize(Math.max(0, quota - used))}.` : 'O iPhone não informou uma estimativa de espaço.'}</p><div class="meter"><span style="width:${quota ? Math.min(100, Math.max(2, used / quota * 100)) : 0}%"></span></div><p class="small">${permanentCount} itens no cofre · ${persisted ? 'pedido de persistência concedido' : 'persistência ainda não concedida'}</p><button id="persist-storage" class="secondary">Proteger dados locais contra limpeza automática</button><label class="preference-label" for="lock-timeout">Bloqueio ao sair do app</label><select id="lock-timeout"><option value="0" ${lockTimeoutMs === 0 ? 'selected' : ''}>Imediato</option><option value="30000" ${lockTimeoutMs === 30000 ? 'selected' : ''}>Após 30 segundos</option><option value="60000" ${lockTimeoutMs === 60000 ? 'selected' : ''}>Após 1 minuto</option><option value="300000" ${lockTimeoutMs === 300000 ? 'selected' : ''}>Após 5 minutos</option></select><p class="small">No segundo plano, o navegador pode suspender temporizadores; o prazo é conferido ao voltar.</p><p class="small">O navegador ainda pode remover dados se a pessoa apagar o site, os dados do Safari ou a PWA.</p></section>
      <section class="settings-card"><p class="eyebrow">RECUPERAÇÃO</p><h3>Faça cópias de segurança</h3><p class="muted">O backup usa uma senha exclusiva para o arquivo. Para restaurar, você precisará dela e também da senha do cofre.</p><div class="button-row"><button id="export-backup" class="secondary">Exportar backup cifrado</button><label class="secondary file-button" for="backup-input">Restaurar backup</label><input id="backup-input" type="file" accept="application/vnd.vault-of-us.backup+json,.voub" hidden /></div><p class="small">O backup inclui fotos, vídeos e registros locais. Guarde o arquivo e a senha em lugares seguros.</p></section>
      <section class="settings-card"><p class="eyebrow">PRIVACIDADE EXTRA</p><h3>Modo Secreto</h3><p class="muted">${secretCredential ? 'PIN secundário configurado. As mídias secretas ficam fora das telas normais e das Memórias.' : 'Crie um PIN secundário para ocultar mídias das telas normais do cofre e das Memórias.'} As mídias continuam cifradas pela senha principal e o backup inclui todos os arquivos.</p><form id="secret-mode-form" class="stack">${secretCredential ? '<label for="secret-current-pin">PIN atual</label><input id="secret-current-pin" type="password" minlength="8" autocomplete="off" required/>' : ''}<label for="secret-new-pin">${secretCredential ? 'Novo PIN' : 'PIN secundário'}</label><input id="secret-new-pin" type="password" minlength="8" autocomplete="new-password" required/><label for="secret-confirm-pin">Confirme o PIN</label><input id="secret-confirm-pin" type="password" minlength="8" autocomplete="new-password" required/><button class="secondary" type="submit">${secretCredential ? 'Trocar PIN' : 'Ativar Modo Secreto'}</button></form>${secretCredential ? '<button id="recover-secret-media" class="text-button">Esqueci o PIN: revelar mídias secretas</button>' : ''}<p class="small">O PIN é verificado localmente. Ao bloquear o cofre, será necessário digitá-lo novamente para abrir a área secreta.</p></section>
      <section class="settings-card"><p class="eyebrow">CHAT E AVISOS</p><h3>Mensagens temporárias</h3><p class="muted">As fotos enviadas no chat terão uma hora de validade. O destinatário poderá salvar no cofre dele durante esse período.</p><button id="open-chat-settings" class="secondary">Configurar chat e avisos</button><p class="small">Depois de parear os aparelhos, ative os avisos na conversa. A notificação será genérica.</p></section>
    </div>`;
  panel.querySelector<HTMLButtonElement>('#toggle-biometric')?.addEventListener('click', async () => {
    if (bioPref) {
      await deleteRecord('preferences', 'biometric-vault-key');
      showToast('Biometria desativada.');
      await renderSettings(panel);
      return;
    }
    try {
      const challenge = crypto.getRandomValues(new Uint8Array(32));
      const userId = crypto.getRandomValues(new Uint8Array(16));
      const credential = await navigator.credentials.create({
        publicKey: {
          challenge,
          rp: { name: 'Vault of Us', id: location.hostname },
          user: { id: userId, name: 'Cofre', displayName: 'Acesso ao Cofre' },
          pubKeyCredParams: [{ type: 'public-key', alg: -7 }, { type: 'public-key', alg: -257 }],
          authenticatorSelection: { authenticatorAttachment: 'platform', userVerification: 'required' },
          timeout: 60000
        }
      });
      if (credential) {
        const exported = await crypto.subtle.exportKey('raw', vaultKey!);
        await putRecord('preferences', {
          key: 'biometric-vault-key',
          credentialId: toBase64(new Uint8Array((credential as PublicKeyCredential).rawId)),
          rawKey: toBase64(new Uint8Array(exported))
        });
        showToast('Biometria ativada com sucesso!');
        await renderSettings(panel);
      }
    } catch (error) {
      showToast('Não foi possível registrar a biometria.');
    }
  });
  panel.querySelector<HTMLFormElement>('#secret-mode-form')?.addEventListener('submit', async (event) => {
    event.preventDefault();
    const currentPin = panel.querySelector<HTMLInputElement>('#secret-current-pin')?.value;
    const nextPin = panel.querySelector<HTMLInputElement>('#secret-new-pin')?.value ?? '';
    const confirmPin = panel.querySelector<HTMLInputElement>('#secret-confirm-pin')?.value ?? '';
    if (secretCredential && (!currentPin || !await verifySecretModeCredential(currentPin, secretCredential))) return showToast('PIN atual incorreto.');
    if (nextPin.length < 8) return showToast('Use um PIN secundário com pelo menos 8 caracteres.');
    if (nextPin !== confirmPin) return showToast('Os PINs não conferem.');
    if (vaultKey !== key || !panel.isConnected) return;
    await putRecord('preferences', await createSecretModeCredential(nextPin));
    showToast(secretCredential ? 'PIN do Modo Secreto alterado.' : 'Modo Secreto ativado.');
    await renderSettings(panel);
  });
  panel.querySelector<HTMLButtonElement>('#recover-secret-media')?.addEventListener('click', async () => {
    const phrase = await requestSecureInput('Confirmar senha principal', 'Esta ação remove as marcações secretas e revela essas mídias nas telas normais.', 'Senha principal do cofre');
    if (!phrase) return;
    const settings = await getSettings();
    if (!settings) return showToast('Não encontrei as configurações do cofre principal.');
    try { await unlockVault(phrase, settings); } catch { return showToast('Senha principal incorreta.'); }
    if (vaultKey !== key || !panel.isConnected) return;
    const rows = await getAll<{ id: string; metadataIv: string; metadataCiphertext: Uint8Array }>('media');
    for (const row of rows) {
      const metadata = JSON.parse(new TextDecoder().decode(await decryptBytes(key, row.metadataIv, row.metadataCiphertext))) as MediaRecord;
      if (metadata.secret) { const { secret: _secret, ...visible } = metadata; await updateMedia(visible, key); }
    }
    await deleteRecord('preferences', 'secret-mode-pin');
    secretModeUnlocked = false;
    filter = filter === 'secret' ? 'all' : filter;
    showToast('Mídias reveladas nas telas normais. O Modo Secreto foi desativado.');
    await renderSettings(panel);
  });
  panel.querySelector<HTMLButtonElement>('#persist-storage')?.addEventListener('click', async () => {
    const granted = await requestPersistentStorage();
    showToast(granted ? 'O iPhone concedeu armazenamento persistente ao site.' : 'O iPhone não concedeu persistência. Vamos manter esta informação visível em Ajustes.');
    await renderSettings(panel);
  });
  panel.querySelector<HTMLSelectElement>('#lock-timeout')?.addEventListener('change', async (event) => {
    lockTimeoutMs = Number((event.currentTarget as HTMLSelectElement).value);
    await putRecord('preferences', { key: 'lock-timeout', value: lockTimeoutMs });
    showToast('Preferência de bloqueio atualizada.');
  });
  panel.querySelector<HTMLButtonElement>('#export-backup')?.addEventListener('click', async () => {
    try {
      const db = await openDb();
      const stores = ['settings', 'media', 'albums', 'local_messages', 'preferences'];
      const data: Record<string, unknown[]> = {};
      for (const store of stores) data[store] = await getAll(store);
      const blobs: Record<string, string> = {};
      const mediaById = new Map((data.media as { id: string; metadataIv: string; metadataCiphertext: Uint8Array }[]).map((row) => [row.id, row]));
      const mediaMetadata: Record<string, { size: number; hash: string; originalIv: string; thumbIv: string }> = {};
      for (const row of mediaById.values()) {
        const clear = await decryptBytes(vaultKey!, row.metadataIv, row.metadataCiphertext);
        const metadata = JSON.parse(new TextDecoder().decode(clear)) as MediaRecord;
        if (metadata.id !== row.id) throw new Error('Um registro de mídia local está inconsistente.');
        mediaMetadata[row.id] = { size: metadata.size, hash: metadata.hash, originalIv: metadata.originalIv, thumbIv: metadata.thumbIv };
      }
      for (const store of ['originals', 'thumbnails']) {
        const tx = db.transaction(store, 'readonly');
        const entries = await new Promise<[IDBValidKey, Blob][]>((resolve, reject) => {
          const request = tx.objectStore(store).openCursor();
          const rows: [IDBValidKey, Blob][] = [];
          request.onsuccess = () => { const cursor = request.result; if (!cursor) return resolve(rows); rows.push([cursor.key, cursor.value as Blob]); cursor.continue(); };
          request.onerror = () => reject(request.error);
        });
        for (const [id, blob] of entries) {
          const mediaId = String(id);
          const metadata = mediaMetadata[mediaId];
          if (!metadata) throw new Error('O armazenamento tem arquivos sem metadados no cofre.');
          if (store === 'originals') {
            const clear = await decryptBytes(vaultKey!, metadata.originalIv, await blob.arrayBuffer());
            if (clear.byteLength !== metadata.size || await sha256(asBuffer(clear)) !== metadata.hash) throw new Error('Uma mídia local não passou pela verificação de integridade.');
          } else {
            await decryptBytes(vaultKey!, metadata.thumbIv, await blob.arrayBuffer());
          }
          blobs[`${store}:${mediaId}`] = await blobToBase64(blob);
        }
      }
      const packageData = { format: 'vault-of-us-backup', version: 1, createdAt: new Date().toISOString(), data, blobs, mediaMetadata };
      const backupPassphrase = await requestSecureInput('Cifrar backup', 'Crie uma senha exclusiva para proteger este arquivo. Você precisará dela para restaurá-lo.', 'Senha do backup (mínimo 12 caracteres)', 12);
      if (!backupPassphrase) return;
      if (backupPassphrase.length < 12) throw new Error('A senha do backup precisa ter pelo menos 12 caracteres.');
      const backupKeyBytes = crypto.getRandomValues(new Uint8Array(32));
      const backupKey = await crypto.subtle.importKey('raw', backupKeyBytes, 'AES-GCM', false, ['encrypt']);
      const salt = crypto.getRandomValues(new Uint8Array(16));
      const wrapMaterial = await crypto.subtle.importKey('raw', new TextEncoder().encode(backupPassphrase), 'PBKDF2', false, ['deriveKey']);
      const wrapKey = await crypto.subtle.deriveKey({ name: 'PBKDF2', salt, iterations: 600_000, hash: 'SHA-256' }, wrapMaterial, { name: 'AES-GCM', length: 256 }, false, ['encrypt']);
      const wrapIv = crypto.getRandomValues(new Uint8Array(12));
      const wrappedKey = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: wrapIv }, wrapKey, backupKeyBytes);
      backupKeyBytes.fill(0);
      const payloadIv = crypto.getRandomValues(new Uint8Array(12));
      const payload = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: payloadIv }, backupKey, new TextEncoder().encode(JSON.stringify(packageData, typedArrayJsonReplacer)));
      const envelope = { format: 'vault-of-us-encrypted-backup', version: 1, salt: toBase64(salt), wrapIv: toBase64(wrapIv), wrappedKey: toBase64(new Uint8Array(wrappedKey)), payloadIv: toBase64(payloadIv), payload: toBase64(new Uint8Array(payload)) };
      const file = new Blob([JSON.stringify(envelope, typedArrayJsonReplacer)], { type: 'application/vnd.vault-of-us.backup+json' });
      downloadBlob(file, `vault-of-us-backup-${new Date().toISOString().slice(0, 10)}.voub`);
      showToast('Backup exportado. Guarde o arquivo em um local seguro.');
    } catch (error) { showToast(error instanceof Error ? error.message : 'Não foi possível exportar o backup.'); }
  });
  panel.querySelector<HTMLInputElement>('#backup-input')?.addEventListener('change', async (event) => {
    const file = (event.currentTarget as HTMLInputElement).files?.[0];
    if (!file) return;
    try {
      if (file.size > 2 * 1024 * 1024 * 1024) throw new Error('O arquivo de backup excede o limite de 2 GB.');
      const envelope = JSON.parse(await file.text()) as { format?: string; version?: number; salt?: string; wrapIv?: string; wrappedKey?: string; payloadIv?: string; payload?: string };
      if (envelope.format !== 'vault-of-us-encrypted-backup' || envelope.version !== 1 || !envelope.salt || !envelope.wrapIv || !envelope.wrappedKey || !envelope.payloadIv || !envelope.payload) throw new Error('Este arquivo não é um backup cifrado compatível.');
      const backupPhrase = await requestSecureInput('Abrir backup', 'Digite a senha exclusiva usada ao exportar este arquivo.', 'Senha do backup', 12);
      if (!backupPhrase) return;
      let packageKey: CryptoKey;
      try {
        const material = await crypto.subtle.importKey('raw', new TextEncoder().encode(backupPhrase), 'PBKDF2', false, ['deriveKey']);
        const wrapping = await crypto.subtle.deriveKey({ name: 'PBKDF2', salt: asBuffer(fromBase64(envelope.salt)), iterations: 600_000, hash: 'SHA-256' }, material, { name: 'AES-GCM', length: 256 }, false, ['decrypt']);
        const raw = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: asBuffer(fromBase64(envelope.wrapIv)) }, wrapping, asBuffer(fromBase64(envelope.wrappedKey)));
        packageKey = await crypto.subtle.importKey('raw', raw, 'AES-GCM', false, ['decrypt']);
      } catch { throw new Error('Senha do arquivo de backup incorreta.'); }
      let parsed: { format?: string; version?: number; data?: Record<string, unknown[]>; blobs?: Record<string, string>; mediaMetadata?: Record<string, { size: number; hash: string; originalIv: string; thumbIv: string }> };
      try { parsed = JSON.parse(new TextDecoder().decode(await crypto.subtle.decrypt({ name: 'AES-GCM', iv: asBuffer(fromBase64(envelope.payloadIv)) }, packageKey, asBuffer(fromBase64(envelope.payload)))), typedArrayJsonReviver) as typeof parsed; }
      catch { throw new Error('Não foi possível abrir este backup. Confira a senha.'); }
      if (parsed.format !== 'vault-of-us-backup' || parsed.version !== 1 || !parsed.data || !parsed.blobs || !parsed.mediaMetadata) throw new Error('Este arquivo não é um backup compatível.');
      const backupSettings = (parsed.data.settings ?? []).find((item) => (item as { id?: string }).id === 'vault') as import('./db').VaultSettings | undefined;
      if (!backupSettings) throw new Error('O backup não contém as configurações do cofre.');
      const phrase = await requestSecureInput('Confirmar cofre', 'Digite a senha do cofre que estava ativa quando o backup foi criado.', 'Senha do cofre', 12);
      if (!phrase) return;
      let verifiedKey: CryptoKey;
      try { verifiedKey = await unlockVault(phrase, backupSettings); }
      catch { throw new Error('Senha do cofre incorreta.'); }
      const mediaRows = (parsed.data.media ?? []) as { id: string; metadataIv: string; metadataCiphertext: Uint8Array }[];
      if (Object.keys(parsed.mediaMetadata).length !== mediaRows.length) throw new Error('O backup contém um índice de integridade inconsistente.');
      for (const row of mediaRows) {
        const metadata = JSON.parse(new TextDecoder().decode(await decryptBytes(verifiedKey, row.metadataIv, row.metadataCiphertext))) as MediaRecord;
        if (metadata.id !== row.id) throw new Error('O backup contém um registro de mídia inconsistente.');
        const originalEncoded = parsed.blobs[`originals:${row.id}`];
        const thumbnailEncoded = parsed.blobs[`thumbnails:${row.id}`];
        if (!originalEncoded || !thumbnailEncoded) throw new Error('O backup não contém todos os arquivos do cofre.');
        const original = await decryptBytes(verifiedKey, metadata.originalIv, await base64ToBlob(originalEncoded).arrayBuffer());
        const integrity = parsed.mediaMetadata[row.id];
        if (!integrity || metadata.size !== integrity.size || metadata.hash !== integrity.hash || metadata.originalIv !== integrity.originalIv || metadata.thumbIv !== integrity.thumbIv || original.byteLength !== integrity.size || await sha256(asBuffer(original)) !== integrity.hash) throw new Error('Uma mídia do backup não passou pela verificação de integridade.');
        await decryptBytes(verifiedKey, metadata.thumbIv, await base64ToBlob(thumbnailEncoded).arrayBuffer());
      }
      const expectedBlobKeys = new Set(mediaRows.flatMap((row) => [`originals:${row.id}`, `thumbnails:${row.id}`]));
      if (Object.keys(parsed.blobs).length !== expectedBlobKeys.size || Object.keys(parsed.blobs).some((name) => !expectedBlobKeys.has(name))) throw new Error('O backup contém arquivos extras ou ausentes.');
      for (const row of (parsed.data.albums ?? []) as { id: string; iv: string; ciphertext: Uint8Array }[]) {
        const album = JSON.parse(new TextDecoder().decode(await decryptBytes(verifiedKey, row.iv, row.ciphertext))) as { id?: string };
        if (album.id !== row.id) throw new Error('O backup contém um álbum inconsistente.');
      }
      for (const row of (parsed.data.local_messages ?? []) as { id: string; iv: string; ciphertext: Uint8Array }[]) await decryptBytes(verifiedKey, row.iv, row.ciphertext);
      const existing = await settingsExist();
      if (existing && !confirm('Restaurar substituirá os dados locais deste cofre. Exporte um backup atual antes de continuar.')) return;
      const pairSecretRow = (parsed.data.local_messages ?? []).find((row) => String((row as { id?: string }).id).startsWith('pair-secret:')) as { id: string; iv: string; ciphertext: Uint8Array } | undefined;
      if (pairSecretRow) {
        try { await decryptBytes(verifiedKey, pairSecretRow.iv, pairSecretRow.ciphertext); }
        catch { throw new Error('Este backup tem conteúdo local vinculado a outro cofre.'); }
      }
      const db = await openDb();
      const names = ['settings', 'media', 'albums', 'local_messages', 'preferences', 'originals', 'thumbnails'];
      const tx = db.transaction(names, 'readwrite');
      for (const name of names) tx.objectStore(name).clear();
      for (const [store, records] of Object.entries(parsed.data)) {
        if (!names.includes(store) || !Array.isArray(records)) continue;
        for (const record of records) tx.objectStore(store).put(record);
      }
      for (const [compoundKey, base64] of Object.entries(parsed.blobs)) {
        const separator = compoundKey.indexOf(':');
        const store = compoundKey.slice(0, separator);
        const id = compoundKey.slice(separator + 1);
        if (store !== 'originals' && store !== 'thumbnails') continue;
        tx.objectStore(store).put(base64ToBlob(base64), id);
      }
      await new Promise<void>((resolve, reject) => { tx.oncomplete = () => resolve(); tx.onerror = () => reject(tx.error); tx.onabort = () => reject(tx.error); });
      showToast('Backup restaurado. Desbloqueie com a senha usada quando ele foi exportado.');
      vaultKey = undefined;
      mountLock(false);
    } catch (error) { showToast(error instanceof Error ? error.message : 'Não foi possível restaurar o backup.'); }
    (event.currentTarget as HTMLInputElement).value = '';
  });
  panel.querySelector<HTMLButtonElement>('#open-chat-settings')?.addEventListener('click', async () => { page = 'chat'; await renderPage(); });
}

function renderChat(panel: HTMLElement): void {
  void renderChatPage(panel, vaultKey!, showToast);
}

async function renderMemories(panel: HTMLElement, syncState: SyncState | 'syncing' = 'syncing', syncAfterRender = true) {
  const localRows = await getAll<{ id: string; iv: string; ciphertext: Uint8Array }>('local_messages');
  const sealed = localRows.filter((item) => item.id.startsWith('memory:'));
  const sealedComments = localRows.filter((item) => item.id.startsWith('comment:'));
  const saved: { id: string; text: string; date: string; annualYear?: number }[] = [];
  const comments: { id: string; postId: string; text: string; date: string; deletedAt?: string }[] = [];
  for (const item of sealed) {
    const clear = await decryptBytes(vaultKey!, item.iv, item.ciphertext);
    const note = JSON.parse(new TextDecoder().decode(clear)) as { id: string; text: string; date: string; annualYear?: number; deletedAt?: string };
    if (!note.deletedAt) saved.push(note);
  }
  for (const item of sealedComments) {
    const clear = await decryptBytes(vaultKey!, item.iv, item.ciphertext);
    const comment = JSON.parse(new TextDecoder().decode(clear)) as { id: string; postId: string; text: string; date: string; deletedAt?: string };
    if (!comment.deletedAt) comments.push(comment);
  }
  const media = await listMedia(vaultKey!, 'all');
  const now = new Date();
  const sameDay = media.filter((item) => { if (!item.takenAt) return false; const date = new Date(item.takenAt); return date.getMonth() === now.getMonth() && date.getDate() === now.getDate() && date.getFullYear() < now.getFullYear(); });
  const years = [...new Set([...media.flatMap((item) => item.takenAt ? [new Date(item.takenAt).getFullYear()] : []), ...saved.map((item) => new Date(item.date).getFullYear())])].sort((a,b) => b-a);
  const chosenYear = Number(panel.querySelector<HTMLSelectElement>('#journal-year')?.value || years[0] || now.getFullYear());
  const annualMedia = media.filter((item) => (item.takenAt ? new Date(item.takenAt).getFullYear() : new Date(item.createdAt).getFullYear()) === chosenYear);
  const annualNotes = saved.filter((item) => new Date(item.date).getFullYear() === chosenYear);
  const annualReview = saved.find((item) => item.annualYear === chosenYear || item.text.startsWith(`Retrospectiva ${chosenYear}:`));
  const personalNotes = annualNotes.filter((item) => item.id !== annualReview?.id);
  const commentsFor = (postId: string) => comments.filter((comment) => comment.postId === postId).sort((a, b) => a.date.localeCompare(b.date));
  panel.innerHTML = `<div class="section-heading"><div><p class="eyebrow">PEQUENOS REGISTROS</p><h2>Memórias</h2><p class="muted">Linha do tempo local; lembranças são cifradas e sincronizadas após parear no Chat.</p><p class="small" id="memories-sync-status">${syncMessage(syncState)}</p></div><button class="text-button" id="sync-memories">Sincronizar</button></div>
    <section class="memory-feature"><div><p class="eyebrow">NESSE DIA</p><h3>${sameDay.length ? `Hoje, em outros anos` : 'Uma data para lembrar'}</h3><p>${sameDay.length ? `${sameDay.length} ${sameDay.length === 1 ? 'momento guardado' : 'momentos guardados'} nesta data.` : 'Importe fotos com a data original para encontrar momentos de anos anteriores.'}</p></div><div class="memory-strip" id="same-day-strip">${sameDay.length ? sameDay.map((item) => `<button class="memory-thumb" data-memory-media="${item.id}" aria-label="Abrir ${escapeHtml(item.name)}"><span id="day-preview-${item.id}">${item.type.startsWith('video/') ? '▶' : '✧'}</span><small>${new Date(item.takenAt!).getFullYear()}</small></button>`).join('') : ''}</div></section>
    <section class="annual-journal"><div class="annual-heading"><div><p class="eyebrow">JOURNAL ANUAL</p><h3>${chosenYear}: coisas que ficaram</h3></div><select id="journal-year" aria-label="Ano da retrospectiva">${[...new Set([now.getFullYear(), ...years])].map((year) => `<option value="${year}" ${year === chosenYear ? 'selected' : ''}>${year}</option>`).join('')}</select></div><p class="muted">${annualMedia.length} mídias e ${personalNotes.length} lembranças guardadas neste ano.</p><button class="secondary" id="save-annual-review">${annualReview ? 'Atualizar retrospectiva cifrada' : 'Criar retrospectiva cifrada'}</button></section>
    <form id="memory-form" class="note-form"><textarea name="text" maxlength="1500" rows="4" placeholder="O que você quer guardar?" required></textarea><button class="primary" type="submit">Guardar lembrança</button></form>
    <div class="timeline-grid">${[...annualMedia.map((item) => ({ type: 'media' as const, at: item.takenAt || item.createdAt, item })), ...annualNotes.map((item) => ({ type: 'note' as const, at: item.date, item }))].sort((a,b) => b.at.localeCompare(a.at)).map((entry) => entry.type === 'media' ? `<button class="timeline-media" data-timeline-media="${entry.item.id}"><span class="timeline-date">${new Date(entry.at).toLocaleDateString('pt-BR')}</span><span class="timeline-name">${escapeHtml(entry.item.name)}</span><span class="timeline-meta">${entry.item.type.startsWith('video/') ? 'Vídeo' : 'Foto'} · ${formatSize(entry.item.size)}</span></button>` : `<article class="note-card timeline-note"><time>${new Date(entry.at).toLocaleDateString('pt-BR')}</time><p>${escapeHtml(entry.item.text)}</p><button class="text-button" data-delete-memory="${escapeHtml(entry.item.id)}">Apagar</button><div class="memory-comments">${commentsFor(entry.item.id).map((comment) => `<p class="memory-comment">${escapeHtml(comment.text)} <time>${new Date(comment.date).toLocaleDateString('pt-BR')}</time></p>`).join('')}<form class="comment-form" data-comment-for="${escapeHtml(entry.item.id)}"><input name="comment" maxlength="500" placeholder="Comentar esta lembrança…" required/><button class="text-button" type="submit">Comentar</button></form></div></article>`).join('') || '<div class="empty-inline">Ainda não há registros neste ano.</div>'}</div>`;
  for (const item of sameDay) {
    const previewUrl = await thumbnailUrl(item, vaultKey!);
    const preview = panel.querySelector<HTMLElement>(`#day-preview-${CSS.escape(item.id)}`);
    if (previewUrl && preview) { urls.push(previewUrl); preview.innerHTML = `<img src="${previewUrl}" alt=""/>`; }
  }
  panel.querySelector<HTMLFormElement>('#memory-form')?.addEventListener('submit', async (event) => {
    event.preventDefault();
    const form = new FormData(event.currentTarget as HTMLFormElement);
    const text = String(form.get('text') ?? '').trim();
    if (!text) return;
    const date = new Date().toISOString();
    const entry = { id: crypto.randomUUID(), text, date, updatedAt: date };
    const encrypted = await encryptBytes(vaultKey!, new TextEncoder().encode(JSON.stringify(entry)));
    await putRecord('local_messages', { id: `memory:${entry.id}`, iv: encrypted.iv, ciphertext: encrypted.ciphertext });
    await renderMemories(panel);
  });
  panel.querySelectorAll<HTMLFormElement>('.comment-form').forEach((form) => form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const text = String(new FormData(form).get('comment') ?? '').trim();
    const postId = form.dataset.commentFor;
    if (!text || !postId || text.length > 500) return;
    const date = new Date().toISOString();
    const comment = { id: crypto.randomUUID(), postId, text, date, updatedAt: date };
    const encrypted = await encryptBytes(vaultKey!, new TextEncoder().encode(JSON.stringify(comment)));
    await putRecord('local_messages', { id: `comment:${comment.id}`, iv: encrypted.iv, ciphertext: encrypted.ciphertext });
    await renderMemories(panel);
  }));
  panel.querySelector<HTMLSelectElement>('#journal-year')?.addEventListener('change', () => void renderMemories(panel));
  panel.querySelector<HTMLButtonElement>('#sync-memories')?.addEventListener('click', () => runSharedSync(panel, 'memories-sync-status', () => renderMemories(panel, 'synced', false), () => Boolean(panel.querySelector<HTMLTextAreaElement>('#memory-form textarea')?.value)));
  if (syncAfterRender) runSharedSync(panel, 'memories-sync-status', () => renderMemories(panel, 'synced', false), () => Boolean(panel.querySelector<HTMLTextAreaElement>('#memory-form textarea')?.value));
  panel.querySelectorAll<HTMLButtonElement>('[data-memory-media],[data-timeline-media]').forEach((button) => button.addEventListener('click', async () => {
    const record = media.find((item) => item.id === button.dataset.memoryMedia || item.id === button.dataset.timelineMedia);
    if (!record) return;
    const url = URL.createObjectURL(await originalBlob(record, vaultKey!)); urls.push(url); openMedia(record, url);
  }));
  panel.querySelector<HTMLButtonElement>('#save-annual-review')?.addEventListener('click', async () => {
    const updatedAt = new Date().toISOString();
    const date = new Date(chosenYear, 11, 31, 12).toISOString();
    const noteHighlights = [...personalNotes].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 8)
      .map((item) => `• ${new Date(item.date).toLocaleDateString('pt-BR')} — ${item.text.replace(/\s+/g, ' ').slice(0, 220)}`);
    const mediaHighlights = [...annualMedia].sort((a, b) => (b.takenAt || b.createdAt).localeCompare(a.takenAt || a.createdAt)).slice(0, 8)
      .map((item) => `• ${new Date(item.takenAt || item.createdAt).toLocaleDateString('pt-BR')} — ${item.name}`);
    const text = [`Retrospectiva ${chosenYear}`, `${annualMedia.length} mídias e ${personalNotes.length} lembranças guardadas neste aparelho.`, '', 'Lembranças', ...(noteHighlights.length ? noteHighlights : ['• Nenhuma lembrança escrita neste ano.']), '', 'Mídias', ...(mediaHighlights.length ? mediaHighlights : ['• Nenhuma mídia guardada neste ano.'])].join('\n');
    const note = { id: annualReview?.id ?? `annual-review:${chosenYear}`, text, date, updatedAt, annualYear: chosenYear };
    const encrypted = await encryptBytes(vaultKey!, new TextEncoder().encode(JSON.stringify(note)));
    await putRecord('local_messages', { id: `memory:${note.id}`, iv: encrypted.iv, ciphertext: encrypted.ciphertext });
    await renderMemories(panel); showToast('Retrospectiva cifrada atualizada no Journal.');
  });
  panel.querySelectorAll<HTMLButtonElement>('[data-delete-memory]').forEach((button) => button.addEventListener('click', async () => {
    if (!confirm('Apagar esta lembrança dos aparelhos pareados?')) return;
    const rowId = `memory:${button.dataset.deleteMemory!}`;
    const row = await getRecord<{ id: string; iv: string; ciphertext: Uint8Array }>('local_messages', rowId);
    if (!row) return;
    const note = JSON.parse(new TextDecoder().decode(await decryptBytes(vaultKey!, row.iv, row.ciphertext))) as { id: string; text: string; date: string; updatedAt?: string; deletedAt?: string };
    note.deletedAt = new Date().toISOString(); note.updatedAt = note.deletedAt;
    const encrypted = await encryptBytes(vaultKey!, new TextEncoder().encode(JSON.stringify(note)));
    await putRecord('local_messages', { id: rowId, iv: encrypted.iv, ciphertext: encrypted.ciphertext });
    await renderMemories(panel);
  }));
}

function renderTogether(panel: HTMLElement): void {
  void renderTogetherPage(panel);
}

interface TogetherItem { id: string; kind: 'list' | 'date' | 'goal' | 'capsule'; title: string; body: string; date?: string; recurring?: boolean; complete?: boolean; unlockAt?: string; checkItems?: { id: string; text: string; checked: boolean }[]; createdAt: string; updatedAt?: string; deletedAt?: string }

async function renderTogetherPage(panel: HTMLElement, syncState: SyncState | 'syncing' = 'syncing', syncAfterRender = true) {
  const key = vaultKey;
  if (!key) return;
  const sealed = (await getAll<{ id: string; iv: string; ciphertext: Uint8Array }>('local_messages')).filter((item) => item.id.startsWith('together:'));
  const items: TogetherItem[] = [];
  for (const item of sealed) {
    const decoded = JSON.parse(new TextDecoder().decode(await decryptBytes(key, item.iv, item.ciphertext))) as TogetherItem;
    if (!decoded.deletedAt) items.push(decoded);
  }
  const ordered = items.sort((a,b) => (a.date || a.unlockAt || a.createdAt).localeCompare(b.date || b.unlockAt || b.createdAt));
  if (capsuleTimer !== undefined) window.clearTimeout(capsuleTimer);
  const nextCapsuleUnlock = items.map((item) => item.unlockAt ? Date.parse(item.unlockAt) : Infinity).filter((time) => time > Date.now()).sort((a,b) => a-b)[0];
  if (nextCapsuleUnlock !== undefined) capsuleTimer = window.setTimeout(() => { if (page === 'together' && panel.isConnected) void renderTogetherPage(panel); }, Math.min(nextCapsuleUnlock - Date.now() + 50, 2_147_000_000));
  const itemMarkup = (item: TogetherItem): string => {
    const locked = item.kind === 'capsule' && Boolean(item.unlockAt) && Date.now() < Date.parse(item.unlockAt!);
    const dateLabel = item.date ? new Date(`${item.date}T12:00:00`).toLocaleDateString('pt-BR') : '';
    let content = '';
    if (item.kind === 'list') content = `<div class="check-list">${(item.checkItems ?? []).map((check) => `<label class="check-row"><input type="checkbox" data-check-item="${item.id}" data-check-id="${check.id}" ${check.checked ? 'checked' : ''}/><span class="${check.checked ? 'checked-text' : ''}">${escapeHtml(check.text)}</span></label>`).join('')}</div>`;
    else if (item.kind === 'goal') content = `<p class="muted">${item.complete ? 'Meta concluída ✓' : 'Meta em andamento'}${dateLabel ? ` · até ${dateLabel}` : ''}</p><button class="secondary" data-toggle-goal="${item.id}">${item.complete ? 'Reabrir meta' : 'Marcar como concluída'}</button>`;
    else if (item.kind === 'date') content = `<p class="muted">${dateLabel}${item.recurring ? ' · repete todo ano' : ''}</p>`;
    else content = locked ? `<p class="muted">🔒 Esta cápsula abre em ${new Date(item.unlockAt!).toLocaleString('pt-BR')}.</p>` : `<p>${escapeHtml(item.body)}</p><p class="small">Cápsula aberta em ${item.unlockAt ? new Date(item.unlockAt).toLocaleString('pt-BR') : 'data definida'}.</p>`;
    return `<article class="note-card together-item"><div><span class="item-kind">${kindLabel(item.kind)}</span>${dateLabel && item.kind !== 'goal' ? `<time>${dateLabel}</time>` : ''}</div><h3>${escapeHtml(item.title)}</h3>${content}<button class="text-button" data-remove-together="${item.id}">Apagar</button></article>`;
  };
  panel.innerHTML = `<div class="section-heading"><div><p class="eyebrow">PLANOS, LEMBRETES, ROTINA</p><h2>A dois</h2><p class="muted">Listas, metas e datas cifradas antes da sincronização.</p><p class="small" id="together-sync-status">${syncMessage(syncState)}</p></div><button class="text-button" id="sync-together">Sincronizar</button></div>
    <div class="together-grid"><form id="together-form" class="settings-card stack"><p class="eyebrow">GUARDAR UM PLANO</p><label for="together-kind">Tipo</label><select id="together-kind" name="kind"><option value="list">Lista de compras</option><option value="goal">Meta</option><option value="date">Data especial</option><option value="capsule">Cápsula do tempo</option></select><label for="together-title">Título</label><input id="together-title" name="title" maxlength="90" required placeholder="Ex.: Nossa viagem"/><label for="together-body">Itens ou detalhes</label><textarea id="together-body" name="body" rows="4" maxlength="2000" placeholder="Lista: um item por linha"></textarea><label for="together-date">Data (opcional)</label><input id="together-date" name="date" type="date"/><label id="recurring-label" class="check-row"><input type="checkbox" name="recurring"/><span>Repetir data todo ano</span></label><label for="capsule-unlock">Abrir cápsula em</label><input id="capsule-unlock" name="unlockAt" type="datetime-local"/><button class="primary" type="submit">Guardar e compartilhar</button></form><div class="together-list">${ordered.length ? ordered.map(itemMarkup).join('') : '<div class="empty-inline">Listas, datas, metas e cápsulas aparecerão aqui.</div>'}</div></div>`;
  panel.querySelector<HTMLButtonElement>('#sync-together')?.addEventListener('click', () => runSharedSync(panel, 'together-sync-status', () => renderTogetherPage(panel, 'synced', false), () => Boolean(panel.querySelector<HTMLInputElement>('#together-title')?.value || panel.querySelector<HTMLTextAreaElement>('#together-body')?.value || panel.querySelector<HTMLInputElement>('#together-date')?.value || panel.querySelector<HTMLInputElement>('#capsule-unlock')?.value)));
  if (syncAfterRender) runSharedSync(panel, 'together-sync-status', () => renderTogetherPage(panel, 'synced', false), () => Boolean(panel.querySelector<HTMLInputElement>('#together-title')?.value || panel.querySelector<HTMLTextAreaElement>('#together-body')?.value || panel.querySelector<HTMLInputElement>('#together-date')?.value || panel.querySelector<HTMLInputElement>('#capsule-unlock')?.value));
  const kindSelect = panel.querySelector<HTMLSelectElement>('#together-kind')!;
  const syncKindFields = () => {
    const kind = kindSelect.value;
    const body = panel.querySelector<HTMLTextAreaElement>('#together-body')!;
    const date = panel.querySelector<HTMLInputElement>('#together-date')!;
    const recurring = panel.querySelector<HTMLElement>('#recurring-label')!;
    const unlock = panel.querySelector<HTMLInputElement>('#capsule-unlock')!;
    body.placeholder = kind === 'list' ? 'Um item por linha' : kind === 'capsule' ? 'O conteúdo ficará escondido até a data escolhida' : 'Detalhes ou descrição';
    body.required = kind === 'capsule';
    recurring.hidden = kind !== 'date';
    date.required = kind === 'goal' || kind === 'date';
    date.hidden = kind === 'capsule';
    unlock.hidden = kind !== 'capsule';
    unlock.required = kind === 'capsule';
  };
  kindSelect.addEventListener('change', syncKindFields); syncKindFields();
  panel.querySelector<HTMLFormElement>('#together-form')?.addEventListener('submit', async (event) => {
    event.preventDefault(); const form = new FormData(event.currentTarget as HTMLFormElement);
    const kind = String(form.get('kind')) as TogetherItem['kind'];
    const body = String(form.get('body') ?? '').trim();
    const now = new Date().toISOString();
    const item: TogetherItem = { id: crypto.randomUUID(), kind, title: String(form.get('title') ?? '').trim(), body: kind === 'list' ? '' : body, date: String(form.get('date') ?? '') || undefined, recurring: form.get('recurring') === 'on', unlockAt: String(form.get('unlockAt') ?? '') ? new Date(String(form.get('unlockAt'))).toISOString() : undefined, checkItems: kind === 'list' ? body.split(/\r?\n/).map((text) => text.trim()).filter(Boolean).map((text) => ({ id: crypto.randomUUID(), text, checked: false })) : undefined, createdAt: now, updatedAt: now };
    if (kind === 'list' && !item.checkItems?.length) return showToast('Adicione ao menos um item à lista.');
    if (kind === 'capsule' && (!item.unlockAt || Date.parse(item.unlockAt) <= Date.now())) return showToast('Escolha uma data futura para abrir a cápsula.');
    const enc = await encryptBytes(key, new TextEncoder().encode(JSON.stringify(item)));
    await putRecord('local_messages', { id: `together:${item.id}`, iv: enc.iv, ciphertext: enc.ciphertext });
    await renderTogetherPage(panel);
  });
  panel.querySelectorAll<HTMLInputElement>('[data-check-item]').forEach((checkbox) => checkbox.addEventListener('change', async () => {
    const item = items.find((row) => row.id === checkbox.dataset.checkItem); const check = item?.checkItems?.find((row) => row.id === checkbox.dataset.checkId); if (!item || !check) return; check.checked = checkbox.checked; await saveTogetherItem(item, key); await renderTogetherPage(panel);
  }));
  panel.querySelectorAll<HTMLButtonElement>('[data-toggle-goal]').forEach((button) => button.addEventListener('click', async () => { const item = items.find((row) => row.id === button.dataset.toggleGoal); if (item) { item.complete = !item.complete; await saveTogetherItem(item, key); await renderTogetherPage(panel); } }));
  panel.querySelectorAll<HTMLButtonElement>('[data-remove-together]').forEach((button) => button.addEventListener('click', async () => { if (!confirm('Apagar este registro dos aparelhos pareados?')) return; const item = items.find((row) => row.id === button.dataset.removeTogether); if (!item) return; item.deletedAt = new Date().toISOString(); await saveTogetherItem(item, key); await renderTogetherPage(panel); }));
}

async function saveTogetherItem(item: TogetherItem, key: CryptoKey): Promise<void> { item.updatedAt = new Date().toISOString(); const enc = await encryptBytes(key, new TextEncoder().encode(JSON.stringify(item))); await putRecord('local_messages', { id: `together:${item.id}`, iv: enc.iv, ciphertext: enc.ciphertext }); }
function syncMessage(state: SyncState | 'syncing'): string { return state === 'synced' ? 'Registros compartilhados cifrados e sincronizados com o aparelho pareado.' : state === 'offline' ? 'Sem conexão com o serviço agora; as alterações locais estão guardadas para sincronizar depois.' : state === 'syncing' ? 'Dados locais carregados; sincronização em segundo plano.' : 'Os registros ficam locais até configurar o chat e parear os aparelhos.'; }
function runSharedSync(panel: HTMLElement, statusId: string, refresh: () => Promise<void>, hasDraft: () => boolean): void { const status = panel.querySelector<HTMLElement>(`#${statusId}`); if (!status || !vaultKey) return; status.textContent = syncMessage('syncing'); void syncSharedRecords(vaultKey).then(async (state) => { if (!panel.isConnected || !vaultKey) return; const currentStatus = panel.querySelector<HTMLElement>(`#${statusId}`); if (state === 'synced' && !hasDraft()) { await refresh(); return; } if (currentStatus) currentStatus.textContent = syncMessage(state); }); }
function kindLabel(kind: TogetherItem['kind']): string { return ({ list: 'LISTA DE COMPRAS', date: 'DATA ESPECIAL', goal: 'META', capsule: 'CÁPSULA DO TEMPO' })[kind]; }
function blobToBase64(blob: Blob): Promise<string> { return new Promise((resolve, reject) => { const reader = new FileReader(); reader.onload = () => resolve(String(reader.result).split(',')[1] || ''); reader.onerror = () => reject(reader.error); reader.readAsDataURL(blob); }); }
function base64ToBlob(value: string): Blob { const binary = atob(value); const bytes = new Uint8Array(binary.length); for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i); return new Blob([bytes], { type: 'application/octet-stream' }); }
function toBase64(bytes: Uint8Array): string { let binary = ''; for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, Math.min(i + 0x8000, bytes.length))); return btoa(binary); }
function fromBase64(value: string): Uint8Array { return Uint8Array.from(atob(value), (character) => character.charCodeAt(0)); }
function asBuffer(value: Uint8Array): ArrayBuffer { return new Uint8Array(value).buffer as ArrayBuffer; }
function typedArrayJsonReplacer(_key: string, value: unknown): unknown { return value instanceof Uint8Array ? { __vaultBytes: toBase64(value) } : value; }
function typedArrayJsonReviver(_key: string, value: unknown): unknown { return value && typeof value === 'object' && '__vaultBytes' in value ? fromBase64(String((value as { __vaultBytes: string }).__vaultBytes)) : value; }
function downloadBlob(blob: Blob, name: string): void { const url = URL.createObjectURL(blob); const anchor = document.createElement('a'); anchor.href = url; anchor.download = name; anchor.click(); window.setTimeout(() => URL.revokeObjectURL(url), 1000); }

function openMedia(record: MediaRecord, url: string): void {
  const dialog = document.createElement('dialog');
  dialog.className = 'media-dialog';
  const element = record.type.startsWith('video/')
    ? `<video class="viewer-media" src="${url}" controls playsinline></video>`
    : record.type.startsWith('audio/')
      ? `<audio class="viewer-audio" src="${url}" controls></audio>`
      : `<img class="viewer-media zoomable-media" src="${url}" alt="${escapeHtml(record.name)}" />`;
  const details = [record.type || 'Tipo desconhecido', formatSize(record.size), record.width && record.height ? `${record.width} × ${record.height} px` : '', record.takenAt ? `Capturada em ${new Date(record.takenAt).toLocaleString('pt-BR')}` : 'Data de captura não encontrada nos metadados'].filter(Boolean).join(' · ');
  dialog.innerHTML = `<button class="dialog-close" aria-label="Fechar">×</button><div class="viewer-toolbar">${record.type.startsWith('image/') ? '<button data-zoom="out" aria-label="Diminuir zoom">−</button><button data-zoom="reset" aria-label="Redefinir zoom">100%</button><button data-zoom="in" aria-label="Aumentar zoom">＋</button>' : ''}<button id="toggle-media-details" class="text-button">Detalhes</button></div><div class="viewer-stage">${element}</div><p class="viewer-name">${escapeHtml(record.name)}</p><p class="viewer-details" hidden>${escapeHtml(details)}</p>`;
  document.body.append(dialog);
  dialog.showModal();
  dialog.querySelector('button')?.addEventListener('click', () => dialog.close());
  dialog.querySelector<HTMLButtonElement>('#toggle-media-details')?.addEventListener('click', () => { const info = dialog.querySelector<HTMLElement>('.viewer-details'); if (info) info.hidden = !info.hidden; });
  const image = dialog.querySelector<HTMLImageElement>('.zoomable-media');
  if (image) {
    let scale = 1;
    const points = new Map<number, PointerEvent>();
    let pinchStart = 0;
    let scaleStart = 1;
    const setScale = (next: number) => { scale = Math.max(1, Math.min(5, next)); image.style.transform = `scale(${scale})`; const label = dialog.querySelector<HTMLButtonElement>('[data-zoom="reset"]'); if (label) label.textContent = `${Math.round(scale * 100)}%`; };
    dialog.querySelector('[data-zoom="in"]')?.addEventListener('click', () => setScale(scale + 0.25));
    dialog.querySelector('[data-zoom="out"]')?.addEventListener('click', () => setScale(scale - 0.25));
    dialog.querySelector('[data-zoom="reset"]')?.addEventListener('click', () => setScale(1));
    image.addEventListener('dblclick', () => setScale(scale === 1 ? 2 : 1));
    image.addEventListener('wheel', (event) => { event.preventDefault(); setScale(scale + (event.deltaY < 0 ? 0.15 : -0.15)); }, { passive: false });
    image.addEventListener('pointerdown', (event) => { points.set(event.pointerId, event); if (points.size === 2) { const [a, b] = [...points.values()]; pinchStart = Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY); scaleStart = scale; } });
    image.addEventListener('pointermove', (event) => { if (!points.has(event.pointerId)) return; points.set(event.pointerId, event); if (points.size === 2 && pinchStart) { const [a, b] = [...points.values()]; setScale(scaleStart * Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY) / pinchStart); event.preventDefault(); } });
    const release = (event: PointerEvent) => { points.delete(event.pointerId); if (points.size < 2) pinchStart = 0; };
    image.addEventListener('pointerup', release); image.addEventListener('pointercancel', release);
  }
  dialog.addEventListener('close', () => dialog.remove());
}

function showToast(message: string): void {
  document.querySelector('.toast')?.remove();
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.textContent = message;
  document.body.append(toast);
  window.setTimeout(() => toast.remove(), 4600);
}

async function start(): Promise<void> {
  if ('serviceWorker' in navigator && window.isSecureContext) {
    navigator.serviceWorker.register('/sw.js').catch(() => undefined);
  }
  try {
    await openDb();
    const configured = await settingsExist();
    mountLock(!configured);
  } catch {
    root.innerHTML = '<main class="lock-page"><div class="lock-card"><h1>Armazenamento indisponível</h1><p>Abra esta PWA no Safari com conexão segura (HTTPS) e tente novamente.</p></div></main>';
  }
  document.addEventListener('visibilitychange', () => {
    if (!vaultKey) return;
    if (document.visibilityState === 'hidden') {
      backgroundAt = Date.now();
      if (lockTimer !== undefined) window.clearTimeout(lockTimer);
      if (lockTimeoutMs === 0) mountLock(false);
      else lockTimer = window.setTimeout(() => mountLock(false), lockTimeoutMs);
    } else if (backgroundAt !== undefined) {
      if (lockTimer !== undefined) window.clearTimeout(lockTimer);
      lockTimer = undefined;
      if (Date.now() - backgroundAt >= lockTimeoutMs) mountLock(false);
      backgroundAt = undefined;
    }
  });
  // Prevent iOS Safari pinch-to-zoom (Safari ignores user-scalable=no since iOS 10).
  // The custom pinch-zoom in the media viewer uses pointer events, so this does not interfere.
  document.addEventListener('touchmove', (event) => { if (event.touches.length > 1) event.preventDefault(); }, { passive: false });
  document.addEventListener('gesturestart', (event) => event.preventDefault());
}

void start();
