import { deleteRecord, getAll, getBlob, getRecord, type MediaRecord, type SealedMediaRecord, putBlob, putRecord, type VaultSettings } from './db';
import { asArrayBuffer, decryptBytes, encryptBytes, randomId, sha256 } from './crypto';

export async function settingsExist(): Promise<boolean> {
  return Boolean(await getRecord<VaultSettings>('settings', 'vault'));
}

export async function saveSettings(settings: VaultSettings): Promise<void> {
  await putRecord('settings', settings);
}

export async function getSettings(): Promise<VaultSettings | undefined> {
  return getRecord<VaultSettings>('settings', 'vault');
}

export function inferMediaType(file: File): string {
  if (file.type) return file.type;
  const extension = file.name.split('.').pop()?.toLowerCase();
  const known: Record<string, string> = {
    jpg: 'image/jpeg', jpeg: 'image/jpeg', png: 'image/png', gif: 'image/gif', webp: 'image/webp',
    heic: 'image/heic', heif: 'image/heif', avif: 'image/avif', bmp: 'image/bmp',
    mp4: 'video/mp4', mov: 'video/quicktime', m4v: 'video/x-m4v', webm: 'video/webm',
    mp3: 'audio/mpeg', m4a: 'audio/mp4', aac: 'audio/aac', wav: 'audio/wav', ogg: 'audio/ogg',
  };
  return extension ? known[extension] ?? 'application/octet-stream' : 'application/octet-stream';
}

async function makeThumbnail(file: File, mediaType: string): Promise<{ blob: Blob; width?: number; height?: number }> {
  if (!mediaType.startsWith('image/')) return { blob: new Blob([], { type: 'image/jpeg' }) };
  let source: CanvasImageSource | undefined;
  let width = 0;
  let height = 0;
  let release: () => void = () => {};
  if (typeof createImageBitmap === 'function') {
    try {
      const bitmap = await createImageBitmap(file);
      source = bitmap;
      width = bitmap.width;
      height = bitmap.height;
      release = () => bitmap.close();
    } catch { /* Fall through to the image-element decoder used by Safari. */ }
  }
  if (!source) {
    const objectUrl = URL.createObjectURL(file);
    try {
      const image = await new Promise<HTMLImageElement>((resolve, reject) => {
        const element = new Image();
        element.onload = () => resolve(element);
        element.onerror = () => reject(new Error('Este formato de imagem não pode ser aberto neste navegador. Atualize o iOS ou converta a foto para JPEG.'));
        element.src = objectUrl;
      });
      source = image;
      width = image.naturalWidth;
      height = image.naturalHeight;
      release = () => URL.revokeObjectURL(objectUrl);
    } catch (error) {
      URL.revokeObjectURL(objectUrl);
      throw error;
    }
  }
  if (!width || !height) { release(); throw new Error('Não foi possível ler as dimensões desta imagem.'); }
  const scale = Math.min(1, 480 / Math.max(width, height));
  const canvas = document.createElement('canvas');
  canvas.width = Math.max(1, Math.round(width * scale));
  canvas.height = Math.max(1, Math.round(height * scale));
  const context = canvas.getContext('2d');
  if (!context) { release(); throw new Error('Não foi possível preparar a miniatura.'); }
  try {
    context.drawImage(source, 0, 0, canvas.width, canvas.height);
    const blob = await new Promise<Blob>((resolve, reject) => canvas.toBlob((value) => value ? resolve(value) : reject(new Error('Falha ao gerar miniatura.')), 'image/jpeg', 0.76));
    return { blob, width, height };
  } finally { release(); }
}

