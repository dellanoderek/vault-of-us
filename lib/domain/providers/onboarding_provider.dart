import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final List<int>? masterKeyBytes;
  final String? mnemonic;

  const OnboardingState({this.masterKeyBytes, this.mnemonic});

  OnboardingState copyWith({List<int>? masterKeyBytes, String? mnemonic}) {
    return OnboardingState(
      masterKeyBytes: masterKeyBytes ?? this.masterKeyBytes,
      mnemonic: mnemonic ?? this.mnemonic,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setData(List<int> keyBytes, String mnemonic) {
    state = OnboardingState(masterKeyBytes: keyBytes, mnemonic: mnemonic);
  }

  void clear() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
