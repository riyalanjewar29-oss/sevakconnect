import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/config/api_config.dart';
import 'package:sevak_connect/core/network/api_client.dart';

void main() {
  group('Incident API Client Tests', () {
    test('ApiConfig produces valid incidents endpoint', () {
      final endpoint = ApiConfig.incidentsEndpoint;
      expect(endpoint, contains('/incidents'));
      expect(endpoint, startsWith('http://'));
    });

    test('IncidentCreateResult correctly models success state', () {
      const result = IncidentCreateResult(
        isSuccess: true,
        incidentId: 'INC-A1B2C3D4',
        status: 'created',
        createdAt: '2026-08-30T01:00:00Z',
      );

      expect(result.isSuccess, isTrue);
      expect(result.incidentId, equals('INC-A1B2C3D4'));
      expect(result.status, equals('created'));
      expect(result.errorMessage, isNull);
    });

    test('IncidentCreateResult correctly models error state', () {
      const result = IncidentCreateResult(
        isSuccess: false,
        errorMessage: 'Network timeout',
      );

      expect(result.isSuccess, isFalse);
      expect(result.incidentId, isNull);
      expect(result.errorMessage, equals('Network timeout'));
    });
  });
}
