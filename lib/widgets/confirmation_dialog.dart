import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor = AppColors.primary,
    this.icon = Icons.warning_amber_rounded,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.primary,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: confirmColor.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: confirmColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineMd(color: AppColors.onSurface)
                  .copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(80, 44),
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(100, 44),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
