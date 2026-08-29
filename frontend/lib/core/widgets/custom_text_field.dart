import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Input Field Component (DESIGN.md)
/// 56px minimum height, 16px text size, labels always visible (never floating).
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.prefixText,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Static visible label (DESIGN.md: labels always visible, never floating)
        Text(
          label,
          style: AppTypography.labelLg.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8.0),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56.0), // 56px minimum height rule
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: AppTypography.bodyLg, // 16px font size rule
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
              errorText: errorText,
              errorStyle: AppTypography.labelSm.copyWith(
                color: AppColors.statusCritical,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: prefixIcon,
              prefix: prefix,
              prefixText: prefixText,
              prefixStyle: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // 8px corner radius
                borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppColors.border, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppColors.statusCritical, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppColors.statusCritical, width: 2.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
