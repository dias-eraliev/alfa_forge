import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class LogoWithGlow extends StatelessWidget {
  final double size;
  final bool animate;
  final Duration animationDuration;

  const LogoWithGlow({
    super.key,
    this.size = 72.0,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  Widget _buildLetter(String letter, BuildContext context) {
    return Text(
      letter,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
        color: PRIMETheme.sand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PRIME
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLetter('P', context),
            _buildLetter('R', context),
            _buildLetter('I', context),
            _buildLetter('M', context),
            _buildLetter('E', context),
          ],
        ),
      ],
    );
  }
}
