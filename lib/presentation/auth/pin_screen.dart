import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/auth_provider.dart';
import 'widgets/pin_keypad.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  int _attempts = 0;
  String? _error;

  Future<void> _onPinEntered(String pin) async {
    final success = await ref.read(authProvider.notifier).unlockWithPin(pin);
    if (success) {
      if (mounted) context.go('/vault');
    } else {
      setState(() {
        _attempts++;
        _error = 'PIN incorreto';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PinKeypad(
        key: ValueKey(_attempts),
        title: 'Vault of Us',
        subtitle: 'Digite seu PIN para entrar',
        errorMessage: _error,
        onCompleted: _onPinEntered,
      ),
    );
  }
}