export async function importFile(file: File, key: CryptoKey): Promise<{ record: MediaRecord; duplicate: boolean }> {
  const mediaType = inferMediaType(file);
  const clear = await file.arrayBuffer();
  const hash = await sha256(clear);
  const existing = [...await listMedia(key, 'all'), ...await listMedia(key, 'trash')].find((record) => record.hash === hash);
  if (existing) {
    if (existing.deletedAt) {
      const { deletedAt: _deletedAt, ...restored } = existing;
      await updateMedia(restored, key);
      return { record: restored, duplicate: true };
    }
    return { record: existing, duplicate: true };
  }
  const { blob: thumbnail, width, height } = await makeThumbnail(file, mediaType);
  const originalEncrypted = await encryptBytes(key, clear);
  const thumbnailEncrypted = await encryptBytes(key, await thumbnail.arrayBuffer());
  const id = randomId();
  const record: MediaRecord = {
    id,
    name: file.name || (file.type.startsWith('video/') ? 'Vídeo' : 'Imagem'),
    type: mediaType,
    size: file.size,
    createdAt: new Date().toISOString(),
    takenAt: await readJpegDateTaken(clear),
    width,
    height,
    favorite: false,
    originalIv: originalEncrypted.iv,
    thumbIv: thumbnailEncrypted.iv,
    hash,
  };
  try {
    await putBlob('originals', id, new Blob([asArrayBuffer(originalEncrypted.ciphertext)], { type: 'application/octet-stream' }));
    await putBlob('thumbnails', id, new Blob([asArrayBuffer(thumbnailEncrypted.ciphertext)], { type: 'application/octet-stream' }));
    const sealedMetadata = await encryptBytes(key, new TextEncoder().encode(JSON.stringify(record)));
    const stored: SealedMediaRecord = { id, metadataIv: sealedMetadata.iv, metadataCiphertext: sealedMetadata.ciphertext };
    await putRecord('media', stored);
  } catch (error) {
    await deleteRecord('originals', id).catch(() => undefined);
    await deleteRecord('thumbnails', id).catch(() => undefined);
    if (error instanceof DOMException && error.name === 'QuotaExceededError') {
      throw new Error('O armazenamento local deste aparelho ficou sem espaço. Libere espaço ou exporte algumas fotos antes de tentar novamente.');
    }
    throw error;
  }
  return { record, duplicate: false };
}

