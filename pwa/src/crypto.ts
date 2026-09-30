import type { VaultSettings } from './db';

const encoder = new TextEncoder();

function toBase64(bytes: Uint8Array): string {
  let binary = '';
  for (let i = 0; i < bytes.length; i += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(i, Math.min(i + 0x8000, bytes.length)));
  }
  return btoa(binary);
}

function fromBase64(value: string): Uint8Array {
  const binary = atob(value);
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

export function asArrayBuffer(bytes: Uint8Array): ArrayBuffer {
  return new Uint8Array(bytes).buffer as ArrayBuffer;
}

async function deriveWrappingKey(passphrase: string, salt: Uint8Array): Promise<CryptoKey> {
  const material = await crypto.subtle.importKey('raw', encoder.encode(passphrase), 'PBKDF2', false, ['deriveKey']);
  return crypto.subtle.deriveKey(
    { name: 'PBKDF2', salt: asArrayBuffer(salt), iterations: 600_000, hash: 'SHA-256' },
    material,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt'],
  );
}

export interface SecretModeCredential {
  key: 'secret-mode-pin';
  salt: string;
  iv: string;
  verifier: string;
}

const SECRET_MODE_MARKER = encoder.encode('vault-of-us-secret-mode-pin-v1');

export async function createSecretModeCredential(passphrase: string): Promise<SecretModeCredential> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await deriveWrappingKey(passphrase, salt);
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const verifier = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: asArrayBuffer(iv) }, key, SECRET_MODE_MARKER);
  return { key: 'secret-mode-pin', salt: toBase64(salt), iv: toBase64(iv), verifier: toBase64(new Uint8Array(verifier)) };
}

export async function verifySecretModeCredential(passphrase: string, credential: SecretModeCredential): Promise<boolean> {
  try {
    const key = await deriveWrappingKey(passphrase, fromBase64(credential.salt));
    const clear = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: asArrayBuffer(fromBase64(credential.iv)) }, key, asArrayBuffer(fromBase64(credential.verifier)));
    const value = new Uint8Array(clear);
    return value.length === SECRET_MODE_MARKER.length && value.every((byte, index) => byte === SECRET_MODE_MARKER[index]);
  } catch { return false; }
}

export async function createVault(passphrase: string): Promise<{ settings: VaultSettings; key: CryptoKey }> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const wrappingKey = await deriveWrappingKey(passphrase, salt);
  const rawVaultKey = crypto.getRandomValues(new Uint8Array(32));
  const wrappingIv = crypto.getRandomValues(new Uint8Array(12));
  const wrapped = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: asArrayBuffer(wrappingIv) }, wrappingKey, asArrayBuffer(rawVaultKey));
  const key = await crypto.subtle.importKey('raw', rawVaultKey, 'AES-GCM', false, ['encrypt', 'decrypt']);
  rawVaultKey.fill(0);
  return {
    settings: {
      id: 'vault',
      salt: toBase64(salt),
      wrappedKey: toBase64(new Uint8Array(wrapped)),
      wrapIv: toBase64(wrappingIv),
      createdAt: new Date().toISOString(),
    },
    key,
  };
}

export async function unlockVault(passphrase: string, settings: VaultSettings): Promise<CryptoKey> {
  const wrappingKey = await deriveWrappingKey(passphrase, fromBase64(settings.salt));
  const rawKey = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: asArrayBuffer(fromBase64(settings.wrapIv)) },
    wrappingKey,
    asArrayBuffer(fromBase64(settings.wrappedKey)),
  );
  return crypto.subtle.importKey('raw', rawKey, 'AES-GCM', false, ['encrypt', 'decrypt']);
}

export async function encryptBytes(key: CryptoKey, cleartext: ArrayBuffer | Uint8Array): Promise<{ iv: string; ciphertext: Uint8Array }> {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const source = cleartext instanceof Uint8Array ? asArrayBuffer(cleartext) : cleartext;
  const ciphertext = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: asArrayBuffer(iv) }, key, source);
  return { iv: toBase64(iv), ciphertext: new Uint8Array(ciphertext) };
}

export async function decryptBytes(key: CryptoKey, iv: string, ciphertext: ArrayBuffer | Uint8Array): Promise<Uint8Array> {
  const source = ciphertext instanceof Uint8Array ? asArrayBuffer(ciphertext) : ciphertext;
  return new Uint8Array(await crypto.subtle.decrypt({ name: 'AES-GCM', iv: asArrayBuffer(fromBase64(iv)) }, key, source));
}

export async function sha256(bytes: ArrayBuffer): Promise<string> {
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', bytes));
  return [...digest].map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

export function randomId(): string {
  return crypto.randomUUID();
}
