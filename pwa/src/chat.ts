import type { SupabaseClient, User } from '@supabase/supabase-js';
import { asArrayBuffer, decryptBytes, encryptBytes, randomId } from './crypto';
import { deleteRecord, getRecord, putRecord } from './db';
import { inferMediaType } from './vault';

export interface Couple { id: string; member_one: string; member_two: string | null }
export interface ChatMessage {
  id: string;
  couple_id: string;
  sender_id: string;
  content_ciphertext: string;
  content_iv: string;
  message_type: 'text' | 'image' | 'video' | 'audio';
  object_path: string | null;
  media_type: string | null;
  sent_at: string;
  read_at: string | null;
  expires_at: string;
}

function toBase64(bytes: Uint8Array): string {
  let binary = '';
  for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, Math.min(i + 0x8000, bytes.length)));
  return btoa(binary);
}
function fromBase64(value: string): Uint8Array { return Uint8Array.from(atob(value), (character) => character.charCodeAt(0)); }

export function inviteUrlFromSecret(secret: Uint8Array): string {
  const token = toBase64(secret).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  const link = new URL(location.href);
  link.hash = `pair=${token}`;
  return link.toString();
}

async function deriveChatKey(sharedSecret: Uint8Array, coupleId: string, messageId: string): Promise<CryptoKey> {
  const material = await crypto.subtle.importKey('raw', asArrayBuffer(sharedSecret), 'HKDF', false, ['deriveKey']);
  return crypto.subtle.deriveKey(
    { name: 'HKDF', hash: 'SHA-256', salt: new TextEncoder().encode(coupleId), info: new TextEncoder().encode(`vault-of-us-chat:${messageId}`) },
    material,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt'],
  );
}

async function cachePairSecret(coupleId: string, secret: Uint8Array, vaultKey: CryptoKey): Promise<void> {
  const sealed = await encryptBytes(vaultKey, secret);
  await putRecord('local_messages', { id: `pair-secret:${coupleId}`, iv: sealed.iv, ciphertext: sealed.ciphertext });
}

export async function removeLocalPairSecret(coupleId: string): Promise<void> {
  await deleteRecord('local_messages', `pair-secret:${coupleId}`);
}

export async function createInvite(client: SupabaseClient, vaultKey: CryptoKey): Promise<string> {
  const secret = crypto.getRandomValues(new Uint8Array(32));
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', asArrayBuffer(secret)));
  const tokenHash = [...digest].map((byte) => byte.toString(16).padStart(2, '0')).join('');
  const { data, error } = await client.rpc('create_partner_invite', { invite_token_hash: tokenHash });
  if (error) throw error;
  await cachePairSecret(data as string, secret, vaultKey).catch(() => undefined);
  const wrap = await encryptBytes(vaultKey, secret);
  const { error: saveError } = await client.from('device_secrets').upsert(
    { secret_key: `couple:${data}`, iv: wrap.iv, secret_ciphertext: toBase64(wrap.ciphertext) },
    { onConflict: 'owner_id,secret_key' },
  );
  if (saveError) throw saveError;
  return inviteUrlFromSecret(secret);
}

export async function acceptInvite(client: SupabaseClient, secretText: string, vaultKey: CryptoKey): Promise<string> {
  const normalized = secretText.replaceAll('-', '+').replaceAll('_', '/');
  const padded = normalized + '='.repeat((4 - normalized.length % 4) % 4);
  const secret = fromBase64(padded);
  if (secret.length !== 32) throw new Error('Convite inválido ou incompleto.');
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', asArrayBuffer(secret)));
  const tokenHash = [...digest].map((byte) => byte.toString(16).padStart(2, '0')).join('');
  const { data, error } = await client.rpc('accept_partner_invite', { invite_token_hash: tokenHash });
  if (error) throw error;
  await cachePairSecret(data as string, secret, vaultKey).catch(() => undefined);
  const wrap = await encryptBytes(vaultKey, secret);
  const { error: saveError } = await client.from('device_secrets').upsert(
    { secret_key: `couple:${data}`, iv: wrap.iv, secret_ciphertext: toBase64(wrap.ciphertext) },
    { onConflict: 'owner_id,secret_key' },
  );
  if (saveError) throw saveError;
  history.replaceState(null, '', `${location.pathname}${location.search}`);
  return data as string;
}

export async function currentCouple(client: SupabaseClient, user: User): Promise<Couple | null> {
  const { data, error } = await client.from('couples').select('id,member_one,member_two')
    .or(`member_one.eq.${user.id},member_two.eq.${user.id}`).maybeSingle();
  if (error) throw error;
  return data as Couple | null;
}

export async function loadPairSecret(client: SupabaseClient, coupleId: string, vaultKey: CryptoKey): Promise<Uint8Array | undefined> {
  const localRow = await getRecord<{ id: string; iv: string; ciphertext: Uint8Array }>('local_messages', `pair-secret:${coupleId}`);
  const localSecret = localRow ? await decryptBytes(vaultKey, localRow.iv, localRow.ciphertext) : undefined;
  try {
    const { data, error } = await client.from('device_secrets').select('iv,secret_ciphertext').eq('secret_key', `couple:${coupleId}`).maybeSingle();
    if (error) throw error;
    if (data) {
      const secret = await decryptBytes(vaultKey, data.iv, fromBase64(data.secret_ciphertext));
      await cachePairSecret(coupleId, secret, vaultKey).catch(() => undefined);
      return secret;
    }
    if (localSecret) {
      const wrap = await encryptBytes(vaultKey, localSecret);
      try {
        await client.from('device_secrets').upsert(
          { secret_key: `couple:${coupleId}`, iv: wrap.iv, secret_ciphertext: toBase64(wrap.ciphertext) },
          { onConflict: 'owner_id,secret_key' },
        );
      } catch { /* The encrypted local copy keeps the current device usable while online repair retries later. */ }
      return localSecret;
    }
    return undefined;
  } catch (error) {
    if (localSecret) return localSecret;
    throw error;
  }
}