export async function listMedia(key: CryptoKey, filter: 'all' | 'favorites' | 'trash' | 'secret' = 'all', includeSecretInTrash = false): Promise<MediaRecord[]> {
  const sealedRows = await getAll<SealedMediaRecord>('media');
  const rows: MediaRecord[] = [];
  for (const sealed of sealedRows) {
    const clear = await decryptBytes(key, sealed.metadataIv, sealed.metadataCiphertext);
    rows.push({ ...(JSON.parse(new TextDecoder().decode(clear)) as Omit<MediaRecord, 'id'>), id: sealed.id });
  }
  return rows
    .filter((row) => filter === 'secret' ? !row.deletedAt && Boolean(row.secret) : filter === 'trash' ? Boolean(row.deletedAt) && (includeSecretInTrash || !row.secret) : !row.deletedAt && !row.secret && (filter === 'favorites' ? row.favorite : true))
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

export async function thumbnailUrl(record: MediaRecord, key: CryptoKey): Promise<string | undefined> {
  if (!record.type.startsWith('image/')) return undefined;
  const encrypted = await getBlob('thumbnails', record.id);
  if (!encrypted) return undefined;
  const clear = await decryptBytes(key, record.thumbIv, await encrypted.arrayBuffer());
  return URL.createObjectURL(new Blob([asArrayBuffer(clear)], { type: 'image/jpeg' }));
}

export async function originalBlob(record: MediaRecord, key: CryptoKey): Promise<Blob> {
  const encrypted = await getBlob('originals', record.id);
  if (!encrypted) throw new Error('O arquivo não está no armazenamento local.');
  const clear = await decryptBytes(key, record.originalIv, await encrypted.arrayBuffer());
  return new Blob([asArrayBuffer(clear)], { type: record.type });
}

export async function updateMedia(record: MediaRecord, key: CryptoKey): Promise<void> {
  const sealed = await encryptBytes(key, new TextEncoder().encode(JSON.stringify(record)));
  await putRecord('media', { id: record.id, metadataIv: sealed.iv, metadataCiphertext: sealed.ciphertext } satisfies SealedMediaRecord);
}

export async function permanentlyDelete(record: MediaRecord): Promise<void> {
  await deleteRecord('media', record.id);
  await deleteRecord('originals', record.id);
  await deleteRecord('thumbnails', record.id);
}

export async function purgeExpiredTrash(key: CryptoKey, retentionDays = 30): Promise<number> {
  const cutoff = Date.now() - retentionDays * 24 * 60 * 60 * 1000;
  const expired = (await listMedia(key, 'trash')).filter((record) => record.deletedAt && Date.parse(record.deletedAt) <= cutoff);
  for (const record of expired) await permanentlyDelete(record);
  return expired.length;
}

export interface VaultAlbum { id: string; name: string; createdAt: string }

export async function listAlbums(key: CryptoKey): Promise<VaultAlbum[]> {
  const rows = await getAll<{ id: string; iv: string; ciphertext: Uint8Array }>('albums');
  const albums: VaultAlbum[] = [];
  for (const row of rows) albums.push(JSON.parse(new TextDecoder().decode(await decryptBytes(key, row.iv, row.ciphertext))) as VaultAlbum);
  return albums.sort((a, b) => a.name.localeCompare(b.name, 'pt-BR'));
}

export async function createAlbum(name: string, key: CryptoKey): Promise<VaultAlbum> {
  const album = { id: randomId(), name: name.trim(), createdAt: new Date().toISOString() };
  const sealed = await encryptBytes(key, new TextEncoder().encode(JSON.stringify(album)));
  await putRecord('albums', { id: album.id, iv: sealed.iv, ciphertext: sealed.ciphertext });
  return album;
}

export async function deleteAlbum(albumId: string, key: CryptoKey): Promise<void> {
  await deleteRecord('albums', albumId);
  for (const record of [...await listMedia(key, 'all'), ...await listMedia(key, 'trash')]) {
    if (record.albumId === albumId) {
      const { albumId: _removed, ...withoutAlbum } = record;
      await updateMedia(withoutAlbum, key);
    }
  }
}

async function readJpegDateTaken(buffer: ArrayBuffer): Promise<string | undefined> {
  try {
    const view = new DataView(buffer);
    if (view.byteLength < 4 || view.getUint16(0, false) !== 0xffd8) return undefined;
    let offset = 2;
    while (offset + 4 <= view.byteLength) {
    if (view.getUint8(offset) !== 0xff) { offset++; continue; }
    const marker = view.getUint8(offset + 1);
    const segmentLength = view.getUint16(offset + 2, false);
    if (segmentLength < 2 || offset + 2 + segmentLength > view.byteLength) return undefined;
    const start = offset + 4;
    if (marker === 0xe1 && segmentLength >= 16 && view.getUint32(start, false) === 0x45786966 && view.getUint16(start + 4, false) === 0) {
      const tiff = start + 6;
      const byteOrder = view.getUint16(tiff, false);
      const little = byteOrder === 0x4949;
      if (!little && byteOrder !== 0x4d4d) return undefined;
      const read16 = (at: number) => view.getUint16(at, little);
      const read32 = (at: number) => view.getUint32(at, little);
      const firstIfd = tiff + read32(tiff + 4);
      if (firstIfd + 2 > view.byteLength) return undefined;
      const readIfd = (ifd: number): Map<number, number> => {
        const values = new Map<number, number>();
        const count = Math.min(read16(ifd), 512);
        for (let i = 0; i < count; i++) {
          const entry = ifd + 2 + i * 12;
          if (entry + 12 > view.byteLength) break;
          const tag = read16(entry);
          const type = read16(entry + 2);
          const valueCount = read32(entry + 4);
          if (tag === 0x8769 && type === 4) values.set(tag, read32(entry + 8));
          if ((tag === 0x9003 || tag === 0x9004) && type === 2 && valueCount >= 19) values.set(tag, read32(entry + 8));
        }
        return values;
      };
      const primary = readIfd(firstIfd);
      const exifOffset = primary.get(0x8769);
      if (exifOffset === undefined) return undefined;
      const exifIfd = readIfd(tiff + exifOffset);
      for (const tag of [0x9003, 0x9004]) {
        const valueOffset = exifIfd.get(tag);
        if (valueOffset === undefined) continue;
        const address = tiff + valueOffset;
        if (address + 19 > view.byteLength) continue;
        const raw = new TextDecoder().decode(new Uint8Array(buffer, address, 19));
        const match = /^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})$/.exec(raw);
        if (!match) continue;
        const [, year, month, day, hour, minute, second] = match;
        const date = new Date(Number(year), Number(month) - 1, Number(day), Number(hour), Number(minute), Number(second));
        if (!Number.isNaN(date.getTime())) return date.toISOString();
      }
      return undefined;
    }
    offset += 2 + segmentLength;
    if (marker === 0xda || marker === 0xd9) break;
    }
    return undefined;
  } catch {
    return undefined;
  }
}
