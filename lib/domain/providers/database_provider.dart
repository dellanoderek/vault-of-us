import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../core/security/crypto_service.dart';
import '../../core/storage/storage_service.dart';
import '../../core/media/media_processor.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final mediaProcessorProvider = Provider<MediaProcessor>((ref) {
  return MediaProcessor();
});
