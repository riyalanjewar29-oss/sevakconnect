import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

enum EmergencySeverity {
  low,
  medium,
  high,
  critical,
}

extension EmergencySeverityExtension on EmergencySeverity {
  String get displayName {
    switch (this) {
      case EmergencySeverity.low:
        return 'Low';
      case EmergencySeverity.medium:
        return 'Medium';
      case EmergencySeverity.high:
        return 'High';
      case EmergencySeverity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case EmergencySeverity.low:
        return AppColors.statusNormal;
      case EmergencySeverity.medium:
        return AppColors.statusModerate;
      case EmergencySeverity.high:
        return AppColors.statusHigh;
      case EmergencySeverity.critical:
        return AppColors.statusCritical;
    }
  }

  Color get containerColor {
    switch (this) {
      case EmergencySeverity.low:
        return AppColors.statusNormalContainer;
      case EmergencySeverity.medium:
        return AppColors.statusModerateContainer;
      case EmergencySeverity.high:
        return AppColors.statusHighContainer;
      case EmergencySeverity.critical:
        return AppColors.statusCriticalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case EmergencySeverity.low:
        return AppColors.onStatusNormal;
      case EmergencySeverity.medium:
        return AppColors.onStatusModerate;
      case EmergencySeverity.high:
        return AppColors.onStatusHigh;
      case EmergencySeverity.critical:
        return AppColors.onStatusCritical;
    }
  }

  static EmergencySeverity fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'low':
        return EmergencySeverity.low;
      case 'high':
        return EmergencySeverity.high;
      case 'critical':
        return EmergencySeverity.critical;
      case 'medium':
      default:
        return EmergencySeverity.medium;
    }
  }
}

enum EmergencyStatus {
  open,
  inProgress,
  resolved,
}

extension EmergencyStatusExtension on EmergencyStatus {
  String get displayName {
    switch (this) {
      case EmergencyStatus.open:
        return 'Open';
      case EmergencyStatus.inProgress:
        return 'In Progress';
      case EmergencyStatus.resolved:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case EmergencyStatus.open:
        return AppColors.statusCritical;
      case EmergencyStatus.inProgress:
        return AppColors.statusModerate;
      case EmergencyStatus.resolved:
        return AppColors.statusNormal;
    }
  }

  Color get containerColor {
    switch (this) {
      case EmergencyStatus.open:
        return AppColors.statusCriticalContainer;
      case EmergencyStatus.inProgress:
        return AppColors.statusModerateContainer;
      case EmergencyStatus.resolved:
        return AppColors.statusNormalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case EmergencyStatus.open:
        return AppColors.onStatusCritical;
      case EmergencyStatus.inProgress:
        return AppColors.onStatusModerate;
      case EmergencyStatus.resolved:
        return AppColors.onStatusNormal;
    }
  }

  String get firestoreValue {
    switch (this) {
      case EmergencyStatus.open:
        return 'open';
      case EmergencyStatus.inProgress:
        return 'in_progress';
      case EmergencyStatus.resolved:
        return 'resolved';
    }
  }

  static EmergencyStatus fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'in_progress':
      case 'in progress':
      case 'inprogress':
        return EmergencyStatus.inProgress;
      case 'resolved':
        return EmergencyStatus.resolved;
      case 'open':
      default:
        return EmergencyStatus.open;
    }
  }
}

class EmergencyReport {
  final String id;
  final String type;
  final EmergencySeverity severity;
  final String description;
  final double? latitude;
  final double? longitude;
  final String reportedBy;
  final EmergencyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const EmergencyReport({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    this.latitude,
    this.longitude,
    required this.reportedBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  // UI Compatibility Getters
  String get location => description;
  DateTime get time => createdAt;

  LatLng? get position {
    if (latitude == null || longitude == null) {
      return null;
    }
    return LatLng(latitude!, longitude!);
  }

  EmergencyReport copyWith({
    String? id,
    String? type,
    EmergencySeverity? severity,
    String? description,
    double? latitude,
    double? longitude,
    String? reportedBy,
    EmergencyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return EmergencyReport(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reportedBy: reportedBy ?? this.reportedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'severity': severity.name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'reportedBy': reportedBy,
      'status': firestoreStatusValue(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  static String firestoreStatusValue(EmergencyStatus s) {
    return s.firestoreValue;
  }

  factory EmergencyReport.fromMap(
    Map<String, dynamic> map, {
    String docId = '',
  }) {
    final createdTimestamp = map['createdAt'];
    final updatedTimestamp = map['updatedAt'];
    final resolvedTimestamp = map['resolvedAt'];

    if (createdTimestamp is! Timestamp) {
      throw const FormatException(
        'EmergencyReport requires a valid Firestore createdAt Timestamp.',
      );
    }

    if (updatedTimestamp is! Timestamp) {
      throw const FormatException(
        'EmergencyReport requires a valid Firestore updatedAt Timestamp.',
      );
    }

    DateTime? parsedResolvedAt;

    if (resolvedTimestamp is Timestamp) {
      parsedResolvedAt = resolvedTimestamp.toDate();
    }

    return EmergencyReport(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      type: map['type'] ?? '',
      severity: EmergencySeverityExtension.fromString(
        map['severity'] ?? 'medium',
      ),
      description: map['description'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      reportedBy: map['reportedBy'] ?? '',
      status: EmergencyStatusExtension.fromString(
        map['status'] ?? 'open',
      ),
      createdAt: createdTimestamp.toDate(),
      updatedAt: updatedTimestamp.toDate(),
      resolvedAt: parsedResolvedAt,
    );
  }
}
