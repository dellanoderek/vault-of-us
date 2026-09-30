import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/onboarding_provider.dart';

class SeedConfirmScreen extends ConsumerStatefulWidget {
  const SeedConfirmScreen({super.key});

  @override
  ConsumerState<SeedConfirmScreen> createState() =>
      _SeedConfirmScreenState();
}

class _SeedConfirmScreenState extends ConsumerState<SeedConfirmScreen> {
  late List<String> _words;
  late List<int> _challengeIndices;
  int _currentChallenge = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    final mnemonic = ref.read(onboardingProvider).mnemonic ?? '';
    _words = mnemonic.split(' ');
    final random = Random.secure();
    final indices = List.generate(_words.length, (i) => i)
      ..shuffle(random);
    _challengeIndices = indices.take(3).toList()..sort();
  }

  List<String> _getOptions(int correctIndex) {
    final correct = _words[correctIndex];
    final random = Random.secure();
    final others = List<String>.from(_words)
      ..remove(correct)
      ..shuffle(random);
    final options = [correct, ...others.take(3)]..shuffle(random);
    return options;
  }

  void _onOptionSelected(String selected) {
    final correctWord = _words[_challengeIndices[_currentChallenge]];
    if (selected == correctWord) {
      if (_currentChallenge == _challengeIndices.length - 1) {
        // Todas corretas — avançar para criação do PIN
        context.go('/pin-setup');
      } else {
        setState(() {
          _currentChallenge++;
          _error = null;
        });
      }
    } else {
      setState(() => _error = 'Palavra incorreta. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final idx = _challengeIndices[_currentChallenge];
    final options = _getOptions(idx);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirme sua Frase')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Qual é a palavra #${idx + 1}?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verificação ${_currentChallenge + 1} de ${_challengeIndices.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              ...options.map(
                (word) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _onOptionSelected(word),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color:
                              colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
