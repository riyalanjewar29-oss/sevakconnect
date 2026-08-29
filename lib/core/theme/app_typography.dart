import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// SevakConnect Design System Typography (Dharma Guide)
/// Inter font family strictly matching scale, weights, line heights, and letter spacing.
class AppTypography {
  // Display: 32px / 40px line-height / Weight 700 / -0.02em letter spacing
  static TextStyle display({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.64, // -0.02em * 32
        color: color,
      );

  // Headline-Lg: 24px / 32px line-height / Weight 600
  static TextStyle headlineLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: color,
      );

  // Headline-Lg Mobile: 22px / 28px line-height / Weight 600
  static TextStyle headlineLgMobile({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        color: color,
      );

  // Headline-Md: 20px / 28px line-height / Weight 600
  static TextStyle headlineMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: color,
      );

  // Body-Lg: 18px / 28px line-height / Weight 400
  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: color,
      );

  // Body-Md: 16px / 24px line-height / Weight 400
  static TextStyle bodyMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color,
      );

  // Label-Lg: 14px / 20px line-height / Weight 600 / +0.01em letter spacing
  static TextStyle labelLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.14, // 0.01em * 14
        color: color,
      );

  // Label-Sm: 12px / 16px line-height / Weight 500 / +0.02em letter spacing
  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.24, // 0.02em * 12
        color: color,
      );
}
