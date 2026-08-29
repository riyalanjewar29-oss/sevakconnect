import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_theme.dart';
import 'status_badge.dart';

class ZoneCard extends StatelessWidget {
  final String name;
  final String? marathiName;
  final String densityLabel;
  final Color densityColor;
  final Color densityContainerColor;
  final String lastUpdate;
  final bool isRestricted;
  final int currentHeadcount;
  final int safeCapacity;
  final double flowSpeedKmh;
  final VoidCallback? onToggleRestriction;

  const ZoneCard({
    super.key,
    required this.name,
    this.marathiName,
    required this.densityLabel,
    required this.densityColor,
    required this.densityContainerColor,
    required this.lastUpdate,
    this.isRestricted = false,
    this.currentHeadcount = 0,
    this.safeCapacity = 1000,
    this.flowSpeedKmh = 0.0,
    this.onToggleRestriction,
  });

  @override
  Widget build(BuildContext context) {
    final capacityPercentage = safeCapacity > 0
        ? (currentHeadcount / safeCapacity).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: isRestricted
          ? AppTheme.criticalAlertDecoration(
              backgroundColor: AppColors.surfaceContainerLowest,
            )
          : AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isRestricted
                  ? AppColors.statusCriticalContainer.withAlpha(50)
                  : AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.headlineMd(color: AppColors.onSurface)
                            .copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (marathiName != null && marathiName!.isNotEmpty)
                        Text(
                          marathiName!,
                          style: AppTypography.labelSm(color: AppColors.secondary)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: densityLabel,
                  backgroundColor: densityContainerColor,
                  textColor: densityColor,
                  dotColor: densityColor,
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headcount vs Capacity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Devotee Crowd:',
                      style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      '$currentHeadcount / $safeCapacity max',
                      style: AppTypography.labelLg(color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: capacityPercentage,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      capacityPercentage > 0.85
                          ? AppColors.statusCritical
                          : (capacityPercentage > 0.6
                              ? AppColors.statusHigh
                              : AppColors.statusNormal),
                    ),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 12),

                // Water Current
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Water Current Speed:',
                          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Text(
                      '$flowSpeedKmh km/h',
                      style: AppTypography.labelSm(color: AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Entry Gate Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isRestricted ? Icons.lock_rounded : Icons.lock_open_rounded,
                          size: 16,
                          color: isRestricted
                              ? AppColors.statusCritical
                              : AppColors.statusNormal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Gate Barrier Status:',
                          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Text(
                      isRestricted ? 'RESTRICTED ENTRY' : 'OPEN FOR DEVOTEES',
                      style: AppTypography.labelSm(
                        color: isRestricted
                            ? AppColors.statusCritical
                            : AppColors.statusNormal,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action Button: Flag for Restricted Entry
                SizedBox(
                  width: double.infinity,
                  child: isRestricted
                      ? OutlinedButton.icon(
                          onPressed: onToggleRestriction,
                          icon: const Icon(Icons.lock_open_rounded, size: 16),
                          label: const Text('Lift Entry Restriction'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            foregroundColor: AppColors.secondary,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: onToggleRestriction,
                          icon: const Icon(Icons.block_rounded, size: 16),
                          label: const Text('Flag for Restricted Entry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
