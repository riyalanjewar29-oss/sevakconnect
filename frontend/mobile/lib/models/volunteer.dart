import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_colors.dart';

enum VolunteerStatus {
  active,
  available,
  busy,
  offline,
}

extension VolunteerStatusExtension on VolunteerStatus {
  String get displayName {
    switch (this) {
      case VolunteerStatus.active:
        return 'ACTIVE';
      case VolunteerStatus.available:
        return 'AVAILABLE';
      case VolunteerStatus.busy:
        return 'BUSY';
      case VolunteerStatus.offline:
        return 'OFFLINE';
    }
  }

  Color get color {
    switch (this) {
      case VolunteerStatus.active:
        return AppColors.statusNormal;
      case VolunteerStatus.available:
        return AppColors.secondary;
      case VolunteerStatus.busy:
        return AppColors.statusModerate;
      case VolunteerStatus.offline:
        return AppColors.tertiary;
    }
  }

  Color get containerColor {
    switch (this) {
      case VolunteerStatus.active:
        return AppColors.statusNormalContainer;
      case VolunteerStatus.available:
        return AppColors.secondaryContainer.withAlpha(120);
      case VolunteerStatus.busy:
        return AppColors.statusModerateContainer;
      case VolunteerStatus.offline:
        return AppColors.surfaceContainerHigh;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case VolunteerStatus.active:
        return AppColors.onStatusNormal;
      case VolunteerStatus.available:
        return AppColors.onSecondaryContainer;
      case VolunteerStatus.busy:
        return AppColors.onStatusModerate;
      case VolunteerStatus.offline:
        return AppColors.onSurfaceVariant;
    }
  }

  static VolunteerStatus fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'active':
        return VolunteerStatus.active;
      case 'available':
        return VolunteerStatus.available;
      case 'busy':
        return VolunteerStatus.busy;
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

  // Optional in-memory UI compatibility fields
  final double? latitude;
  final double? longitude;
  final int batteryPercent;

  const Volunteer({
    required this.uid,
    required this.name,
    this.phone = '',
    this.email = '',
    this.role = 'volunteer',
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
  String get currentLocation => dindiId;
  DateTime get lastActive => updatedAt;

  LatLng? get position =>
      (latitude != null && longitude != null) ? LatLng(latitude!, longitude!) : null;

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
    String? currentLocation,
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
