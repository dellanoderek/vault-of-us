import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  final _chacha20 = Chacha20.poly1305Aead();
  final _sha256 = Sha256();
  final _argon2 = Argon2id(
    memory: 65536,
    iterations: 3,
    parallelism: 4,
    hashLength: 32,
  );
  final _secureStorage = const FlutterSecureStorage();

  // --- Hex utilities ---

  String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  List<int> hexToBytes(String hex) {
    return List<int>.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    );
  }

  // --- SHA-256 (deduplicação - calculado ANTES da criptografia) ---

  Future<String> calculateSha256(List<int> data) async {
    final hash = await _sha256.hash(data);
    return bytesToHex(hash.bytes);
  }

  // --- Master Key + BIP-39 ---

  Future<({List<int> keyBytes, String mnemonic})> generateMasterKeyWithSeed() async {
    // 1. Gera mnemonic de 24 palavras (internamente cria 256 bits de entropia)
    final mnemonic = bip39.generateMnemonic(strength: 256);
    // 2. Deriva seed determinística do mnemonic
    final seedHex = bip39.mnemonicToSeedHex(mnemonic);
    // 3. Usa os primeiros 32 bytes como master key
    final keyBytes = hexToBytes(seedHex).sublist(0, 32);
    return (keyBytes: keyBytes, mnemonic: mnemonic);
  }

  List<int> recoverMasterKeyFromSeed(String mnemonic) {
    final seedHex = bip39.mnemonicToSeedHex(mnemonic);
    return hexToBytes(seedHex).sublist(0, 32);
  }

  // --- PIN + Argon2 ---

  List<int> generateSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  Future<SecretKey> deriveKeyFromPin(String pin, List<int> salt) async {
    return await _argon2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
  }

  // --- Encrypt/Decrypt Master Key com PIN-derived key ---

  Future<({List<int> cipherText, List<int> nonce, List<int> mac})> encryptMasterKey(
    List<int> masterKeyBytes,
    SecretKey pinDerivedKey,
  ) async {
    final secretBox = await _chacha20.encrypt(
      masterKeyBytes,
      secretKey: pinDerivedKey,
    );
    return (
      cipherText: secretBox.cipherText,
      nonce: secretBox.nonce,
      mac: secretBox.mac.bytes,
    );
  }

  Future<List<int>> decryptMasterKey(
    List<int> cipherText,
    List<int> nonce,
    List<int> mac,
    SecretKey pinDerivedKey,
  ) async {
    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(mac),
    );
    return await _chacha20.decrypt(secretBox, secretKey: pinDerivedKey);
  }

  // --- Encrypt/Decrypt files (fotos, vídeos) ---

  Future<({List<int> encryptedData, List<int> nonce})> encryptFile(
    List<int> clearData,
    SecretKey masterKey,
  ) async {
    final secretBox = await _chacha20.encrypt(
      clearData,
      secretKey: masterKey,
    );
    final encrypted = [...secretBox.cipherText, ...secretBox.mac.bytes];
    return (encryptedData: encrypted, nonce: secretBox.nonce);
  }

  Future<List<int>> decryptFile(
    List<int> encryptedData,
    List<int> nonce,
    SecretKey masterKey,
  ) async {
    final macBytes = encryptedData.sublist(encryptedData.length - 16);
    final cipherText = encryptedData.sublist(0, encryptedData.length - 16);
    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );
    return await _chacha20.decrypt(secretBox, secretKey: masterKey);
  }

  // --- Secure Storage helpers (Keychain no iOS) ---

  Future<void> storeSalt(List<int> salt) async {
    await _secureStorage.write(key: 'argon2_salt', value: bytesToHex(salt));
  }

  Future<List<int>?> loadSalt() async {
    final hex = await _secureStorage.read(key: 'argon2_salt');
    if (hex == null) return null;
    return hexToBytes(hex);
  }

  Future<void> storeEncryptedMasterKey(
    List<int> cipherText,
    List<int> nonce,
    List<int> mac,
  ) async {
    await _secureStorage.write(key: 'mk_cipher', value: bytesToHex(cipherText));
    await _secureStorage.write(key: 'mk_nonce', value: bytesToHex(nonce));
    await _secureStorage.write(key: 'mk_mac', value: bytesToHex(mac));
  }

  Future<({List<int> cipherText, List<int> nonce, List<int> mac})?> loadEncryptedMasterKey() async {
    final cipher = await _secureStorage.read(key: 'mk_cipher');
    final nonce = await _secureStorage.read(key: 'mk_nonce');
    final mac = await _secureStorage.read(key: 'mk_mac');
    if (cipher == null || nonce == null || mac == null) return null;
    return (
      cipherText: hexToBytes(cipher),
      nonce: hexToBytes(nonce),
      mac: hexToBytes(mac),
    );
  }

  Future<void> markOnboardingComplete() async {
    await _secureStorage.write(key: 'onboarding_complete', value: 'true');
  }

  Future<bool> isOnboardingComplete() async {
    final val = await _secureStorage.read(key: 'onboarding_complete');
    return val == 'true';
  }
}
