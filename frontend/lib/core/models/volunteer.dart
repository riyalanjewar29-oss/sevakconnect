import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum VolunteerStatus {
  active,
  onDuty,
  idle,
  offline,
}

extension VolunteerStatusExtension on VolunteerStatus {
  String get displayName {
    switch (this) {
      case VolunteerStatus.active:
        return 'Active';
      case VolunteerStatus.onDuty:
        return 'On Duty';
      case VolunteerStatus.idle:
        return 'Idle';
      case VolunteerStatus.offline:
        return 'Offline';
    }
  }

  Color get color {
    switch (this) {
      case VolunteerStatus.active:
      case VolunteerStatus.onDuty:
        return AppColors.statusNormal;
      case VolunteerStatus.idle:
        return AppColors.statusModerate;
      case VolunteerStatus.offline:
        return AppColors.textMuted;
    }
  }

  Color get containerColor {
    switch (this) {
      case VolunteerStatus.active:
      case VolunteerStatus.onDuty:
        return AppColors.statusNormalContainer;
      case VolunteerStatus.idle:
        return AppColors.statusModerateContainer;
      case VolunteerStatus.offline:
        return AppColors.surfaceVariant;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case VolunteerStatus.active:
      case VolunteerStatus.onDuty:
        return AppColors.onStatusNormal;
      case VolunteerStatus.idle:
        return AppColors.onStatusModerate;
      case VolunteerStatus.offline:
        return AppColors.textMuted;
    }
  }

  static VolunteerStatus fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'active':
        return VolunteerStatus.active;
      case 'on_duty':
      case 'onduty':
      case 'on duty':
        return VolunteerStatus.onDuty;
      case 'idle':
        return VolunteerStatus.idle;
      case 'offline':
      default:
        return VolunteerStatus.offline;
    }
  }
}

class Volunteer {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String dindiId;
  final VolunteerStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;
  final int batteryPercent;

  const Volunteer({
    required this.uid,
    required this.name,
    required this.phone,
    this.email = '',
    required this.role,
    this.dindiId = '',
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.batteryPercent = 100,
  });

  // UI Compatibility Getters
  String get id => uid;
  String get team => dindiId;
  String get currentLocation =>
      latitude != null && longitude != null
          ? 'Lat: ${latitude!.toStringAsFixed(4)}, Lon: ${longitude!.toStringAsFixed(4)}'
          : 'Unknown Location';
  DateTime get lastActive => updatedAt;

  Volunteer copyWith({
    String? uid,
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? dindiId,
    String? team,
    VolunteerStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    double? latitude,
    double? longitude,
    int? batteryPercent,
  }) {
    return Volunteer(
      uid: uid ?? id ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      dindiId: dindiId ?? team ?? this.dindiId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? lastActive ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      batteryPercent: batteryPercent ?? this.batteryPercent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'dindiId': dindiId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Volunteer.fromMap(
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

    final resolvedUid = docId.isNotEmpty
        ? docId
        : (map['uid'] ?? map['id'] ?? map['userId'] ?? '');

    return Volunteer(
      uid: resolvedUid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'volunteer',
      dindiId: map['dindiId'] ?? map['team'] ?? map['dindi'] ?? '',
      status: VolunteerStatusExtension.fromString(map['status'] ?? 'offline'),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      batteryPercent: (map['batteryPercent'] as num?)?.toInt() ?? 100,
    );
  }
}
