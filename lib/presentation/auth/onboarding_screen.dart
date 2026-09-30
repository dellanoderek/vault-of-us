import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/database_provider.dart';
import '../../domain/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _loading = false;

  Future<void> _startSetup() async {
    setState(() => _loading = true);
    final crypto = ref.read(cryptoServiceProvider);
    final result = await crypto.generateMasterKeyWithSeed();
    ref
        .read(onboardingProvider.notifier)
        .setData(result.keyBytes, result.mnemonic);
    if (mounted) context.go('/seed-phrase');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.favorite_rounded,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32),
              const Text(
                'Vault of Us',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'O cofre privado e emocional\nda nossa vida a dois.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: colorScheme.onSurface.withOpacity(0.5),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: _loading ? null : _startSetup,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Configurar meu Cofre',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
