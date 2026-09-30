import type { SupabaseClient } from '@supabase/supabase-js';
import { backendConfigured, supabase } from './backend';
import { currentCouple, loadPairSecret } from './chat';
import { asArrayBuffer, decryptBytes, encryptBytes } from './crypto';
import { getAll, putRecord } from './db';

export type SyncState = 'local' | 'synced' | 'offline';
type LocalRow = { id: string; iv: string; ciphertext: Uint8Array };
type SharedPayload = { id: string; syncId?: string; createdAt?: string; date?: string; updatedAt?: string; deletedAt?: string };
type RemoteRow = { record_id: string; content_iv: string; content_ciphertext: string; updated_at: string };

function toBase64(bytes: Uint8Array): string {
  let binary = '';
  for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, Math.min(i + 0x8000, bytes.length)));
  return btoa(binary);
}

function fromBase64(value: string): Uint8Array {
  return Uint8Array.from(atob(value), (character) => character.charCodeAt(0));
}

async function sharedKey(secret: Uint8Array, coupleId: string, recordId: string): Promise<CryptoKey> {
  const material = await crypto.subtle.importKey('raw', asArrayBuffer(secret), 'HKDF', false, ['deriveKey']);
  return crypto.subtle.deriveKey(
    { name: 'HKDF', hash: 'SHA-256', salt: new TextEncoder().encode(coupleId), info: new TextEncoder().encode(`vault-of-us-shared-record:${recordId}`) },
    material,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt'],
  );
}

async function openRemote(secret: Uint8Array, coupleId: string, row: RemoteRow): Promise<SharedPayload> {
  const key = await sharedKey(secret, coupleId, row.record_id);
  const clear = await decryptBytes(key, row.content_iv, fromBase64(row.content_ciphertext));
  const payload = JSON.parse(new TextDecoder().decode(clear)) as SharedPayload;
  if (payload.syncId !== row.record_id || !(payload.createdAt || payload.date)) throw new Error('Um registro compartilhado está inconsistente.');
  return payload;
}

async function sealRemote(secret: Uint8Array, coupleId: string, payload: SharedPayload): Promise<{ content_iv: string; content_ciphertext: string }> {
  if (!payload.syncId) throw new Error('Registro sem identificador de sincronização.');
  const key = await sharedKey(secret, coupleId, payload.syncId);
  const sealed = await encryptBytes(key, new TextEncoder().encode(JSON.stringify(payload)));
  return { content_iv: sealed.iv, content_ciphertext: toBase64(sealed.ciphertext) };
}

function revision(payload: SharedPayload): number {
  return Date.parse(payload.updatedAt ?? payload.createdAt ?? payload.date ?? '') || 0;
}

async function syncForCouple(client: SupabaseClient, coupleId: string, secret: Uint8Array, vaultKey: CryptoKey): Promise<void> {
  const remoteRows: RemoteRow[] = [];
  for (let offset = 0; ; offset += 1000) {
    const { data, error } = await client.from('couple_records')
      .select('record_id,content_iv,content_ciphertext,updated_at')
      .eq('couple_id', coupleId).range(offset, offset + 999);
    if (error) throw error;
    remoteRows.push(...((data ?? []) as RemoteRow[]));
    if ((data ?? []).length < 1000) break;
  }

  const localRows = (await getAll<LocalRow>('local_messages')).filter((row) => row.id.startsWith('memory:') || row.id.startsWith('together:') || row.id.startsWith('comment:'));
  const localPayloads = new Map<string, { payload: SharedPayload; localId: string }>();
  for (const row of localRows) {
    const payload = JSON.parse(new TextDecoder().decode(await decryptBytes(vaultKey, row.iv, row.ciphertext))) as SharedPayload;
    if (!payload.id || !(payload.createdAt || payload.date)) continue;
    payload.syncId = row.id;
    payload.updatedAt ??= payload.createdAt ?? payload.date;
    localPayloads.set(payload.syncId, { payload, localId: row.id });
  }

  const remoteIds = new Set<string>();
  for (const row of remoteRows) {
    remoteIds.add(row.record_id);
    const remotePayload = await openRemote(secret, coupleId, row);
    const local = localPayloads.get(row.record_id);
    if (!local || revision(remotePayload) >= revision(local.payload)) {
      const sealed = await encryptBytes(vaultKey, new TextEncoder().encode(JSON.stringify(remotePayload)));
      await putRecord('local_messages', {
        id: remotePayload.syncId!,
        iv: sealed.iv,
        ciphertext: sealed.ciphertext,
      });
      localPayloads.set(row.record_id, { payload: remotePayload, localId: remotePayload.syncId! });
    } else if (revision(local.payload) > revision(remotePayload)) {
      const sealedLocal = await encryptBytes(vaultKey, new TextEncoder().encode(JSON.stringify(local.payload)));
      await putRecord('local_messages', { id: local.localId, iv: sealedLocal.iv, ciphertext: sealedLocal.ciphertext });
      const sealed = await sealRemote(secret, coupleId, local.payload);
      const { error: writeError } = await client.from('couple_records').upsert({
        couple_id: coupleId, record_id: local.payload.syncId, ...sealed,
      }, { onConflict: 'couple_id,record_id' });
      if (writeError) throw writeError;
    }
  }

  for (const [recordId, local] of localPayloads) {
    if (remoteIds.has(recordId)) continue;
    const sealedLocal = await encryptBytes(vaultKey, new TextEncoder().encode(JSON.stringify(local.payload)));
    await putRecord('local_messages', { id: local.localId, iv: sealedLocal.iv, ciphertext: sealedLocal.ciphertext });
    const sealed = await sealRemote(secret, coupleId, local.payload);
    const { error: writeError } = await client.from('couple_records').upsert({
      couple_id: coupleId, record_id: recordId, ...sealed,
    }, { onConflict: 'couple_id,record_id' });
    if (writeError) throw writeError;
  }
}

export async function syncSharedRecords(vaultKey: CryptoKey): Promise<SyncState> {
  if (!backendConfigured || !supabase) return 'local';
  try {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;
    const user = data.session?.user;
    if (!user) return 'local';
    const couple = await currentCouple(supabase, user);
    if (!couple?.member_two) return 'local';
    const secret = await loadPairSecret(supabase, couple.id, vaultKey);
    if (!secret) return 'local';
    await syncForCouple(supabase, couple.id, secret, vaultKey);
    return 'synced';
  } catch {
    return 'offline';
  }
}
