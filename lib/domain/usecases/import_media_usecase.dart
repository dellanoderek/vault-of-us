import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' as drift;
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';
import '../../core/media/media_processor.dart';
import '../../core/security/crypto_service.dart';
import '../../core/storage/storage_service.dart';
import '../../data/database/app_database.dart';

class ImportMediaUseCase {
  final AppDatabase db;
  final CryptoService cryptoService;
  final StorageService storageService;
  final MediaProcessor mediaProcessor;
  final SecretKey masterKey;

  ImportMediaUseCase({
    required this.db,
    required this.cryptoService,
    required this.storageService,
    required this.mediaProcessor,
    required this.masterKey,
  });

  /// Fluxo de importação (especificação seção 7):
  /// 1. Recebe arquivo original
  /// 2. Calcula SHA-256 ANTES da criptografia
  /// 3. Verifica deduplicação
  /// 4. Se hash existe → referencia arquivo existente
  /// 5. Se não → gera thumb/preview/original → criptografa → salva
  Future<void> importMedia(
    AssetEntity asset,
    int? albumId, {
    bool removeFromGallery = false,
  }) async {
    final originalFile = await asset.file;
    if (originalFile == null) throw Exception('Arquivo não encontrado');

    final bytes = await originalFile.readAsBytes();

    // 2. SHA-256 antes da criptografia
    final hash = await cryptoService.calculateSha256(bytes);

    // 3. Deduplicação
    final existing = await (db.select(db.mediaItems)
          ..where((t) => t.hash.equals(hash)))
        .getSingleOrNull();

    if (existing != null) {
      // 4. Referencia arquivo existente
      await db.into(db.mediaItems).insert(
            MediaItemsCompanion.insert(
              hash: hash,
              albumId: drift.Value(albumId),
              filePath: existing.filePath,
              thumbPath: existing.thumbPath,
              previewPath: existing.previewPath,
              mediaType: existing.mediaType,
              takenAt: drift.Value(asset.createDateTime),
              importedAt: DateTime.now(),
              encryptionIv: existing.encryptionIv,
            ),
          );
    } else {
      // 5. Processa e criptografa
      late File thumb, preview, original;

      if (asset.type == AssetType.image) {
        final p = await mediaProcessor.processPhoto(originalFile);
        thumb = p.thumb;
        preview = p.preview;
        original = p.original;
      } else if (asset.type == AssetType.video) {
        final p = await mediaProcessor.processVideo(originalFile);
        thumb = p.thumb;
        preview = p.preview;
        original = p.original;
      } else {
        throw Exception('Tipo de mídia não suportado');
      }

      final uuid = const Uuid().v4();

      final encThumb = await cryptoService.encryptFile(await thumb.readAsBytes(), masterKey);
      final encPreview = await cryptoService.encryptFile(await preview.readAsBytes(), masterKey);
      final encOriginal = await cryptoService.encryptFile(await original.readAsBytes(), masterKey);

      final thumbSaved = await storageService.saveEncryptedFile(
        'albums/$uuid/thumb.enc',
        encThumb.encryptedData,
      );
      final previewSaved = await storageService.saveEncryptedFile(
        'albums/$uuid/preview.enc',
        encPreview.encryptedData,
      );
      final originalSaved = await storageService.saveEncryptedFile(
        'albums/$uuid/original.enc',
        encOriginal.encryptedData,
      );

      final nonceHex = cryptoService.bytesToHex(encOriginal.nonce);

      await db.into(db.mediaItems).insert(
            MediaItemsCompanion.insert(
              hash: hash,
              albumId: drift.Value(albumId),
              filePath: originalSaved.path,
              thumbPath: thumbSaved.path,
              previewPath: previewSaved.path,
              mediaType: asset.type == AssetType.image ? 'photo' : 'video',
              takenAt: drift.Value(asset.createDateTime),
              importedAt: DateTime.now(),
              encryptionIv: nonceHex,
            ),
          );
    }

    if (removeFromGallery) {
      await PhotoManager.editor.deleteWithIds([asset.id]);
    }
  }
}
