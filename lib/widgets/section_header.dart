import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Color iconBackgroundColor;
  final Color iconColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.iconBackgroundColor = AppColors.secondary,
    this.iconColor = AppColors.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineMd(color: AppColors.onSurface),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant).copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
