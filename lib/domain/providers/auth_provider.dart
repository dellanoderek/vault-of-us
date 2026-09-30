import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/crypto_service.dart';
import 'database_provider.dart';

enum AppMode { normal, secret }

enum AuthStatus { uninitialized, onboarding, locked, unlocked }

class AuthState {
  final AuthStatus status;
  final AppMode mode;
  final SecretKey? masterKey;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.mode = AppMode.normal,
    this.masterKey,
  });

  AuthState copyWith({AuthStatus? status, AppMode? mode, SecretKey? masterKey}) {
    return AuthState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      masterKey: masterKey ?? this.masterKey,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final CryptoService _crypto;

  AuthNotifier(this._crypto) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final isOnboarded = await _crypto.isOnboardingComplete();
    if (!isOnboarded) {
      state = const AuthState(status: AuthStatus.onboarding);
    } else {
      state = const AuthState(status: AuthStatus.locked);
    }
  }

  Future<bool> unlockWithPin(String pin) async {
    final salt = await _crypto.loadSalt();
    if (salt == null) return false;

    final pinKey = await _crypto.deriveKeyFromPin(pin, salt);
    final stored = await _crypto.loadEncryptedMasterKey();
    if (stored == null) return false;

    try {
      final masterKeyBytes = await _crypto.decryptMasterKey(
        stored.cipherText,
        stored.nonce,
        stored.mac,
        pinKey,
      );
      state = AuthState(
        status: AuthStatus.unlocked,
        mode: AppMode.normal,
        masterKey: SecretKey(masterKeyBytes),
      );
      return true;
    } catch (e) {
      // PIN errado = falha na descriptografia
      return false;
    }
  }

  Future<void> setupPin(String pin, List<int> masterKeyBytes) async {
    final salt = _crypto.generateSalt();
    await _crypto.storeSalt(salt);

    final pinKey = await _crypto.deriveKeyFromPin(pin, salt);
    final encrypted = await _crypto.encryptMasterKey(masterKeyBytes, pinKey);
    await _crypto.storeEncryptedMasterKey(
      encrypted.cipherText,
      encrypted.nonce,
      encrypted.mac,
    );
    await _crypto.markOnboardingComplete();

    state = AuthState(
      status: AuthStatus.unlocked,
      mode: AppMode.normal,
      masterKey: SecretKey(masterKeyBytes),
    );
  }

  void lock() {
    state = const AuthState(status: AuthStatus.locked);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(cryptoServiceProvider)),
);
