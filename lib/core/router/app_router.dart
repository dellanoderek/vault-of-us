import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/onboarding_screen.dart';
import '../../presentation/auth/seed_phrase_screen.dart';
import '../../presentation/auth/seed_confirm_screen.dart';
import '../../presentation/auth/pin_setup_screen.dart';
import '../../presentation/auth/pin_screen.dart';
import '../../presentation/vault/vault_screen.dart';

final initialRouteProvider = StateProvider<String>((ref) => '/onboarding');

final appRouterProvider = Provider<GoRouter>((ref) {
  final initialRoute = ref.read(initialRouteProvider);

  return GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/seed-phrase',
        builder: (context, state) => const SeedPhraseScreen(),
      ),
      GoRoute(
        path: '/seed-confirm',
        builder: (context, state) => const SeedConfirmScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinScreen(),
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultScreen(),
      ),
    ],
  );
});
