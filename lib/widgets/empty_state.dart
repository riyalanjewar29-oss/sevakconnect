import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final double verticalPadding;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.verticalPadding = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: verticalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: AppColors.secondary.withAlpha(180),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: AppTypography.headlineMd(color: AppColors.onSurface).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Text(
                    message!,
                    style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant).copyWith(
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 14),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
