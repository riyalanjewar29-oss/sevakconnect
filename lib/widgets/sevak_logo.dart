import 'package:flutter/material.dart';

class SevakLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const SevakLogo({
    super.key,
    this.size = 110,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/sevak_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF9933),
            ),
            child: Icon(
              Icons.temple_hindu_rounded,
              color: Colors.white,
              size: size * 0.4,
            ),
          );
        },
      ),
    );
  }
}
