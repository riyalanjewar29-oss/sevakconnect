import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ReadinessLevel {
  ready,
  moderate,
  notReady,
}

extension ReadinessLevelExtension on ReadinessLevel {
  String get displayName {
    switch (this) {
      case ReadinessLevel.ready:
        return 'Ready';
      case ReadinessLevel.moderate:
        return 'Moderate Risk';
      case ReadinessLevel.notReady:
        return 'Not Ready';
    }
  }

  Color get color {
    switch (this) {
      case ReadinessLevel.ready:
        return AppColors.statusNormal;
      case ReadinessLevel.moderate:
        return AppColors.statusModerate;
      case ReadinessLevel.notReady:
        return AppColors.statusCritical;
    }
  }

  Color get containerColor {
    switch (this) {
      case ReadinessLevel.ready:
        return AppColors.statusNormalContainer;
      case ReadinessLevel.moderate:
        return AppColors.statusModerateContainer;
      case ReadinessLevel.notReady:
        return AppColors.statusCriticalContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case ReadinessLevel.ready:
        return AppColors.onStatusNormal;
      case ReadinessLevel.moderate:
        return AppColors.onStatusModerate;
      case ReadinessLevel.notReady:
        return AppColors.onStatusCritical;
    }
  }

  static ReadinessLevel fromScore(double score) {
    if (score >= 80) {
      return ReadinessLevel.ready;
    } else if (score >= 50) {
      return ReadinessLevel.moderate;
    } else {
      return ReadinessLevel.notReady;
    }
  }

  static ReadinessLevel fromString(String val) {
    switch (val.toLowerCase()) {
      case 'ready':
        return ReadinessLevel.ready;
      case 'moderate':
        return ReadinessLevel.moderate;
      default:
        return ReadinessLevel.notReady;
    }
  }
}

enum ItemStatus { ready, limited, notReady }

extension ItemStatusExtension on ItemStatus {
  String get displayName {
    switch (this) {
      case ItemStatus.ready:
        return 'READY';
      case ItemStatus.limited:
        return 'LIMITED';
      case ItemStatus.notReady:
        return 'NOT READY';
    }
  }

  Color get color {
    switch (this) {
      case ItemStatus.ready:
        return const Color(0xFF2E7D32);
      case ItemStatus.limited:
        return const Color(0xFFE65100);
      case ItemStatus.notReady:
        return const Color(0xFFC62828);
    }
  }
}

class HaltReadiness {
  final String id;
  final String name;
  final String dindiName;
  final double latitude;
  final double longitude;
  final int expectedVarkaris;
  final DateTime expectedArrival;
  final int waterCapacityLiters;
  final int foodPacketsAvailable;
  final int sanitationFacilities;
  final int medicalTeams;
  final int crowdMarshals;
  final double readinessScore; // 0 to 100
  final ReadinessLevel readinessLevel;
  final List<String> flaggedDeficits;
  final DateTime lastUpdated;

  const HaltReadiness({
    required this.id,
    required this.name,
    required this.dindiName,
    required this.latitude,
    required this.longitude,
    required this.expectedVarkaris,
    required this.expectedArrival,
    required this.waterCapacityLiters,
    required this.foodPacketsAvailable,
    required this.sanitationFacilities,
    required this.medicalTeams,
    required this.crowdMarshals,
    required this.readinessScore,
    required this.readinessLevel,
    required this.flaggedDeficits,
    required this.lastUpdated,
  });

  ItemStatus get waterStatus {
    if (expectedVarkaris <= 0) return ItemStatus.ready;
    final ratio = waterCapacityLiters / (expectedVarkaris * 3.0);
    if (ratio >= 0.8) return ItemStatus.ready;
    if (ratio >= 0.35) return ItemStatus.limited;
    return ItemStatus.notReady;
  }

  ItemStatus get foodStatus {
    if (expectedVarkaris <= 0) return ItemStatus.ready;
    final ratio = foodPacketsAvailable / expectedVarkaris.toDouble();
    if (ratio >= 0.8) return ItemStatus.ready;
    if (ratio >= 0.35) return ItemStatus.limited;
    return ItemStatus.notReady;
  }

  ItemStatus get sanitationStatus {
    if (expectedVarkaris <= 0) return ItemStatus.ready;
    final ratio = sanitationFacilities / (expectedVarkaris / 100.0);
    if (ratio >= 0.8) return ItemStatus.ready;
    if (ratio >= 0.35) return ItemStatus.limited;
    return ItemStatus.notReady;
  }

  ItemStatus get medicalStatus {
    if (expectedVarkaris <= 0) return ItemStatus.ready;
    final ratio = medicalTeams / (expectedVarkaris / 2000.0);
    if (ratio >= 0.8) return ItemStatus.ready;
    if (ratio >= 0.35) return ItemStatus.limited;
    return ItemStatus.notReady;
  }

  ItemStatus get securityStatus {
    if (expectedVarkaris <= 0) return ItemStatus.ready;
    final ratio = crowdMarshals / (expectedVarkaris / 250.0);
    if (ratio >= 0.8) return ItemStatus.ready;
    if (ratio >= 0.35) return ItemStatus.limited;
    return ItemStatus.notReady;
  }

