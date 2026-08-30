import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/config/api_config.dart';
import 'package:sevak_connect/core/extensions/crowd_level_extension.dart';
import 'package:sevak_connect/core/models/crowd_condition.dart';
import 'package:sevak_connect/core/network/api_client.dart';
import 'package:sevak_connect/core/theme/app_colors.dart';

void main() {
  group('Crowd API & Model Unit Tests', () {
    test('ApiConfig generates valid crowd endpoints', () {
      expect(ApiConfig.crowdReportsEndpoint, contains('/crowd-reports'));
      expect(ApiConfig.crowdSummaryEndpoint, contains('/crowd-reports/summary'));
    });

    test('CrowdReportCreateResult models success and error states', () {
      const success = CrowdReportCreateResult(
        isSuccess: true,
        reportId: 'CRD-12345678',
        status: 'created',
        createdAt: '2026-08-30T00:00:00Z',
      );
      expect(success.isSuccess, isTrue);
      expect(success.reportId, equals('CRD-12345678'));

      const failure = CrowdReportCreateResult(
        isSuccess: false,
        errorMessage: 'Connection timed out',
      );
      expect(failure.isSuccess, isFalse);
      expect(failure.errorMessage, equals('Connection timed out'));
    });

    test('CrowdReportEntry deserializes backend JSON correctly', () {
      final json = {
        'id': 'CRD-ABCDEF12',
        'crowd_level': 'high',
        'estimated_headcount': 750,
        'movement_direction': 'towards_pandharpur',
        'description': 'Heavy flow near temple ghat',
        'latitude': 17.6740,
        'longitude': 75.3260,
        'reported_by': 'Volunteer Ramesh',
        'created_at': '2026-08-30T01:30:00Z',
      };

      final entry = CrowdReportEntry.fromJson(json);
      expect(entry.id, equals('CRD-ABCDEF12'));
      expect(entry.crowdLevel, equals('high'));
      expect(entry.estimatedHeadcount, equals(750));
      expect(entry.movementDirection, equals('towards_pandharpur'));
      expect(entry.latitude, closeTo(17.674, 0.001));
      expect(entry.longitude, closeTo(75.326, 0.001));
      expect(entry.reportedBy, equals('Volunteer Ramesh'));
    });

    test('CrowdLevelExtension produces correct semantic status colors', () {
      expect(CrowdLevel.normal.color, equals(AppColors.statusNormal));
      expect(CrowdLevel.moderate.color, equals(AppColors.statusModerate));
      expect(CrowdLevel.high.color, equals(AppColors.statusHigh));
      expect(CrowdLevel.critical.color, equals(AppColors.statusCritical));

      expect(CrowdLevel.normal.displayName, equals('NORMAL'));
      expect(CrowdLevel.critical.displayName, equals('CRITICAL'));
    });
  });
}
