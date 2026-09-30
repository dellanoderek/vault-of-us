import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinKeypad extends StatefulWidget {
  final int pinLength;
  final Function(String) onCompleted;
  final String title;
  final String? subtitle;
  final String? errorMessage;

  const PinKeypad({
    super.key,
    this.pinLength = 4,
    required this.onCompleted,
    required this.title,
    this.subtitle,
    this.errorMessage,
  });

  @override
  State<PinKeypad> createState() => _PinKeypadState();
}

class _PinKeypadState extends State<PinKeypad> with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeController;
  double _shakeOffset = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeController.addListener(() {
      setState(() {
        _shakeOffset = _shakeController.value < 0.5
            ? _shakeController.value * 20
            : (1.0 - _shakeController.value) * -20;
      });
    });
  }

  Widget _buildPinDots(ColorScheme colorScheme) {
    return Transform.translate(
      offset: Offset(_shakeOffset, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.pinLength, (i) {
          final filled = i < _pin.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            width: filled ? 18 : 16,
            height: filled ? 18 : 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: colorScheme.primary.withOpacity(filled ? 1.0 : 0.3),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void didUpdateWidget(PinKeypad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null &&
        oldWidget.errorMessage != widget.errorMessage) {
      _shakeController.forward(from: 0);
      _pin = '';
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= widget.pinLength) return;
    HapticFeedback.lightImpact();
    setState(() => _pin += digit);
    if (_pin.length == widget.pinLength) {
      widget.onCompleted(_pin);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 48),
          // Pin dots com animação de shake
          _buildPinDots(colorScheme),
          const Spacer(),
          // Teclado numérico
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                for (int row = 0; row < 3; row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int col = 1; col <= 3; col++)
                          _buildKey('${row * 3 + col}', colorScheme),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 72, height: 72),
                    _buildKey('0', colorScheme),
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: IconButton(
                        onPressed: _onBackspace,
                        icon: Icon(
                          Icons.backspace_outlined,
                          size: 24,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildKey(String digit, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _onDigit(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
