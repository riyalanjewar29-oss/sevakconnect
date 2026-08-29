import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_theme.dart';
import '../models/crowd_report.dart';
import 'status_badge.dart';

class AlertFeedTile extends StatelessWidget {
  final CrowdReport alert;
  final VoidCallback onResolve;
  final VoidCallback? onViewOnMap;

  const AlertFeedTile({
    super.key,
    required this.alert,
    required this.onResolve,
    this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.density == CrowdDensity.critical;
    final timeFormatted = DateFormat('hh:mm a').format(alert.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: isCritical
          ? AppTheme.criticalAlertDecoration(
              backgroundColor: alert.isResolved
                  ? AppColors.surfaceContainerLowest
                  : AppColors.statusCriticalContainer.withAlpha(50),
            )
          : AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCritical
                      ? AppColors.statusCriticalContainer
                      : AppColors.statusHighContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
                  color: isCritical ? AppColors.statusCritical : AppColors.statusHigh,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.zoneName,
                            style: AppTypography.headlineMd(
                              color: AppColors.onSurface,
                            ).copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge.fromDensity(
                          alert.density,
                          timestamp: alert.timestamp,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reported by ${alert.reportedBy} (${alert.reporterRole}) • $timeFormatted',
                      style: AppTypography.labelSm(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (alert.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.notes,
                      style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Est. Crowd: ${alert.estimatedCount > 0 ? '${alert.estimatedCount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} Devotees' : "High Density"}',
                    style: AppTypography.labelSm(
                      color: AppColors.secondary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                children: [
                  if (onViewOnMap != null)
                    OutlinedButton.icon(
                      onPressed: onViewOnMap,
                      icon: const Icon(Icons.location_on_outlined, size: 16),
                      label: const Text('View on Map'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(110, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: AppTypography.labelSm(color: AppColors.secondary),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: Icon(
                      alert.isResolved
                          ? Icons.check_circle_outline
                          : Icons.task_alt_rounded,
                      size: 16,
                    ),
                    label: Text(alert.isResolved ? 'Resolved' : 'Dispatch / Acknowledge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alert.isResolved
                          ? AppColors.statusNormal
                          : AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size(140, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      textStyle: AppTypography.labelSm(color: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
