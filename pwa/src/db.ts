export interface VaultSettings {
  id: 'vault';
  salt: string;
  wrappedKey: string;
  wrapIv: string;
  createdAt: string;
}

export interface MediaRecord {
  id: string;
  name: string;
  type: string;
  size: number;
  createdAt: string;
  takenAt?: string;
  width?: number;
  height?: number;
  albumId?: string;
  favorite: boolean;
  secret?: boolean;
  deletedAt?: string;
  originalIv: string;
  thumbIv: string;
  hash: string;
}

export interface SealedMediaRecord {
  id: string;
  metadataIv: string;
  metadataCiphertext: Uint8Array;
}

const DB_NAME = 'vault-of-us-local';
const DB_VERSION = 1;

let dbPromise: Promise<IDBDatabase> | undefined;

export function openDb(): Promise<IDBDatabase> {
  if (dbPromise) return dbPromise;
  dbPromise = new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);
    request.onupgradeneeded = () => {
      const db = request.result;
      db.createObjectStore('settings', { keyPath: 'id' });
      db.createObjectStore('media', { keyPath: 'id' });
      db.createObjectStore('originals');
      db.createObjectStore('thumbnails');
      db.createObjectStore('albums', { keyPath: 'id' });
      db.createObjectStore('local_messages', { keyPath: 'id' });
      db.createObjectStore('preferences', { keyPath: 'key' });
    };
    request.onerror = () => reject(request.error ?? new Error('Não foi possível abrir o cofre local.'));
    request.onsuccess = () => resolve(request.result);
  });
  return dbPromise;
}

export async function getRecord<T>(storeName: string, key: IDBValidKey): Promise<T | undefined> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const request = db.transaction(storeName, 'readonly').objectStore(storeName).get(key);
    request.onsuccess = () => resolve(request.result as T | undefined);
    request.onerror = () => reject(request.error);
  });
}

export async function getAll<T>(storeName: string): Promise<T[]> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const request = db.transaction(storeName, 'readonly').objectStore(storeName).getAll();
    request.onsuccess = () => resolve(request.result as T[]);
    request.onerror = () => reject(request.error);
  });
}

export async function putRecord(storeName: string, value: unknown): Promise<void> {
  const db = await openDb();
  await new Promise<void>((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite');
    tx.objectStore(storeName).put(value);
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
    tx.onabort = () => reject(tx.error ?? new Error('A gravação local foi cancelada.'));
  });
}

export async function putBlob(storeName: string, key: IDBValidKey, value: Blob): Promise<void> {
  const db = await openDb();
  await new Promise<void>((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite');
    tx.objectStore(storeName).put(value, key);
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
    tx.onabort = () => reject(tx.error ?? new Error('A gravação local foi cancelada.'));
  });
}

export async function getBlob(storeName: string, key: IDBValidKey): Promise<Blob | undefined> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const request = db.transaction(storeName, 'readonly').objectStore(storeName).get(key);
    request.onsuccess = () => resolve(request.result as Blob | undefined);
    request.onerror = () => reject(request.error);
  });
}

export async function deleteRecord(storeName: string, key: IDBValidKey): Promise<void> {
  const db = await openDb();
  await new Promise<void>((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite');
    tx.objectStore(storeName).delete(key);
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
  });
}

export async function clearLocalVault(): Promise<void> {
  const db = await openDb();
  db.close();
  dbPromise = undefined;
  await new Promise<void>((resolve, reject) => {
    const request = indexedDB.deleteDatabase(DB_NAME);
    request.onsuccess = () => resolve();
    request.onerror = () => reject(request.error);
    request.onblocked = () => reject(new Error('Feche outras abas do Vault of Us e tente novamente.'));
  });
}
