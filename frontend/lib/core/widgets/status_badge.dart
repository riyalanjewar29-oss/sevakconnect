import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum StatusTier {
  normal,
  moderate,
  high,
  critical,
}

/// Simulation-Honest Status Badge Component (DESIGN.md)
/// Pill-shaped, high-contrast, includes a last-updated timestamp per rule.
class StatusBadge extends StatelessWidget {
  final StatusTier tier;
  final String label;
  final String lastUpdatedText;

  const StatusBadge({
    super.key,
    required this.tier,
    required this.label,
    required this.lastUpdatedText,
  });

  Color get _bg {
    switch (tier) {
      case StatusTier.normal:
        return AppColors.statusNormalBg;
      case StatusTier.moderate:
        return AppColors.statusModerateBg;
      case StatusTier.high:
        return AppColors.statusHighBg;
      case StatusTier.critical:
        return AppColors.statusCriticalBg;
    }
  }

  Color get _fg {
    switch (tier) {
      case StatusTier.normal:
        return AppColors.statusNormal;
      case StatusTier.moderate:
        return AppColors.statusModerate;
      case StatusTier.high:
        return AppColors.statusHigh;
      case StatusTier.critical:
        return AppColors.statusCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(50.0), // Pill shape per spec
        border: Border.all(color: _fg.withAlpha(102), width: 1.0), // 40% opacity border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: _fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            '• $lastUpdatedText',
            style: AppTypography.labelSm.copyWith(
              color: _fg.withAlpha(204), // 80% opacity text
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
