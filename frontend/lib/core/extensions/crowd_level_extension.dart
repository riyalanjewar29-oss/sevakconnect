import 'package:flutter/material.dart';
import '../models/crowd_condition.dart';
import '../theme/app_colors.dart';

extension CrowdLevelExtension on CrowdLevel {
  String get displayName {
    switch (this) {
      case CrowdLevel.normal:
        return 'NORMAL';
      case CrowdLevel.moderate:
        return 'MODERATE';
      case CrowdLevel.high:
        return 'HIGH';
      case CrowdLevel.critical:
        return 'CRITICAL';
    }
  }

  Color get color {
    switch (this) {
      case CrowdLevel.normal:
        return AppColors.statusNormal;
      case CrowdLevel.moderate:
        return AppColors.statusModerate;
      case CrowdLevel.high:
        return AppColors.statusHigh;
      case CrowdLevel.critical:
        return AppColors.statusCritical;
    }
  }

  Color get containerColor {
    switch (this) {
      case CrowdLevel.normal:
        return AppColors.statusNormalContainer;
      case CrowdLevel.moderate:
        return AppColors.statusModerateContainer;
      case CrowdLevel.high:
        return AppColors.statusHighContainer;
      case CrowdLevel.critical:
        return AppColors.statusCriticalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case CrowdLevel.normal:
        return AppColors.onStatusNormal;
      case CrowdLevel.moderate:
        return AppColors.onStatusModerate;
      case CrowdLevel.high:
        return AppColors.onStatusHigh;
      case CrowdLevel.critical:
        return AppColors.onStatusCritical;
    }
  }
}
