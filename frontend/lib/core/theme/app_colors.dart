import 'package:flutter/material.dart';

/// SevakConnect Strict Design System Colors (DESIGN.md)
abstract class AppColors {
  // Brand Colors (DESIGN.md)
  static const Color primary = Color(0xFF8F4E00); // Saffron/Ochre: Primary buttons, branding
  static const Color primaryContainer = Color(0xFFFF9933); // Saffron accent container
  static const Color secondary = Color(0xFF26365C); // Deep Navy: Headers, secondary outlines, chrome
  static const Color tertiary = Color(0xFFD9622B); // Minimal accent

  // Neutral & Surface Colors
  static const Color background = Color(0xFFFCF9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4EFEA);
  static const Color textPrimary = Color(0xFF1B1C1C);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF757575);
  static const Color outline = Color(0xFF887364);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);

  // 4-Tier Functional Status System (DESIGN.md)
  static const Color statusNormal = Color(0xFF2E7D32); // Normal Green
  static const Color statusNormalBg = Color(0xFFE8F5E9);
  
  static const Color statusModerate = Color(0xFFED6C02); // Moderate Amber
  static const Color statusModerateBg = Color(0xFFFFF3E0);
  
  static const Color statusHigh = Color(0xFFD32F2F); // High Alert Red
  static const Color statusHighBg = Color(0xFFFFEBEE);
  
  static const Color statusCritical = Color(0xFFB71C1C); // Emergency Deep Red
  static const Color statusCriticalBg = Color(0xFFFFEBEE);

  // Offline Banner Strip Colors
  static const Color bannerOnline = Color(0xFF26365C); // Deep Navy strip when online
  static const Color bannerOffline = Color(0xFFED6C02); // Moderate Yellow/Amber strip when offline
}
