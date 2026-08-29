import 'package:latlong2/latlong.dart';
import 'crowd_report.dart';

class RiverZone {
  final String id;
  final String name;
  final String marathiName;
  final CrowdDensity density;
  final double latitude;
  final double longitude;
  final DateTime lastUpdate;
  final bool restrictedEntry;
  final DateTime? restrictedAt;
  final String? restrictedBy;
  final int currentHeadcount;
  final int safeCapacity;
  final double waterFlowSpeedKmh;
  final String safetyWarning;

  const RiverZone({
    required this.id,
    required this.name,
    this.marathiName = '',
    required this.density,
    required this.latitude,
    required this.longitude,
    required this.lastUpdate,
    this.restrictedEntry = false,
    this.restrictedAt,
    this.restrictedBy,
    this.currentHeadcount = 0,
    this.safeCapacity = 5000,
    this.waterFlowSpeedKmh = 2.4,
    this.safetyWarning = '',
  });

  LatLng get position => LatLng(latitude, longitude);

  double get capacityPercentage =>
      safeCapacity > 0 ? (currentHeadcount / safeCapacity).clamp(0.0, 1.0) : 0.0;

  RiverZone copyWith({
    String? id,
    String? name,
    String? marathiName,
    CrowdDensity? density,
    double? latitude,
    double? longitude,
    DateTime? lastUpdate,
    bool? restrictedEntry,
    DateTime? restrictedAt,
    String? restrictedBy,
    int? currentHeadcount,
    int? safeCapacity,
    double? waterFlowSpeedKmh,
    String? safetyWarning,
  }) {
    return RiverZone(
      id: id ?? this.id,
      name: name ?? this.name,
      marathiName: marathiName ?? this.marathiName,
      density: density ?? this.density,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      restrictedEntry: restrictedEntry ?? this.restrictedEntry,
      restrictedAt: restrictedAt ?? this.restrictedAt,
      restrictedBy: restrictedBy ?? this.restrictedBy,
      currentHeadcount: currentHeadcount ?? this.currentHeadcount,
      safeCapacity: safeCapacity ?? this.safeCapacity,
      waterFlowSpeedKmh: waterFlowSpeedKmh ?? this.waterFlowSpeedKmh,
      safetyWarning: safetyWarning ?? this.safetyWarning,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'marathi_name': marathiName,
      'density': density.name,
      'latitude': latitude,
      'longitude': longitude,
      'last_update': lastUpdate.toIso8601String(),
      'restricted_entry': restrictedEntry,
      'restricted_at': restrictedAt?.toIso8601String(),
      'restricted_by': restrictedBy,
      'current_headcount': currentHeadcount,
      'safe_capacity': safeCapacity,
      'water_flow_speed_kmh': waterFlowSpeedKmh,
      'safety_warning': safetyWarning,
    };
  }

  factory RiverZone.fromMap(Map<String, dynamic> map) {
    return RiverZone(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      marathiName: map['marathi_name'] ?? '',
      density: CrowdDensityExtension.fromString(map['density'] ?? 'normal'),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 17.6750,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 75.3240,
      lastUpdate: map['last_update'] != null
          ? DateTime.tryParse(map['last_update']) ?? DateTime.now()
          : DateTime.now(),
      restrictedEntry: map['restricted_entry'] ?? false,
      restrictedAt: map['restricted_at'] != null
          ? DateTime.tryParse(map['restricted_at'])
          : null,
      restrictedBy: map['restricted_by'],
      currentHeadcount: (map['current_headcount'] as num?)?.toInt() ?? 0,
      safeCapacity: (map['safe_capacity'] as num?)?.toInt() ?? 5000,
      waterFlowSpeedKmh:
          (map['water_flow_speed_kmh'] as num?)?.toDouble() ?? 2.4,
      safetyWarning: map['safety_warning'] ?? '',
    );
  }
}
