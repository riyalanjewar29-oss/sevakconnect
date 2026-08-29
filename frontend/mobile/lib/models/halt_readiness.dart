import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum HaltReadinessStatus {
  ready,
  partiallyReady,
  notReady,
}

extension HaltReadinessStatusExtension on HaltReadinessStatus {
  String get displayName {
    switch (this) {
      case HaltReadinessStatus.ready:
        return 'READY';
      case HaltReadinessStatus.partiallyReady:
        return 'PARTIALLY READY';
      case HaltReadinessStatus.notReady:
        return 'NOT READY';
    }
  }

  Color get color {
    switch (this) {
      case HaltReadinessStatus.ready:
        return AppColors.statusNormal;
      case HaltReadinessStatus.partiallyReady:
        return AppColors.statusModerate;
      case HaltReadinessStatus.notReady:
        return AppColors.statusCritical;
    }
  }

  Color get containerColor {
    switch (this) {
      case HaltReadinessStatus.ready:
        return AppColors.statusNormalContainer;
      case HaltReadinessStatus.partiallyReady:
        return AppColors.statusModerateContainer;
      case HaltReadinessStatus.notReady:
        return AppColors.statusCriticalContainer;
    }
  }
}

class Halt {
  final String id;
  final int sequence;
  final String name;
  final String location;
  final String eta;
  final int expectedCrowd;
  final int projectedMeals;
  final int availableMeals;
  final int projectedWaterLiters;
  final int availableWaterLiters;
  final int projectedMedicalUnits;
  final int availableMedicalUnits;
  final String coordinatorName;
  final String coordinatorPhone;
  final String statusNote;

  const Halt({
    required this.id,
    required this.sequence,
    required this.name,
    required this.location,
    required this.eta,
    required this.expectedCrowd,
    required this.projectedMeals,
    required this.availableMeals,
    required this.projectedWaterLiters,
    required this.availableWaterLiters,
    required this.projectedMedicalUnits,
    required this.availableMedicalUnits,
    required this.coordinatorName,
    required this.coordinatorPhone,
    this.statusNote = '',
  });

  // Rule-based readiness calculation (No ML)
  double get mealFulfillment =>
      projectedMeals > 0 ? (availableMeals / projectedMeals).clamp(0.0, 1.5) : 1.0;

  double get waterFulfillment =>
      projectedWaterLiters > 0
          ? (availableWaterLiters / projectedWaterLiters).clamp(0.0, 1.5)
          : 1.0;

  double get medicalFulfillment =>
      projectedMedicalUnits > 0
          ? (availableMedicalUnits / projectedMedicalUnits).clamp(0.0, 1.5)
          : 1.0;

  double get overallScore =>
      (mealFulfillment * 0.4) +
      (waterFulfillment * 0.4) +
      (medicalFulfillment * 0.2);

  HaltReadinessStatus get readinessStatus {
    if (mealFulfillment >= 0.90 &&
        waterFulfillment >= 0.90 &&
        medicalFulfillment >= 0.85) {
      return HaltReadinessStatus.ready;
    } else if (mealFulfillment >= 0.60 &&
        waterFulfillment >= 0.60 &&
        medicalFulfillment >= 0.50) {
      return HaltReadinessStatus.partiallyReady;
    } else {
      return HaltReadinessStatus.notReady;
    }
  }

  bool get requiresAttention =>
      readinessStatus != HaltReadinessStatus.ready;

  Halt copyWith({
    String? id,
    int? sequence,
    String? name,
    String? location,
    String? eta,
    int? expectedCrowd,
    int? projectedMeals,
    int? availableMeals,
    int? projectedWaterLiters,
    int? availableWaterLiters,
    int? projectedMedicalUnits,
    int? availableMedicalUnits,
    String? coordinatorName,
    String? coordinatorPhone,
    String? statusNote,
  }) {
    return Halt(
      id: id ?? this.id,
      sequence: sequence ?? this.sequence,
      name: name ?? this.name,
      location: location ?? this.location,
      eta: eta ?? this.eta,
      expectedCrowd: expectedCrowd ?? this.expectedCrowd,
      projectedMeals: projectedMeals ?? this.projectedMeals,
      availableMeals: availableMeals ?? this.availableMeals,
      projectedWaterLiters: projectedWaterLiters ?? this.projectedWaterLiters,
      availableWaterLiters: availableWaterLiters ?? this.availableWaterLiters,
      projectedMedicalUnits:
          projectedMedicalUnits ?? this.projectedMedicalUnits,
      availableMedicalUnits:
          availableMedicalUnits ?? this.availableMedicalUnits,
      coordinatorName: coordinatorName ?? this.coordinatorName,
      coordinatorPhone: coordinatorPhone ?? this.coordinatorPhone,
      statusNote: statusNote ?? this.statusNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sequence': sequence,
      'name': name,
      'location': location,
      'eta': eta,
      'expected_crowd': expectedCrowd,
      'projected_meals': projectedMeals,
      'available_meals': availableMeals,
      'projected_water_liters': projectedWaterLiters,
      'available_water_liters': availableWaterLiters,
      'projected_medical_units': projectedMedicalUnits,
      'available_medical_units': availableMedicalUnits,
      'coordinator_name': coordinatorName,
      'coordinator_phone': coordinatorPhone,
      'status_note': statusNote,
    };
  }

  factory Halt.fromMap(Map<String, dynamic> map) {
    return Halt(
      id: map['id'] ?? '',
      sequence: (map['sequence'] as num?)?.toInt() ?? 1,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      eta: map['eta'] ?? 'On Schedule',
      expectedCrowd: (map['expected_crowd'] as num?)?.toInt() ?? 0,
      projectedMeals: (map['projected_meals'] as num?)?.toInt() ?? 0,
      availableMeals: (map['available_meals'] as num?)?.toInt() ?? 0,
      projectedWaterLiters:
          (map['projected_water_liters'] as num?)?.toInt() ?? 0,
      availableWaterLiters:
          (map['available_water_liters'] as num?)?.toInt() ?? 0,
      projectedMedicalUnits:
          (map['projected_medical_units'] as num?)?.toInt() ?? 0,
      availableMedicalUnits:
          (map['available_medical_units'] as num?)?.toInt() ?? 0,
      coordinatorName: map['coordinator_name'] ?? '',
      coordinatorPhone: map['coordinator_phone'] ?? '',
      statusNote: map['status_note'] ?? '',
    );
  }
}
