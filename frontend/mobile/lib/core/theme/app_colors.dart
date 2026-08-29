import 'package:flutter/material.dart';

/// SevakConnect Design System Color Tokens (Dharma Guide)
/// Adheres strictly to the Dharma Guide design specifications:
/// - Primary: #8F4E00 (Saffron/Ochre)
/// - Primary Container: #FF9933
/// - Secondary: #4C56AF (Deep Navy / Vitthal Indigo)
/// - Secondary Container: #959EFD
/// - Tertiary: #5D5F5F
/// - 4-Tier Functional Status Colors (Normal, Moderate, High, Critical)
class AppColors {
  // Brand Base Tokens (Dharma Guide)
  static const Color primary = Color(0xFF8F4E00); // Saffron / Ochre
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFF9933);
  static const Color onPrimaryContainer = Color(0xFF693800);
  static const Color inversePrimary = Color(0xFFFFB77A);
  static const Color primaryFixed = Color(0xFFFFDCC2);
  static const Color primaryFixedDim = Color(0xFFFFB77A);
  static const Color onPrimaryFixed = Color(0xFF2E1500);
  static const Color onPrimaryFixedVariant = Color(0xFF6D3A00);

  static const Color secondary = Color(0xFF4C56AF); // Deep Navy / Vitthal Indigo
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF959EFD);
  static const Color onSecondaryContainer = Color(0xFF27308A);
  static const Color secondaryFixed = Color(0xFFE0E0FF);
  static const Color secondaryFixedDim = Color(0xFFBDC2FF);
  static const Color onSecondaryFixed = Color(0xFF000767);
  static const Color onSecondaryFixedVariant = Color(0xFF343D96);

  static const Color tertiary = Color(0xFF5D5F5F);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB1B2B2);
  static const Color onTertiaryContainer = Color(0xFF434545);
  static const Color tertiaryFixed = Color(0xFFE2E2E2);
  static const Color tertiaryFixedDim = Color(0xFFC6C6C7);
  static const Color onTertiaryFixed = Color(0xFF1A1C1C);
  static const Color onTertiaryFixedVariant = Color(0xFF454747);

  // Surface & Canvas Tokens
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceBright = Color(0xFFFCF9F8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFFE5E2E1);

  // Text & On-Surface Tokens
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF554336);
  static const Color inverseSurface = Color(0xFF303030);
  static const Color inverseOnSurface = Color(0xFFF3F0EF);

  // Outlines & Borders
  static const Color outline = Color(0xFF887364);
  static const Color outlineVariant = Color(0xFFDBC2B0);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color surfaceTint = Color(0xFF8F4E00);

  // Error / Critical
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Background
  static const Color background = Color(0xFFFCF9F8);
  static const Color onBackground = Color(0xFF1B1C1C);

  // 4-Tier Functional Status Colors (Strict High-Contrast System)
  static const Color statusNormal = Color(0xFF2E6B27);
  static const Color statusNormalContainer = Color(0xFFE2F4E0);
  static const Color onStatusNormal = Color(0xFF11420C);

  static const Color statusModerate = Color(0xFFE69500);
  static const Color statusModerateContainer = Color(0xFFFEF3C7);
  static const Color onStatusModerate = Color(0xFF92400E);

  static const Color statusHigh = Color(0xFFD9622B);
  static const Color statusHighContainer = Color(0xFFFFEDD5);
  static const Color onStatusHigh = Color(0xFF9A3412);

  static const Color statusCritical = Color(0xFFBA1A1A);
  static const Color statusCriticalContainer = Color(0xFFFFDAD6);
  static const Color onStatusCritical = Color(0xFF93000A);

  // Elevation Shadows
  // Level 1: 12% opacity Navy #4C56AF for standard cards
  static const Color shadowAmbient = Color(0x1F4C56AF);
  // Level 2: 20% opacity Red #BA1A1A for critical emergency overlays
  static const Color shadowAlert = Color(0x33BA1A1A);
}
