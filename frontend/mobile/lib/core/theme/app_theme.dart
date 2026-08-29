import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),

      // Card Theme (Elevation Level 1 with 8px radius and subtle 1px border)
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme (Primary Button: Saffron background + White text, 56px height)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(88, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.labelLg(color: AppColors.onPrimary),
        ),
      ),

      // Outlined Button Theme (Secondary Button: Deep Navy outline, 56px height)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          minimumSize: const Size(88, 56),
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.labelLg(color: AppColors.secondary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLg(color: AppColors.primary),
        ),
      ),

      // Input Decoration Theme (56px minimum height, 16px text, non-floating visible label)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMd(color: AppColors.outline),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceContainerHigh,
        thickness: 1,
        space: 1,
      ),

      // AppBar Theme (Secondary Deep Navy background for Chrome)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd(color: AppColors.onSecondary),
        iconTheme: const IconThemeData(color: AppColors.onSecondary),
      ),
    );
  }

  // Level 1 Box Shadow decoration for standard cards
  static BoxDecoration cardDecoration({
    Color backgroundColor = AppColors.surfaceContainerLowest,
    Border? border,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      border: border ?? Border.all(color: AppColors.borderLight, width: 1),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadowAmbient,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  // Level 2 Box Shadow decoration for critical alerts & emergency overlays
  static BoxDecoration criticalAlertDecoration({
    Color backgroundColor = AppColors.surfaceContainerLowest,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.statusCritical, width: 2),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadowAlert,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
