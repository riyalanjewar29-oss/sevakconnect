import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/config/api_config.dart';
import 'package:sevak_connect/core/models/app_alert.dart';
import 'package:sevak_connect/core/models/river_zone.dart';
import 'package:sevak_connect/core/models/crowd_report.dart';

void main() {
  group('River Zones & Alerts Unit Tests', () {
    test('ApiConfig generates valid endpoints for river zones and alerts', () {
      expect(ApiConfig.riverZonesEndpoint, contains('/river/zones'));
      expect(ApiConfig.alertsEndpoint, contains('/alerts'));
      expect(ApiConfig.alertReadEndpoint('ALT-001'), contains('/alerts/ALT-001/read'));
    });

    test('RiverZone calculates status and capacity thresholds accurately', () {
      final safeZone = RiverZone(
        id: 'RIV-001',
        name: 'South Ghat',
        density: CrowdDensity.normal,
        latitude: 17.67,
        longitude: 75.32,
        lastUpdate: DateTime.now(),
        currentHeadcount: 1400,
        safeCapacity: 3000,
        restrictedEntry: false,
      );
      expect(safeZone.calculatedStatus, equals('SAFE'));
      expect(safeZone.isSafe, isTrue);
      expect(safeZone.isCritical, isFalse);

      final moderateZone = RiverZone(
        id: 'RIV-002',
        name: 'Mid Ghat',
        density: CrowdDensity.moderate,
        latitude: 17.67,
        longitude: 75.32,
        lastUpdate: DateTime.now(),
        currentHeadcount: 2100,
        safeCapacity: 3000,
        restrictedEntry: false,
      );
      expect(moderateZone.calculatedStatus, equals('MODERATE'));
      expect(moderateZone.isModerate, isTrue);

      final highZone = RiverZone(
        id: 'RIV-003',
        name: 'Temple Ghat',
        density: CrowdDensity.high,
        latitude: 17.67,
        longitude: 75.32,
        lastUpdate: DateTime.now(),
        currentHeadcount: 2700,
        safeCapacity: 3000,
        restrictedEntry: false,
      );
      expect(highZone.calculatedStatus, equals('HIGH'));
      expect(highZone.isHigh, isTrue);

      final restrictedZone = RiverZone(
        id: 'RIV-004',
        name: 'Deep Channel',
        density: CrowdDensity.critical,
        latitude: 17.67,
        longitude: 75.32,
        lastUpdate: DateTime.now(),
        currentHeadcount: 100,
        safeCapacity: 3000,
        restrictedEntry: true,
      );
      expect(restrictedZone.calculatedStatus, equals('CRITICAL'));
      expect(restrictedZone.isCritical, isTrue);
    });

    test('RiverZone fromMap parses backend payload correctly', () {
      final json = {
        'id': 'RIV-ZN-003',
        'name': 'Deep Water Channel Sandbar',
        'marathi_name': 'खोल पाण्याचा प्रवाह',
        'latitude': 17.6742,
        'longitude': 75.3268,
        'current_headcount': 2600,
        'safe_capacity': 2000,
        'water_speed': 3.4,
        'restricted_entry': true,
        'density': 'critical',
        'safety_warning': 'Entry prohibited beyond red flags',
        'updated_at': '2026-08-30T00:00:00Z',
      };

      final zone = RiverZone.fromMap(json);
      expect(zone.id, equals('RIV-ZN-003'));
      expect(zone.marathiName, equals('खोल पाण्याचा प्रवाह'));
      expect(zone.waterFlowSpeedKmh, equals(3.4));
      expect(zone.restrictedEntry, isTrue);
      expect(zone.calculatedStatus, equals('CRITICAL'));
    });

    test('AppAlert parses JSON and models severity states', () {
      final json = {
        'id': 'ALT-RIV-001',
        'title': 'River Zone 3 Entry Restricted',
        'description': 'Sandbar closed due to high flow speed',
        'type': 'river_safety',
        'severity': 'CRITICAL',
        'location': 'Chandrabhaga Deep Water Sandbar',
        'created_at': '2026-08-30T00:00:00Z',
        'is_read': 0,
      };

      final alert = AppAlert.fromJson(json);
      expect(alert.id, equals('ALT-RIV-001'));
      expect(alert.isCritical, isTrue);
      expect(alert.isRead, isFalse);

      final readAlert = alert.copyWith(isRead: true);
      expect(readAlert.isRead, isTrue);
    });
  });
}
