import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/models/crowd_condition.dart';
import 'package:sevak_connect/core/models/crowd_report.dart';
import 'package:sevak_connect/core/models/darshan_batch.dart';
import 'package:sevak_connect/core/models/emergency_report.dart';
import 'package:sevak_connect/core/models/halt_readiness.dart';
import 'package:sevak_connect/core/models/lost_found_case.dart';
import 'package:sevak_connect/core/models/overview_metrics.dart';
import 'package:sevak_connect/core/models/river_zone.dart';
import 'package:sevak_connect/core/models/supply_report.dart';
import 'package:sevak_connect/core/models/volunteer.dart';

void main() {
  group('Domain Models Unit Tests', () {
    test('CrowdReport serialization and deserialization', () {
      final now = DateTime(2026, 8, 30, 10, 0);
      final report = CrowdReport(
        id: 'cr-101',
        zoneId: 'zone-pandharpur-1',
        zoneName: 'Temple Gate',
        density: CrowdDensity.high,
        latitude: 17.6775,
        longitude: 75.3278,
        timestamp: now,
        reportedBy: 'Volunteer Ramesh',
        estimatedCount: 1500,
      );

      final map = report.toMap();
      expect(map['id'], 'cr-101');
      expect(map['density'], 'high');

      final deserialized = CrowdReport.fromMap(map);
      expect(deserialized.id, report.id);
      expect(deserialized.density, CrowdDensity.high);
      expect(deserialized.position.latitude, 17.6775);
    });

    test('RiverZone calculations and serialization', () {
      final now = DateTime(2026, 8, 30, 10, 0);
      final zone = RiverZone(
        id: 'rz-1',
        name: 'Ghat Area',
        marathiName: 'घाट परिसर',
        density: CrowdDensity.moderate,
        latitude: 17.6750,
        longitude: 75.3240,
        lastUpdate: now,
        currentHeadcount: 2500,
        safeCapacity: 5000,
      );

      expect(zone.capacityPercentage, 0.5);
      final map = zone.toMap();
      expect(map['name'], 'Ghat Area');
      final deserialized = RiverZone.fromMap(map);
      expect(deserialized.currentHeadcount, 2500);
    });

    test('SupplyReport and Redistribution calculations', () {
      final report = SupplyReport(
        haltId: 'halt-1',
        haltName: 'Wakhari Camp',
        latitude: 17.6500,
        longitude: 75.3000,
        mealsAvailable: 5000,
        mealsRequired: 4000,
        waterLitersAvailable: 8000,
        waterLitersRequired: 10000,
        medicalKitsAvailable: 50,
        medicalKitsRequired: 50,
        lastInventoryCheck: DateTime.now(),
      );

      expect(report.mealDiff, 1000);
      expect(report.waterDiff, -2000);
      expect(report.hasMealSurplus, true);
      expect(report.hasWaterShortage, true);

      final dist = RedistributionSuggestion.calculateDistanceKm(
        17.6775, 75.3278, 17.6500, 75.3000,
      );
      expect(dist > 0, true);
    });

    test('HaltReadiness WHO formula computation', () {
      final score = HaltReadiness.computeReadinessScore(
        expectedVarkaris: 1000,
        waterLiters: 3000, // 100%
        foodPackets: 1000, // 100%
        toilets: 10,       // 100%
        medicalStaff: 1,   // 100%
        marshals: 4,       // 100%
      );
      expect(score, 100.0);
    });

    test('DarshanBatch and OverviewMetrics instantiation', () {
      final batch = DarshanBatch(
        id: 'db-1',
        dindi: 'Dindi 108',
        block: 'Block A',
        batch: 'Batch 3',
        tokenRange: '1001-1500',
        status: DarshanStatus.called,
        estimatedTime: '20 mins',
        totalDevotees: 500,
        updatedAt: DateTime.now(),
      );
      expect(batch.status, DarshanStatus.called);

      const metrics = OverviewMetrics(
        activeEmergencies: 2,
        criticalZones: 1,
        activeVolunteers: 45,
      );
      expect(metrics.activeEmergencies, 2);
    });

    test('CrowdCondition, EmergencyReport, LostFoundCase, and Volunteer models', () {
      final condition = CrowdCondition(
        id: 'cc-1',
        zoneId: 'zone-1',
        crowdLevel: CrowdLevel.moderate,
        reportedBy: 'Volunteer A',
        description: 'Moderate rush at gate',
        createdAt: DateTime.now(),
      );
      expect(condition.crowdLevel, CrowdLevel.moderate);

      final emergency = EmergencyReport(
        id: 'em-1',
        type: 'Medical',
        severity: EmergencySeverity.high,
        description: 'First aid needed',
        reportedBy: 'Volunteer B',
        status: EmergencyStatus.open,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(emergency.severity, EmergencySeverity.high);

      final lostFound = LostFoundCase(
        id: 'lf-1',
        type: 'child',
        description: 'Lost child near temple',
        reportedBy: 'Volunteer C',
        isMinor: true,
        status: LostFoundStatus.open,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(lostFound.isMinor, true);

      final volunteer = Volunteer(
        uid: 'vol-123',
        name: 'Ganesh Shinde',
        phone: '9876543210',
        role: 'volunteer',
        status: VolunteerStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(volunteer.status, VolunteerStatus.active);
    });
  });
}
