import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/onboarding_provider.dart';
import 'widgets/pin_keypad.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String? _firstPin;
  String? _error;
  int _attempt = 0;

  Future<void> _onPinEntered(String pin) async {
    if (_firstPin == null) {
      // Primeiro PIN
      setState(() {
        _firstPin = pin;
        _error = null;
        _attempt++;
      });
    } else {
      // Confirmação
      if (pin == _firstPin) {
        final masterKeyBytes = ref.read(onboardingProvider).masterKeyBytes;
        if (masterKeyBytes == null) return;
        await ref.read(authProvider.notifier).setupPin(pin, masterKeyBytes);
        ref.read(onboardingProvider.notifier).clear();
        if (mounted) context.go('/vault');
      } else {
        setState(() {
          _firstPin = null;
          _error = 'PINs não conferem. Tente novamente.';
          _attempt++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PinKeypad(
        key: ValueKey(_attempt),
        title: _firstPin == null ? 'Crie seu PIN' : 'Confirme seu PIN',
        subtitle: _firstPin == null ? 'Escolha 4 dígitos' : 'Digite novamente',
        errorMessage: _error,
        onCompleted: _onPinEntered,
      ),
    );
  }
}
