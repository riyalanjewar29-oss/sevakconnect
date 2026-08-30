import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/models/lost_found_case.dart';
import 'package:sevak_connect/core/models/halt_readiness.dart';

void main() {
  group('LostFoundCase Model Tests', () {
    test('Correctly parses missing person map with minor flag', () {
      final map = {
        'id': 'MP-1001',
        'type': 'person',
        'name': 'Aarav Shinde',
        'age': 8,
        'gender': 'Male',
        'description': 'Wearing yellow kurta and white topi',
        'latitude': 17.7015,
        'longitude': 75.2910,
        'is_minor': true,
        'reported_by': 'volunteer_demo',
        'additional_info': 'Carrying small steel bottle',
        'status': 'searching',
        'created_at': '2026-08-30T04:00:00Z',
        'updated_at': '2026-08-30T04:00:00Z',
      };

      final c = LostFoundCase.fromMap(map);
      expect(c.id, 'MP-1001');
      expect(c.name, 'Aarav Shinde');
      expect(c.age, 8);
      expect(c.gender, 'Male');
      expect(c.isMinor, true);
      expect(c.status, LostFoundStatus.investigating);
      expect(c.position?.latitude, 17.7015);
      expect(c.position?.longitude, 75.2910);
    });

    test('Defaults unprovided fields gracefully', () {
      final map = {
        'id': 'MP-9999',
        'description': 'Unknown lost person',
        'latitude': 17.6750,
        'longitude': 75.3240,
        'status': 'open',
      };

      final c = LostFoundCase.fromMap(map);
      expect(c.id, 'MP-9999');
      expect(c.name, null);
      expect(c.age, null);
      expect(c.isMinor, false);
      expect(c.status, LostFoundStatus.open);
    });
  });

  group('HaltReadiness Algorithmic Scoring Tests', () {
    test('Computes 100% when all requirements fully satisfied', () {
      // 1000 varkaris -> 3000L water, 1000 food, 10 toilets, 1 med, 4 marshals
      final score = HaltReadiness.computeReadinessScore(
        expectedVarkaris: 1000,
        waterLiters: 3000,
        foodPackets: 1000,
        toilets: 10,
        medicalStaff: 1,
        marshals: 4,
      );
      expect(score, 100.0);
      expect(ReadinessLevelExtension.fromScore(score), ReadinessLevel.ready);
    });

    test('Computes partial score when supplies are limited', () {
      // 1000 varkaris -> 1500L water (50%), 500 food (50%), 5 toilets (50%), 1 med (100%), 2 marshals (50%)
      // Weighted: 0.5*30 + 0.5*25 + 0.5*20 + 1.0*15 + 0.5*10 = 15 + 12.5 + 10 + 15 + 5 = 57.5
      final score = HaltReadiness.computeReadinessScore(
        expectedVarkaris: 1000,
        waterLiters: 1500,
        foodPackets: 500,
        toilets: 5,
        medicalStaff: 1,
        marshals: 2,
      );
      expect(score, 57.5);
      expect(ReadinessLevelExtension.fromScore(score), ReadinessLevel.moderate);
    });

    test('Correctly identifies deficits', () {
      final deficits = HaltReadiness.detectDeficits(
        expectedVarkaris: 1000,
        waterLiters: 1000, // Deficit: 2000L
        foodPackets: 800,  // Deficit: 200 packets
        toilets: 2,        // Deficit: 8 toilets
        medicalStaff: 0,   // Missing
        marshals: 1,       // Deficit: 3
      );
      expect(deficits.length, 5);
      expect(deficits[0], contains('Water shortage: 2000 L deficit'));
      expect(deficits[1], contains('Meals shortage: 200 packets deficit'));
    });

    test('Correctly determines ItemStatus for checklist categories', () {
      final halt = HaltReadiness(
        id: 'HLT-WAK-001',
        name: 'Wakhari Phata',
        dindiName: 'Dindi 1',
        latitude: 17.7015,
        longitude: 75.2905,
        expectedVarkaris: 1000,
        expectedArrival: DateTime.now(),
        waterCapacityLiters: 3000, // 100% -> ready
        foodPacketsAvailable: 500, // 50% -> limited
        sanitationFacilities: 10,  // 100% -> ready
        medicalTeams: 0,           // 0% -> notReady
        crowdMarshals: 4,          // 100% -> ready
        readinessScore: 72.5,
        readinessLevel: ReadinessLevel.moderate,
        flaggedDeficits: [],
        lastUpdated: DateTime.now(),
      );

      expect(halt.waterStatus, ItemStatus.ready);
      expect(halt.foodStatus, ItemStatus.limited);
      expect(halt.sanitationStatus, ItemStatus.ready);
      expect(halt.medicalStatus, ItemStatus.notReady);
      expect(halt.securityStatus, ItemStatus.ready);
    });
  });
}
