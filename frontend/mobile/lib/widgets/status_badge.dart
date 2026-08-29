import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_typography.dart';
import '../models/emergency_report.dart';
import '../models/crowd_condition.dart';
import '../models/crowd_report.dart';
import '../models/volunteer.dart';
import '../core/extensions/crowd_level_extension.dart';
export '../core/extensions/crowd_level_extension.dart';

/// High-contrast pill-shaped status badge with optional timestamp
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final DateTime? lastUpdated;
  final bool showDot;
  final Color? dotColor;
  final double horizontalPadding;
  final double verticalPadding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.lastUpdated,
    this.showDot = true,
    this.dotColor,
    this.horizontalPadding = 12.0,
    this.verticalPadding = 6.0,
  });

  /// Factory for EmergencySeverity
  factory StatusBadge.fromEmergencySeverity(EmergencySeverity severity) {
    return StatusBadge(
      label: severity.displayName,
      backgroundColor: severity.containerColor,
      textColor: severity.onContainerColor,
      dotColor: severity.color,
    );
  }

  /// Factory for EmergencyStatus
  factory StatusBadge.fromEmergencyStatus(EmergencyStatus status, {DateTime? timestamp}) {
    return StatusBadge(
      label: status.displayName,
      backgroundColor: status.containerColor,
      textColor: status.onContainerColor,
      dotColor: status.color,
      lastUpdated: timestamp,
    );
  }

  /// Factory for CrowdLevel
  factory StatusBadge.fromCrowdLevel(CrowdLevel level, {DateTime? timestamp}) {
    return StatusBadge(
      label: level.displayName,
      backgroundColor: level.containerColor,
      textColor: level.onContainerColor,
      dotColor: level.color,
      lastUpdated: timestamp,
    );
  }

  /// Factory for CrowdDensity
  factory StatusBadge.fromDensity(CrowdDensity density, {DateTime? timestamp}) {
    return StatusBadge(
      label: density.displayName.toUpperCase(),
      backgroundColor: density.containerColor,
      textColor: density.onContainerColor,
      dotColor: density.color,
      lastUpdated: timestamp,
    );
  }

  /// Factory for VolunteerStatus
  factory StatusBadge.fromVolunteerStatus(VolunteerStatus status, {DateTime? timestamp}) {
    return StatusBadge(
      label: status.displayName,
      backgroundColor: status.containerColor,
      textColor: status.onContainerColor,
      dotColor: status.color,
      lastUpdated: timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? timeStr;
    if (lastUpdated != null) {
      timeStr = DateFormat('HH:mm').format(lastUpdated!);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor ?? textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.labelSm(color: textColor).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (timeStr != null) ...[
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: AppTypography.labelSm(
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
