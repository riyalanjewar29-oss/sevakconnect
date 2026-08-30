import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

enum CrowdLevel {
  normal,
  moderate,
  high,
  critical,
}

class CrowdCondition {
  final String id;
  final String zoneId;
  final CrowdLevel crowdLevel;
  final double? latitude;
  final double? longitude;
  final String reportedBy;
  final String description;
  final DateTime createdAt;

  const CrowdCondition({
    required this.id,
    required this.zoneId,
    required this.crowdLevel,
    this.latitude,
    this.longitude,
    required this.reportedBy,
    required this.description,
    required this.createdAt,
  });

  static CrowdLevel crowdLevelFromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'moderate':
        return CrowdLevel.moderate;
      case 'high':
        return CrowdLevel.high;
      case 'critical':
        return CrowdLevel.critical;
      case 'normal':
      default:
        return CrowdLevel.normal;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zoneId': zoneId,
      'crowdLevel': crowdLevel.name,
      'latitude': latitude,
      'longitude': longitude,
      'reportedBy': reportedBy,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CrowdCondition.fromMap(
    Map<String, dynamic> map, {
    String docId = '',
  }) {
    final rawCreatedAt = map['createdAt'];

    if (rawCreatedAt is! Timestamp) {
      throw const FormatException(
        'CrowdCondition requires a valid Firestore createdAt Timestamp.',
      );
    }

    return CrowdCondition(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      zoneId: map['zoneId'] ?? '',
      crowdLevel: crowdLevelFromString(
        map['crowdLevel'] ?? 'normal',
      ),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      reportedBy: map['reportedBy'] ?? '',
      description: map['description'] ?? '',
      createdAt: rawCreatedAt.toDate(),
    );
  }

  // UI compatibility getters (not written to Firestore).
  String get zone => zoneId;
  String get location => description.isNotEmpty ? description : zoneId;
  DateTime get lastUpdate => createdAt;

  LatLng? get position {
    if (latitude == null || longitude == null) {
      return null;
    }
    return LatLng(latitude!, longitude!);
  }
}
