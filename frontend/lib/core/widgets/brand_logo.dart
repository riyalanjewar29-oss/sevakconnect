import 'package:flutter/material.dart';

/// SevakConnect Centralized Official Brand Logo Component
/// Renders the transparent official SevakConnect logo mark seamlessly across all screens.
class BrandLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const BrandLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/sevakconnect_logo_transparent.png',
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        // Fallback for asset loading edge-cases
        return SizedBox(
          width: width ?? 48.0,
          height: height ?? 48.0,
          child: const Icon(
            Icons.volunteer_activism_rounded,
            color: Color(0xFF8F4E00),
          ),
        );
      },
    );
  }
}