export async function listMessages(client: SupabaseClient, coupleId: string): Promise<ChatMessage[]> {
  const { data, error } = await client.from('chat_messages').select('*').eq('couple_id', coupleId)
    .gt('expires_at', new Date().toISOString()).order('sent_at', { ascending: false }).limit(100);
  if (error) throw error;
  // Fetch the newest unexpired messages, then render that window chronologically.
  return ((data ?? []) as ChatMessage[]).reverse();
}

async function persistMessage(client: SupabaseClient, coupleId: string, userId: string, sharedSecret: Uint8Array, content: Uint8Array, type: ChatMessage['message_type'], mediaType: string | null): Promise<ChatMessage> {
  const id = randomId();
  const key = await deriveChatKey(sharedSecret, coupleId, id);
  const sealed = await encryptBytes(key, content);
  const row = {
    id,
    couple_id: coupleId,
    sender_id: userId,
    content_ciphertext: toBase64(sealed.ciphertext),
    content_iv: sealed.iv,
    message_type: type,
    object_path: null as string | null,
    media_type: mediaType,
  };
  const { data, error } = await client.from('chat_messages').insert(row).select('*').single();
  if (error) throw error;
  return data as ChatMessage;
}

export async function sendText(client: SupabaseClient, coupleId: string, user: User, secret: Uint8Array, text: string): Promise<ChatMessage> {
  const message = await persistMessage(client, coupleId, user.id, secret, new TextEncoder().encode(text), 'text', null);
  void client.functions.invoke('send-message-push', { body: { message_id: message.id } }).catch(() => undefined);
  return message;
}

export async function sendMedia(client: SupabaseClient, coupleId: string, user: User, secret: Uint8Array, file: File): Promise<ChatMessage> {
  const id = randomId();
  const mediaType = inferMediaType(file);
  const key = await deriveChatKey(secret, coupleId, id);
  const sealed = await encryptBytes(key, await file.arrayBuffer());
  const path = `${coupleId}/${id}.bin`;
  const { error: uploadError } = await client.storage.from('chat-temp').upload(path, new Blob([asArrayBuffer(sealed.ciphertext)]), {
    contentType: 'application/octet-stream', upsert: false,
  });
  if (uploadError) throw uploadError;
  const { data, error } = await client.from('chat_messages').insert({
    id, couple_id: coupleId, sender_id: user.id,
    content_ciphertext: '', content_iv: sealed.iv,
    message_type: mediaType.startsWith('video/') ? 'video' : mediaType.startsWith('audio/') ? 'audio' : 'image',
    object_path: path, media_type: mediaType,
  }).select('*').single();
  if (error) {
    await client.storage.from('chat-temp').remove([path]);
    throw error;
  }
  const message = data as ChatMessage;
  void client.functions.invoke('send-message-push', { body: { message_id: message.id } }).catch(() => undefined);
  return message;
}

export async function decryptMessage(client: SupabaseClient, coupleId: string, secret: Uint8Array, message: ChatMessage): Promise<Uint8Array> {
  const key = await deriveChatKey(secret, coupleId, message.id);
  if (message.message_type === 'text') return decryptBytes(key, message.content_iv, fromBase64(message.content_ciphertext));
  if (!message.object_path) throw new Error('Arquivo temporário não encontrado.');
  const { data, error } = await client.storage.from('chat-temp').download(message.object_path);
  if (error) throw error;
  return decryptBytes(key, message.content_iv, await data.arrayBuffer());
}

export async function subscribeForPush(client: SupabaseClient, user: User, publicKey: string): Promise<PushSubscription> {
  if (!('serviceWorker' in navigator) || !('PushManager' in window) || typeof Notification === 'undefined') {
    throw new Error('Este iPhone não oferece Web Push para a PWA. Adicione o site à Tela de Início e use iOS 16.4 ou posterior.');
  }
  // Ask before awaiting registration so iOS can associate the permission prompt with the user's tap.
  const permission = await Notification.requestPermission();
  if (permission !== 'granted') throw new Error('A permissão de notificações não foi concedida.');
  const registration = await navigator.serviceWorker.register('/sw.js');
  const current = await registration.pushManager.getSubscription();
  const subscription = current ?? await registration.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: asArrayBuffer(decodeVapidKey(publicKey)) });
  const payload = subscription.toJSON();
  const { error } = await client.from('push_subscriptions').upsert(
    { user_id: user.id, endpoint: payload.endpoint, subscription: payload },
    { onConflict: 'user_id,endpoint' },
  );
  if (error) throw error;
  return subscription;
}

function decodeVapidKey(encoded: string): Uint8Array {
  const raw = atob(encoded.replaceAll('-', '+').replaceAll('_', '/'));
  return Uint8Array.from(raw, (character) => character.charCodeAt(0));
}
