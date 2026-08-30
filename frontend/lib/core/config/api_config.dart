import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized API configuration for SevakConnect.
///
/// Automatically handles localhost vs Android emulator address mapping:
/// - Android emulator uses http://10.0.2.2:8000
/// - Web and desktop use http://localhost:8000
class ApiConfig {
  ApiConfig._();

  static const int port = 8000;
  static String? _customBaseUrl;

  /// Allows dynamically setting the API base URL at runtime (e.g. for physical devices).
  static void setBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;
    }
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:$port';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }

  // Endpoints
  static String get healthEndpoint => '$baseUrl/health';
  static String get rootEndpoint => '$baseUrl/';
  static String get incidentsEndpoint => '$baseUrl/incidents';
  static String get crowdReportsEndpoint => '$baseUrl/crowd-reports';
  static String get crowdSummaryEndpoint => '$baseUrl/crowd-reports/summary';
  static String get routesRecommendEndpoint => '$baseUrl/routes/recommend';
  static String get routePresetsEndpoint => '$baseUrl/routes/presets';
  static String get suppliesEndpoint => '$baseUrl/supplies';
  static String get suppliesUpdateEndpoint => '$baseUrl/supplies/update';
  static String get facilitiesEndpoint => '$baseUrl/facilities';
  static String get riverZonesEndpoint => '$baseUrl/river/zones';
  static String get alertsEndpoint => '$baseUrl/alerts';
  static String alertReadEndpoint(String id) => '$baseUrl/alerts/$id/read';
  static String get missingPersonsEndpoint => '$baseUrl/missing-persons';
  static String get haltsEndpoint => '$baseUrl/halts';
  static String haltReadinessEndpoint(String id) => '$baseUrl/halts/$id/readiness';
  static String get sosEndpoint => '$baseUrl/sos';
  static String get tasksEndpoint => '$baseUrl/tasks';
  static String taskStatusEndpoint(String id) => '$baseUrl/tasks/$id/status';
}


