import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/network/api_client.dart';

void main() {
  group('Route Data Models & Serialization Tests', () {
    test('RoutePointData parses JSON correctly', () {
      final json = {'latitude': 17.6740, 'longitude': 75.3260};
      final pt = RoutePointData.fromJson(json);

      expect(pt.latitude, closeTo(17.6740, 0.0001));
      expect(pt.longitude, closeTo(75.3260, 0.0001));
    });

    test('RouteOptionData parses JSON with all scoring and road-snapped fields', () {
      final json = {
        'id': 'route_north_canal',
        'name': 'North Canal Bypass Road',
        'via_road': 'North Canal Road',
        'description': 'Lower congestion perimeter road',
        'distance_km': 2.6,
        'estimated_time_mins': 30,
        'points': [
          {'latitude': 17.7020, 'longitude': 75.2900},
          {'latitude': 17.6890, 'longitude': 75.3120},
          {'latitude': 17.6775, 'longitude': 75.3278},
        ],
        'crowd_penalty': 0.0,
        'crowd_risk': 'low',
        'total_score': 2.6,
        'is_recommended': true,
        'recommendation_reason':
            'This route is 0.5 km longer than the shortest route, but it avoids 2 high-density crowd zones.',
        'affected_reports_count': 0,
        'avoided_hotspots_count': 2,
      };

      final option = RouteOptionData.fromJson(json);

      expect(option.id, equals('route_north_canal'));
      expect(option.name, equals('North Canal Bypass Road'));
      expect(option.viaRoad, equals('North Canal Road'));
      expect(option.distanceKm, equals(2.6));
      expect(option.estimatedTimeMins, equals(30));
      expect(option.crowdPenalty, equals(0.0));
      expect(option.crowdRisk, equals('low'));
      expect(option.totalScore, equals(2.6));
      expect(option.isRecommended, isTrue);
      expect(option.affectedReportsCount, equals(0));
      expect(option.avoidedHotspotsCount, equals(2));
      expect(option.points.length, equals(3));
    });

    test('RouteRecommendResult parses full API response with hotspots list', () {
      final json = {
        'recommended_route': {
          'id': 'route_north_canal',
          'name': 'North Canal Bypass Road',
          'via_road': 'North Canal Road',
          'description': 'Perimeter route',
          'distance_km': 2.6,
          'estimated_time_mins': 30,
          'points': [
            {'latitude': 17.7020, 'longitude': 75.2900},
            {'latitude': 17.6775, 'longitude': 75.3278},
          ],
          'crowd_penalty': 0.0,
          'crowd_risk': 'low',
          'total_score': 2.6,
          'is_recommended': true,
          'recommendation_reason': 'Avoids crowd bottlenecks',
          'affected_reports_count': 0,
          'avoided_hotspots_count': 1,
        },
        'alternatives': [
          {
            'id': 'route_primary',
            'name': 'Main Palkhi Highway (NH-965)',
            'via_road': 'NH-965 Corridor',
            'description': 'Direct highway',
            'distance_km': 2.1,
            'estimated_time_mins': 25,
            'points': [
              {'latitude': 17.7020, 'longitude': 75.2900},
              {'latitude': 17.6775, 'longitude': 75.3278},
            ],
            'crowd_penalty': 9.5,
            'crowd_risk': 'critical',
            'total_score': 11.6,
            'is_recommended': false,
            'recommendation_reason': 'Passes through 1 high-density crowd zone(s).',
            'affected_reports_count': 1,
            'avoided_hotspots_count': 0,
          }
        ],
        'hotspots': [
          {
            'id': 'CRD-57A58667',
            'crowd_level': 'critical',
            'location_name': 'Pandharpur Central Junction',
            'description': 'Heavy congregation near temple gate',
            'estimated_headcount': 850,
            'latitude': 17.6740,
            'longitude': 75.3260,
            'created_at': '2026-08-30T02:00:00Z',
          }
        ],
        'total_options': 2,
        'active_crowd_reports_considered': 1,
        'timestamp': '2026-08-30T02:00:00Z',
      };

      final result = RouteRecommendResult.fromJson(json);

      expect(result.isSuccess, isTrue);
      expect(result.recommendedRoute, isNotNull);
      expect(result.recommendedRoute!.id, equals('route_north_canal'));
      expect(result.recommendedRoute!.viaRoad, equals('North Canal Road'));
      expect(result.alternatives.length, equals(1));
      expect(result.alternatives.first.crowdRisk, equals('critical'));
      expect(result.hotspots.length, equals(1));
      expect(result.hotspots.first.id, equals('CRD-57A58667'));
      expect(result.hotspots.first.locationName, equals('Pandharpur Central Junction'));
    });
  });
}
