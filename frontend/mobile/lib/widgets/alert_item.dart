import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_theme.dart';
import 'status_badge.dart';

class AlertItem extends StatelessWidget {
  final String title;
  final String location;
  final String timestamp;
  final String? note;
  final bool isCritical;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onDispatch;

  const AlertItem({
    super.key,
    required this.title,
    required this.location,
    required this.timestamp,
    this.note,
    this.isCritical = false,
    this.onAcknowledge,
    this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: isCritical
          ? AppTheme.criticalAlertDecoration(
              backgroundColor: AppColors.surfaceContainerLowest,
            )
          : AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCritical ? Icons.warning_rounded : Icons.info_rounded,
                    color: isCritical ? AppColors.statusCritical : AppColors.statusHigh,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.headlineMd(color: AppColors.onSurface).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: isCritical ? 'CRITICAL' : 'HIGH',
                backgroundColor: isCritical
                    ? AppColors.statusCriticalContainer
                    : AppColors.statusHighContainer,
                textColor: isCritical
                    ? AppColors.statusCritical
                    : AppColors.statusHigh,
                dotColor: isCritical
                    ? AppColors.statusCritical
                    : AppColors.statusHigh,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$location • $timestamp',
            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
          ),
          if (note != null && note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note!,
              style: AppTypography.bodyMd(color: AppColors.onSurface),
            ),
          ],
          if (onAcknowledge != null || onDispatch != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onAcknowledge != null)
                  OutlinedButton(
                    onPressed: onAcknowledge,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(100, 36),
                      foregroundColor: AppColors.secondary,
                    ),
                    child: const Text('Acknowledge'),
                  ),
                if (onDispatch != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDispatch,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 36),
                      backgroundColor: isCritical
                          ? AppColors.statusCritical
                          : AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('Dispatch Marshal'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