  // Calculate algorithmic readiness score based on WHO/Disaster Management Wari specs
  static double computeReadinessScore({
    required int expectedVarkaris,
    required int waterLiters,
    required int foodPackets,
    required int toilets,
    required int medicalStaff,
    required int marshals,
  }) {
    if (expectedVarkaris <= 0) return 100.0;

    // Ratios needed:
    // Water: 3 Liters per Varkari
    // Food: 1 packet per Varkari
    // Sanitation: 1 facility per 100 Varkaris
    // Medical: 1 team per 2000 Varkaris
    // Marshals: 1 per 250 Varkaris
    final waterRatio = (waterLiters / (expectedVarkaris * 3.0)).clamp(0.0, 1.0);
    final foodRatio = (foodPackets / expectedVarkaris.toDouble()).clamp(0.0, 1.0);
    final sanitationRatio =
        (toilets / (expectedVarkaris / 100.0)).clamp(0.0, 1.0);
    final medicalRatio =
        (medicalStaff / max(1.0, expectedVarkaris / 2000.0)).clamp(0.0, 1.0);
    final marshalRatio =
        (marshals / (expectedVarkaris / 250.0)).clamp(0.0, 1.0);

    // Weighted formula: Water (30%), Sanitation (25%), Food (20%), Medical (15%), Marshals (10%)
    final total = (waterRatio * 30.0) +
        (sanitationRatio * 25.0) +
        (foodRatio * 20.0) +
        (medicalRatio * 15.0) +
        (marshalRatio * 10.0);

    return double.parse(total.toStringAsFixed(1));
  }

  static List<String> detectDeficits({
    required int expectedVarkaris,
    required int waterLiters,
    required int foodPackets,
    required int toilets,
    required int medicalStaff,
    required int marshals,
  }) {
    final List<String> deficits = [];
    if (waterLiters < expectedVarkaris * 3) {
      deficits.add(
          'Water shortage: ${(expectedVarkaris * 3) - waterLiters} L deficit');
    }
    if (foodPackets < expectedVarkaris) {
      deficits.add('Meals shortage: ${expectedVarkaris - foodPackets} packets deficit');
    }
    if (toilets < expectedVarkaris / 100) {
      deficits.add(
          'Sanitation deficit: ${((expectedVarkaris / 100) - toilets).ceil()} units missing');
    }
    if (medicalStaff < (expectedVarkaris / 2000).ceil()) {
      deficits.add('Inadequate medical response teams');
    }
    if (marshals < expectedVarkaris / 250) {
      deficits.add(
          'Volunteer deficit: ${((expectedVarkaris / 250) - marshals).ceil()} marshals needed');
    }
    return deficits;
  }

  HaltReadiness copyWith({
    String? id,
    String? name,
    String? dindiName,
    double? latitude,
    double? longitude,
    int? expectedVarkaris,
    DateTime? expectedArrival,
    int? waterCapacityLiters,
    int? foodPacketsAvailable,
    int? sanitationFacilities,
    int? medicalTeams,
    int? crowdMarshals,
    double? readinessScore,
    ReadinessLevel? readinessLevel,
    List<String>? flaggedDeficits,
    DateTime? lastUpdated,
  }) {
    return HaltReadiness(
      id: id ?? this.id,
      name: name ?? this.name,
      dindiName: dindiName ?? this.dindiName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      expectedVarkaris: expectedVarkaris ?? this.expectedVarkaris,
      expectedArrival: expectedArrival ?? this.expectedArrival,
      waterCapacityLiters: waterCapacityLiters ?? this.waterCapacityLiters,
      foodPacketsAvailable: foodPacketsAvailable ?? this.foodPacketsAvailable,
      sanitationFacilities: sanitationFacilities ?? this.sanitationFacilities,
      medicalTeams: medicalTeams ?? this.medicalTeams,
      crowdMarshals: crowdMarshals ?? this.crowdMarshals,
      readinessScore: readinessScore ?? this.readinessScore,
      readinessLevel: readinessLevel ?? this.readinessLevel,
      flaggedDeficits: flaggedDeficits ?? this.flaggedDeficits,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dindi_name': dindiName,
      'latitude': latitude,
      'longitude': longitude,
      'expected_varkaris': expectedVarkaris,
      'expected_arrival': expectedArrival.toIso8601String(),
      'water_capacity_liters': waterCapacityLiters,
      'food_packets_available': foodPacketsAvailable,
      'sanitation_facilities': sanitationFacilities,
      'medical_teams': medicalTeams,
      'crowd_marshals': crowdMarshals,
      'readiness_score': readinessScore,
      'readiness_level': readinessLevel.name,
      'flagged_deficits': flaggedDeficits,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory HaltReadiness.fromMap(Map<String, dynamic> map) {
    return HaltReadiness(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dindiName: map['dindi_name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.6775,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 75.3278,
      expectedVarkaris: (map['expected_varkaris'] as num?)?.toInt() ?? 0,
      expectedArrival: map['expected_arrival'] != null
          ? DateTime.tryParse(map['expected_arrival']) ?? DateTime.now()
          : DateTime.now(),
      waterCapacityLiters:
          (map['water_capacity_liters'] as num?)?.toInt() ?? 0,
      foodPacketsAvailable:
          (map['food_packets_available'] as num?)?.toInt() ?? 0,
      sanitationFacilities:
          (map['sanitation_facilities'] as num?)?.toInt() ?? 0,
      medicalTeams: (map['medical_teams'] as num?)?.toInt() ?? 0,
      crowdMarshals: (map['crowd_marshals'] as num?)?.toInt() ?? 0,
      readinessScore: (map['readiness_score'] as num?)?.toDouble() ?? 0.0,
      readinessLevel: ReadinessLevelExtension.fromString(
          map['readiness_level'] ?? 'notReady'),
      flaggedDeficits: List<String>.from(map['flagged_deficits'] ?? []),
      lastUpdated: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : (map['last_updated'] != null
              ? DateTime.tryParse(map['last_updated'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}
