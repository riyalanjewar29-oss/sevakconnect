import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

enum CrowdDensity {
  normal,
  moderate,
  high,
  critical,
}

extension CrowdDensityExtension on CrowdDensity {
  String get displayName {
    switch (this) {
      case CrowdDensity.normal:
        return 'Normal';
      case CrowdDensity.moderate:
        return 'Moderate';
      case CrowdDensity.high:
        return 'High';
      case CrowdDensity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case CrowdDensity.normal:
        return AppColors.statusNormal;
      case CrowdDensity.moderate:
        return AppColors.statusModerate;
      case CrowdDensity.high:
        return AppColors.statusHigh;
      case CrowdDensity.critical:
        return AppColors.statusCritical;
    }
  }

  Color get containerColor {
    switch (this) {
      case CrowdDensity.normal:
        return AppColors.statusNormalContainer;
      case CrowdDensity.moderate:
        return AppColors.statusModerateContainer;
      case CrowdDensity.high:
        return AppColors.statusHighContainer;
      case CrowdDensity.critical:
        return AppColors.statusCriticalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case CrowdDensity.normal:
        return AppColors.onStatusNormal;
      case CrowdDensity.moderate:
        return AppColors.onStatusModerate;
      case CrowdDensity.high:
        return AppColors.onStatusHigh;
      case CrowdDensity.critical:
        return AppColors.onStatusCritical;
    }
  }

  static CrowdDensity fromString(String val) {
    switch (val.toLowerCase()) {
      case 'critical':
        return CrowdDensity.critical;
      case 'high':
        return CrowdDensity.high;
      case 'moderate':
        return CrowdDensity.moderate;
      default:
        return CrowdDensity.normal;
    }
  }
}

class CrowdReport {
  final String id;
  final String zoneId;
  final String zoneName;
  final CrowdDensity density;
  final String context; // "general" or "river"
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String reportedBy;
  final String reporterRole;
  final String notes;
  final int estimatedCount;
  final bool isResolved;

  const CrowdReport({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.density,
    this.context = 'general',
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.reportedBy,
    this.reporterRole = 'Volunteer',
    this.notes = '',
    this.estimatedCount = 0,
    this.isResolved = false,
  });

  LatLng get position => LatLng(latitude, longitude);

  CrowdReport copyWith({
    String? id,
    String? zoneId,
    String? zoneName,
    CrowdDensity? density,
    String? context,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? reportedBy,
    String? reporterRole,
    String? notes,
    int? estimatedCount,
    bool? isResolved,
  }) {
    return CrowdReport(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      density: density ?? this.density,
      context: context ?? this.context,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      reportedBy: reportedBy ?? this.reportedBy,
      reporterRole: reporterRole ?? this.reporterRole,
      notes: notes ?? this.notes,
      estimatedCount: estimatedCount ?? this.estimatedCount,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zone_id': zoneId,
      'zone_name': zoneName,
      'density': density.name,
      'context': context,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'reported_by': reportedBy,
      'reporter_role': reporterRole,
      'notes': notes,
      'estimated_count': estimatedCount,
      'is_resolved': isResolved,
    };
  }

  factory CrowdReport.fromMap(Map<String, dynamic> map) {
    return CrowdReport(
      id: map['id'] ?? '',
      zoneId: map['zone_id'] ?? '',
      zoneName: map['zone_name'] ?? '',
      density: CrowdDensityExtension.fromString(map['density'] ?? 'normal'),
      context: map['context'] ?? 'general',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.6775,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 75.3278,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      reportedBy: map['reported_by'] ?? 'Volunteer',
      reporterRole: map['reporter_role'] ?? 'Volunteer',
      notes: map['notes'] ?? '',
      estimatedCount: (map['estimated_count'] as num?)?.toInt() ?? 0,
      isResolved: map['is_resolved'] ?? false,
    );
  }
}
