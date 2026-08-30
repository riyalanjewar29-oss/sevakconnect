import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/config/api_config.dart';
import 'package:sevak_connect/core/network/api_client.dart';

void main() {
  group('Camp Supplies & Facilities Unit Tests', () {
    test('ApiConfig produces valid supplies and facilities endpoints', () {
      expect(ApiConfig.suppliesEndpoint, contains('/supplies'));
      expect(ApiConfig.suppliesUpdateEndpoint, contains('/supplies/update'));
      expect(ApiConfig.facilitiesEndpoint, contains('/facilities'));
    });

    test('SupplyItemData parses JSON and calculates thresholds correctly', () {
      final jsonAvailable = {
        'id': 'SUP-MEA-001',
        'resource': 'food',
        'resource_name': 'Meals / Ration',
        'quantity': 1200,
        'required_quantity': 1000,
        'unit': 'Packets',
        'location': 'Wakhari Phata',
        'status': 'AVAILABLE',
        'updated_at': '2026-08-30T02:00:00Z',
      };

      final supplyAvailable = SupplyItemData.fromJson(jsonAvailable);
      expect(supplyAvailable.isAvailable, isTrue);
      expect(supplyAvailable.isLow, isFalse);
      expect(supplyAvailable.isCritical, isFalse);
      expect(supplyAvailable.fulfillmentRatio, equals(1.0));

      final jsonLow = {
        'id': 'SUP-WAT-001',
        'resource': 'water',
        'resource_name': 'Drinking Water',
        'quantity': 350,
        'required_quantity': 500,
        'unit': 'Liters',
        'location': 'Wakhari Phata',
        'status': 'LOW',
        'updated_at': '2026-08-30T02:00:00Z',
      };

      final supplyLow = SupplyItemData.fromJson(jsonLow);
      expect(supplyLow.isLow, isTrue);
      expect(supplyLow.fulfillmentRatio, closeTo(0.7, 0.01));

      final jsonCritical = {
        'id': 'SUP-MED-001',
        'resource': 'medical',
        'resource_name': 'Medical Kits',
        'quantity': 3,
        'required_quantity': 15,
        'unit': 'Kits',
        'location': 'Wakhari Phata',
        'status': 'CRITICAL',
        'updated_at': '2026-08-30T02:00:00Z',
      };

      final supplyCritical = SupplyItemData.fromJson(jsonCritical);
      expect(supplyCritical.isCritical, isTrue);
      expect(supplyCritical.fulfillmentRatio, closeTo(0.2, 0.01));
    });

    test('FacilityItemData parses JSON correctly', () {
      final json = {
        'id': 'FAC-MED-001',
        'name': 'Wakhari Emergency Medical Tent 1',
        'type': 'medical',
        'location_name': 'Wakhari Phata',
        'latitude': 17.7015,
        'longitude': 75.2905,
        'status': 'OPEN',
        'description': '24/7 volunteer doctors',
        'contact_info': 'Dr. Deshmukh',
        'updated_at': '2026-08-30T02:00:00Z',
      };

      final facility = FacilityItemData.fromJson(json);
      expect(facility.id, equals('FAC-MED-001'));
      expect(facility.name, equals('Wakhari Emergency Medical Tent 1'));
      expect(facility.type, equals('medical'));
      expect(facility.isOpen, isTrue);
      expect(facility.isClosed, isFalse);
      expect(facility.latitude, closeTo(17.7015, 0.0001));
      expect(facility.longitude, closeTo(75.2905, 0.0001));
    });
  });
}
