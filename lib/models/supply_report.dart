import 'dart:math';

class SupplyReport {
  final String haltId;
  final String haltName;
  final double latitude;
  final double longitude;
  final int mealsAvailable;
  final int mealsRequired;
  final int waterLitersAvailable;
  final int waterLitersRequired;
  final int medicalKitsAvailable;
  final int medicalKitsRequired;
  final DateTime lastInventoryCheck;

  const SupplyReport({
    required this.haltId,
    required this.haltName,
    required this.latitude,
    required this.longitude,
    required this.mealsAvailable,
    required this.mealsRequired,
    required this.waterLitersAvailable,
    required this.waterLitersRequired,
    required this.medicalKitsAvailable,
    required this.medicalKitsRequired,
    required this.lastInventoryCheck,
  });

  int get mealDiff => mealsAvailable - mealsRequired;
  int get waterDiff => waterLitersAvailable - waterLitersRequired;
  int get medicalDiff => medicalKitsAvailable - medicalKitsRequired;

  bool get hasMealShortage => mealDiff < 0;
  bool get hasWaterShortage => waterDiff < 0;
  bool get hasMedicalShortage => medicalDiff < 0;

  bool get hasMealSurplus => mealDiff > 500;
  bool get hasWaterSurplus => waterDiff > 1000;

  SupplyReport copyWith({
    String? haltId,
    String? haltName,
    double? latitude,
    double? longitude,
    int? mealsAvailable,
    int? mealsRequired,
    int? waterLitersAvailable,
    int? waterLitersRequired,
    int? medicalKitsAvailable,
    int? medicalKitsRequired,
    DateTime? lastInventoryCheck,
  }) {
    return SupplyReport(
      haltId: haltId ?? this.haltId,
      haltName: haltName ?? this.haltName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mealsAvailable: mealsAvailable ?? this.mealsAvailable,
      mealsRequired: mealsRequired ?? this.mealsRequired,
      waterLitersAvailable: waterLitersAvailable ?? this.waterLitersAvailable,
      waterLitersRequired: waterLitersRequired ?? this.waterLitersRequired,
      medicalKitsAvailable: medicalKitsAvailable ?? this.medicalKitsAvailable,
      medicalKitsRequired: medicalKitsRequired ?? this.medicalKitsRequired,
      lastInventoryCheck: lastInventoryCheck ?? this.lastInventoryCheck,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'halt_id': haltId,
      'halt_name': haltName,
      'latitude': latitude,
      'longitude': longitude,
      'meals_available': mealsAvailable,
      'meals_required': mealsRequired,
      'water_liters_available': waterLitersAvailable,
      'water_liters_required': waterLitersRequired,
      'medical_kits_available': medicalKitsAvailable,
      'medical_kits_required': medicalKitsRequired,
      'last_inventory_check': lastInventoryCheck.toIso8601String(),
    };
  }

  factory SupplyReport.fromMap(Map<String, dynamic> map) {
    return SupplyReport(
      haltId: map['halt_id'] ?? '',
      haltName: map['halt_name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.6775,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 75.3278,
      mealsAvailable: (map['meals_available'] as num?)?.toInt() ?? 0,
      mealsRequired: (map['meals_required'] as num?)?.toInt() ?? 0,
      waterLitersAvailable:
          (map['water_liters_available'] as num?)?.toInt() ?? 0,
      waterLitersRequired:
          (map['water_liters_required'] as num?)?.toInt() ?? 0,
      medicalKitsAvailable:
          (map['medical_kits_available'] as num?)?.toInt() ?? 0,
      medicalKitsRequired:
          (map['medical_kits_required'] as num?)?.toInt() ?? 0,
      lastInventoryCheck: map['last_inventory_check'] != null
          ? DateTime.tryParse(map['last_inventory_check']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class RedistributionSuggestion {
  final String id;
  final String fromHalt;
  final String toHalt;
  final String resourceType; // 'Water' or 'Meals' or 'Medical'
  final int quantity;
  final String unit;
  final double distanceKm;
  final String reason;
  final bool isExecuted;

  const RedistributionSuggestion({
    required this.id,
    required this.fromHalt,
    required this.toHalt,
    required this.resourceType,
    required this.quantity,
    required this.unit,
    required this.distanceKm,
    required this.reason,
    this.isExecuted = false,
  });

  // Calculate distance in km between two geo points (Haversine formula)
  static double calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
