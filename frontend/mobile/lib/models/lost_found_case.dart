import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_colors.dart';

enum LostFoundStatus {
  open,
  investigating,
  resolved,
}

extension LostFoundStatusExtension on LostFoundStatus {
  String get displayName {
    switch (this) {
      case LostFoundStatus.open:
        return 'OPEN';
      case LostFoundStatus.investigating:
        return 'INVESTIGATING';
      case LostFoundStatus.resolved:
        return 'RESOLVED';
    }
  }

  Color get color {
    switch (this) {
      case LostFoundStatus.open:
        return AppColors.statusCritical;
      case LostFoundStatus.investigating:
        return AppColors.statusModerate;
      case LostFoundStatus.resolved:
        return AppColors.statusNormal;
    }
  }

  Color get containerColor {
    switch (this) {
      case LostFoundStatus.open:
        return AppColors.statusCriticalContainer;
      case LostFoundStatus.investigating:
        return AppColors.statusModerateContainer;
      case LostFoundStatus.resolved:
        return AppColors.statusNormalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case LostFoundStatus.open:
        return AppColors.onStatusCritical;
      case LostFoundStatus.investigating:
        return AppColors.onStatusModerate;
      case LostFoundStatus.resolved:
        return AppColors.onStatusNormal;
    }
  }

  String get firestoreValue {
    switch (this) {
      case LostFoundStatus.open:
        return 'open';
      case LostFoundStatus.investigating:
        return 'investigating';
      case LostFoundStatus.resolved:
        return 'resolved';
    }
  }

  static LostFoundStatus fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'investigating':
        return LostFoundStatus.investigating;
      case 'resolved':
        return LostFoundStatus.resolved;
      case 'open':
      default:
        return LostFoundStatus.open;
    }
  }
}

class LostFoundCase {
  final String id;
  final String type;
  final String description;
  final double? latitude;
  final double? longitude;
  final String reportedBy;
  final bool isMinor;
  final LostFoundStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LostFoundCase({
    required this.id,
    required this.type,
    required this.description,
    this.latitude,
    this.longitude,
    required this.reportedBy,
    this.isMinor = false,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  LatLng? get position {
    if (latitude == null || longitude == null) {
      return null;
    }
    return LatLng(latitude!, longitude!);
  }

  LostFoundCase copyWith({
    String? id,
    String? type,
    String? description,
    double? latitude,
    double? longitude,
    String? reportedBy,
    bool? isMinor,
    LostFoundStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LostFoundCase(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reportedBy: reportedBy ?? this.reportedBy,
      isMinor: isMinor ?? this.isMinor,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'reportedBy': reportedBy,
      'isMinor': isMinor,
      'status': status.firestoreValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LostFoundCase.fromMap(
    Map<String, dynamic> map, {
    String docId = '',
  }) {
    final rawCreatedAt = map['createdAt'];
    final rawUpdatedAt = map['updatedAt'];

    DateTime parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt =
          DateTime.tryParse(rawCreatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime parsedUpdatedAt;
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt =
          DateTime.tryParse(rawUpdatedAt) ?? parsedCreatedAt;
    } else if (rawUpdatedAt is int) {
      parsedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(rawUpdatedAt);
    } else {
      parsedUpdatedAt = parsedCreatedAt;
    }

    return LostFoundCase(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      reportedBy: map['reportedBy'] ?? '',
      isMinor: map['isMinor'] ?? map['is_minor'] ?? false,
      status: LostFoundStatusExtension.fromString(map['status'] ?? 'open'),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }
}
