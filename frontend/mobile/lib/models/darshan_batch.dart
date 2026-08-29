import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum DarshanStatus {
  waiting,
  resting,
  called,
  completed,
}

extension DarshanStatusExtension on DarshanStatus {
  String get displayName {
    switch (this) {
      case DarshanStatus.waiting:
        return 'Waiting';
      case DarshanStatus.resting:
        return 'Resting';
      case DarshanStatus.called:
        return 'Called';
      case DarshanStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case DarshanStatus.waiting:
        return AppColors.secondary;
      case DarshanStatus.resting:
        return AppColors.statusModerate;
      case DarshanStatus.called:
        return AppColors.primary;
      case DarshanStatus.completed:
        return AppColors.statusNormal;
    }
  }

  Color get containerColor {
    switch (this) {
      case DarshanStatus.waiting:
        return AppColors.secondaryContainer;
      case DarshanStatus.resting:
        return AppColors.statusModerateContainer;
      case DarshanStatus.called:
        return AppColors.primaryContainer;
      case DarshanStatus.completed:
        return AppColors.statusNormalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case DarshanStatus.waiting:
        return AppColors.onSecondaryContainer;
      case DarshanStatus.resting:
        return AppColors.onStatusModerate;
      case DarshanStatus.called:
        return AppColors.onPrimaryContainer;
      case DarshanStatus.completed:
        return AppColors.onStatusNormal;
    }
  }

  static DarshanStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'called':
        return DarshanStatus.called;
      case 'resting':
        return DarshanStatus.resting;
      case 'completed':
        return DarshanStatus.completed;
      default:
        return DarshanStatus.waiting;
    }
  }
}

class DarshanBatch {
  final String id;
  final String dindi;
  final String block;
  final String batch;
  final String tokenRange;
  final DarshanStatus status;
  final String estimatedTime;
  final int totalDevotees;
  final DateTime updatedAt;
  final String gateAssigned;
  final String volunteerInCharge;

  const DarshanBatch({
    required this.id,
    required this.dindi,
    required this.block,
    required this.batch,
    required this.tokenRange,
    required this.status,
    required this.estimatedTime,
    required this.totalDevotees,
    required this.updatedAt,
    this.gateAssigned = 'Gate 2 (Tukaram Dwar)',
    this.volunteerInCharge = 'Ramesh Patil',
  });

  DarshanBatch copyWith({
    String? id,
    String? dindi,
    String? block,
    String? batch,
    String? tokenRange,
    DarshanStatus? status,
    String? estimatedTime,
    int? totalDevotees,
    DateTime? updatedAt,
    String? gateAssigned,
    String? volunteerInCharge,
  }) {
    return DarshanBatch(
      id: id ?? this.id,
      dindi: dindi ?? this.dindi,
      block: block ?? this.block,
      batch: batch ?? this.batch,
      tokenRange: tokenRange ?? this.tokenRange,
      status: status ?? this.status,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      totalDevotees: totalDevotees ?? this.totalDevotees,
      updatedAt: updatedAt ?? this.updatedAt,
      gateAssigned: gateAssigned ?? this.gateAssigned,
      volunteerInCharge: volunteerInCharge ?? this.volunteerInCharge,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dindi': dindi,
      'block': block,
      'batch': batch,
      'token_range': tokenRange,
      'status': status.name,
      'estimated_time': estimatedTime,
      'total_devotees': totalDevotees,
      'updated_at': updatedAt.toIso8601String(),
      'gate_assigned': gateAssigned,
      'volunteer_in_charge': volunteerInCharge,
    };
  }

  factory DarshanBatch.fromMap(Map<String, dynamic> map) {
    return DarshanBatch(
      id: map['id'] ?? '',
      dindi: map['dindi'] ?? '',
      block: map['block'] ?? '',
      batch: map['batch'] ?? '',
      tokenRange: map['token_range'] ?? '',
      status: DarshanStatusExtension.fromString(map['status'] ?? 'waiting'),
      estimatedTime: map['estimated_time'] ?? '',
      totalDevotees: (map['total_devotees'] as num?)?.toInt() ?? 0,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      gateAssigned: map['gate_assigned'] ?? 'Gate 2',
      volunteerInCharge: map['volunteer_in_charge'] ?? 'Volunteer',
    );
  }
}
