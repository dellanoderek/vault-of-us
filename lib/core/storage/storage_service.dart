import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../security/file_protection_channel.dart';

class StorageService {
  Directory? _baseDir;

  Future<Directory> getBaseDirectory() async {
    if (_baseDir != null) return _baseDir!;
    final supportDir = await getApplicationSupportDirectory();
    final vaultDir = Directory(p.join(supportDir.path, 'vault_of_us'));
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    _baseDir = vaultDir;
    return vaultDir;
  }

  Future<void> initializeFolders() async {
    final baseDir = await getBaseDirectory();
    for (var folder in ['albums', 'chat_media', 'temp_media', 'encrypted']) {
      final dir = Directory(p.join(baseDir.path, folder));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  Future<File> saveEncryptedFile(
    String relativePath,
    List<int> bytes, {
    bool sensitive = true,
  }) async {
    final baseDir = await getBaseDirectory();
    final file = File(p.join(baseDir.path, relativePath));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes, flush: true);
    // Aplica NSFileProtection no iOS (Camada 3)
    await FileProtectionChannel.setProtection(file.path, sensitive: sensitive);
    return file;
  }

  Future<List<int>> readEncryptedFile(String relativePath) async {
    final baseDir = await getBaseDirectory();
    final file = File(p.join(baseDir.path, relativePath));
    return await file.readAsBytes();
  }
}
