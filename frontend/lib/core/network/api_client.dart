import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/river_zone.dart';
import '../models/app_alert.dart';
import '../models/lost_found_case.dart';
import '../models/halt_readiness.dart';
import '../models/app_task.dart';

/// Centralized API Client for SevakConnect backend communication.
class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  static const String connectionErrorMessage =
      'Unable to connect to the SevakConnect server. Make sure your phone and computer are connected to the same Wi-Fi.';

  final http.Client _client = http.Client();

  /// Checks the backend health by calling GET /health.
  /// Returns a map with `connected: true/false`, `status`, and `message`.
  Future<BackendHealthResult> checkHealth() async {
    try {
      final uri = Uri.parse(ApiConfig.healthEndpoint);
      debugPrint('[ApiClient] Checking backend health at: $uri');
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'unknown';
        final message = data['message'] as String? ?? '';
        return BackendHealthResult(
          isConnected: status == 'ok',
          status: status,
          message: message,
          endpoint: uri.toString(),
        );
      } else {
        return BackendHealthResult(
          isConnected: false,
          status: 'error',
          message: 'HTTP ${response.statusCode}',
          endpoint: uri.toString(),
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] Health check failed: $e');
      return BackendHealthResult(
        isConnected: false,
        status: 'unreachable',
        message: e.toString(),
        endpoint: ApiConfig.healthEndpoint,
      );
    }
  }

  /// Sends a POST request to create an incident in the FastAPI backend.
  Future<IncidentCreateResult> createIncident({
    required String type,
    required String severity,
    String? description,
    required double latitude,
    required double longitude,
    String? reportedBy,
  }) async {
    final uri = Uri.parse(ApiConfig.incidentsEndpoint);
    final payload = {
      'type': type,
      'severity': severity,
      'description': description ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'reported_by': reportedBy ?? 'volunteer_demo',
    };

    try {
      debugPrint('[ApiClient] Creating incident at $uri with: $payload');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return IncidentCreateResult(
          isSuccess: true,
          incidentId: data['incident_id'] as String?,
          status: data['status'] as String?,
          createdAt: data['created_at'] as String?,
        );
      } else {
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody.containsKey('detail')) {
            errorMsg = errBody['detail'].toString();
          }
        } catch (_) {}
        return IncidentCreateResult(
          isSuccess: false,
          errorMessage: errorMsg,
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] createIncident failed: $e');
      return IncidentCreateResult(
        isSuccess: false,
        errorMessage: connectionErrorMessage,
      );
    }
  }

  /// Sends a POST request to record a crowd report in the FastAPI backend.
  Future<CrowdReportCreateResult> createCrowdReport({
    required String crowdLevel,
    int? estimatedHeadcount,
    String? movementDirection,
    String? description,
    required double latitude,
    required double longitude,
    String? reportedBy,
  }) async {
    final uri = Uri.parse(ApiConfig.crowdReportsEndpoint);
    final payload = {
      'crowd_level': crowdLevel.toLowerCase().trim(),
      'estimated_headcount': estimatedHeadcount,
      'movement_direction': movementDirection,
      'description': description ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'reported_by': reportedBy ?? 'volunteer_demo',
    };

    try {
      debugPrint('[ApiClient] Submitting crowd report to $uri with: $payload');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CrowdReportCreateResult(
          isSuccess: true,
          reportId: data['report_id'] as String?,
          status: data['status'] as String?,
          createdAt: data['created_at'] as String?,
        );
      } else {
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody.containsKey('detail')) {
            errorMsg = errBody['detail'].toString();
          }
        } catch (_) {}
        return CrowdReportCreateResult(
          isSuccess: false,
          errorMessage: errorMsg,
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] createCrowdReport failed: $e');
      return CrowdReportCreateResult(
        isSuccess: false,
        errorMessage: connectionErrorMessage,
      );
    }
  }

  /// Fetches all stored crowd reports from the backend.
  Future<List<CrowdReportEntry>> fetchCrowdReports() async {
    final uri = Uri.parse(ApiConfig.crowdReportsEndpoint);
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list.map((item) => CrowdReportEntry.fromJson(item)).toList();
      } else {
        debugPrint('[ApiClient] fetchCrowdReports failed with status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[ApiClient] fetchCrowdReports failed: $e');
      return [];
    }
  }

  /// Fetches summary count of crowd reports grouped by level.
  Future<CrowdSummaryResult?> fetchCrowdSummary() async {
    final uri = Uri.parse(ApiConfig.crowdSummaryEndpoint);
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CrowdSummaryResult(
          total: data['total'] as int? ?? 0,
          normal: data['normal'] as int? ?? 0,
          moderate: data['moderate'] as int? ?? 0,
          high: data['high'] as int? ?? 0,
          critical: data['critical'] as int? ?? 0,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[ApiClient] fetchCrowdSummary failed: $e');
      return null;
    }
  }

  /// Evaluates Wari pilgrimage corridors and requests crowd-aware route recommendations.
  Future<RouteRecommendResult> recommendRoute({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    String? originName,
    String? destinationName,
  }) async {
    final uri = Uri.parse(ApiConfig.routesRecommendEndpoint);
    final payload = {
      'start_lat': startLat,
      'start_lng': startLng,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'origin_name': originName ?? 'Current Location',
      'destination_name': destinationName ?? 'Vitthal Mandir Complex',
    };

    try {
      debugPrint('[ApiClient] Requesting route recommendations from $uri');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RouteRecommendResult.fromJson(data);
      } else {
        return RouteRecommendResult(
          isSuccess: false,
          errorMessage: 'Server responded with HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] recommendRoute failed: $e');
      return RouteRecommendResult(
        isSuccess: false,
        errorMessage: connectionErrorMessage,
      );
    }
  }

  /// Fetches standard corridor origin/destination presets.
  Future<List<RoutePresetData>> fetchRoutePresets() async {
    final uri = Uri.parse(ApiConfig.routePresetsEndpoint);
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list.map((item) => RoutePresetData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchRoutePresets failed: $e');
      return [];
    }
  }

  /// Fetches camp supplies inventory from the backend.
  Future<List<SupplyItemData>> fetchSupplies({String? location}) async {
    String url = ApiConfig.suppliesEndpoint;
    if (location != null && location.isNotEmpty && location != 'All Halts') {
      url += '?location=${Uri.encodeComponent(location)}';
    }
    final uri = Uri.parse(url);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list.map((item) => SupplyItemData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchSupplies failed: $e');
      return [];
    }
  }

  /// Updates or creates a camp supply inventory record.
  Future<SupplyUpdateResult> updateSupply({
    required String resource,
    required int quantity,
    int? requiredQuantity,
    required String location,
    String? unit,
  }) async {
    final uri = Uri.parse(ApiConfig.suppliesUpdateEndpoint);
    final payload = <String, dynamic>{
      'resource': resource,
      'quantity': quantity,
      'location': location,
    };
    if (requiredQuantity != null) {
      payload['required_quantity'] = requiredQuantity;
    }
    if (unit != null) {
      payload['unit'] = unit;
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SupplyUpdateResult(
          isSuccess: true,
          message: data['message'] as String? ?? 'Supply updated successfully.',
          supply: data['supply'] != null ? SupplyItemData.fromJson(data['supply']) : null,
        );
      } else {
        return SupplyUpdateResult(
          isSuccess: false,
          errorMessage: 'Server responded with HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] updateSupply failed: $e');
      return SupplyUpdateResult(
        isSuccess: false,
        errorMessage: 'Network error: could not update supply inventory ($e)',
      );
    }
  }

  /// Fetches operational facilities directory from the backend.
  Future<List<FacilityItemData>> fetchFacilities({String? type}) async {
    String url = ApiConfig.facilitiesEndpoint;
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
      url += '?type=${Uri.encodeComponent(type.toLowerCase())}';
    }
    final uri = Uri.parse(url);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list.map((item) => FacilityItemData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchFacilities failed: $e');
      return [];
    }
  }

  /// Fetches Chandrabhaga Safety Zones from the backend.
  Future<List<RiverZone>> fetchRiverZones() async {
    final uri = Uri.parse(ApiConfig.riverZonesEndpoint);
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list
            .map((item) => RiverZone.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchRiverZones failed: $e');
      return [];
    }
  }

  /// Fetches operational alerts ordered by priority and recency.
  Future<List<AppAlert>> fetchAlerts({
    bool unreadOnly = false,
    String? severity,
  }) async {
    String url = ApiConfig.alertsEndpoint;
    List<String> queryParams = [];
    if (unreadOnly) queryParams.add('unread_only=true');
    if (severity != null &&
        severity.isNotEmpty &&
        severity.toLowerCase() != 'all') {
      queryParams.add('severity=${Uri.encodeComponent(severity)}');
    }
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }
    final uri = Uri.parse(url);

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list
            .map((item) => AppAlert.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchAlerts failed: $e');
      return [];
    }
  }

  /// Marks an alert as read in the backend.
  Future<bool> markAlertAsRead(String alertId) async {
    final uri = Uri.parse(ApiConfig.alertReadEndpoint(alertId));
    try {
      final response =
          await _client.patch(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiClient] markAlertAsRead failed: $e');
      return false;
    }
  }

  /// Sends an Emergency SOS request to the backend.
  Future<IncidentCreateResult> triggerSos({
    required double latitude,
    required double longitude,
    String? reportedBy,
    String? description,
  }) async {
    final uri = Uri.parse(ApiConfig.sosEndpoint);
    final payload = {
      'type': 'sos',
      'severity': 'critical',
      'description': description ?? 'Urgent emergency SOS triggered by volunteer.',
      'latitude': latitude,
      'longitude': longitude,
      'reported_by': reportedBy ?? 'volunteer_demo',
    };

    try {
      debugPrint('[ApiClient] Triggering SOS at $uri with: $payload');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return IncidentCreateResult(
          isSuccess: true,
          incidentId: data['incident_id'] as String?,
          status: data['status'] as String?,
          createdAt: data['created_at'] as String?,
        );
      } else {
        return IncidentCreateResult(
          isSuccess: false,
          errorMessage: 'Server returned HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] triggerSos failed: $e');
      return IncidentCreateResult(
        isSuccess: false,
        errorMessage: 'Network error: unable to broadcast SOS ($e)',
      );
    }
  }

  /// Reports a missing person case to the backend.
  Future<MissingPersonCreateResult> createMissingPerson({
    String? name,
    int? age,
    String? gender,
    required String description,
    required double latitude,
    required double longitude,
    required bool isMinor,
    String? reportedBy,
    String? additionalInfo,
    String? photoUrl,
  }) async {
    final uri = Uri.parse(ApiConfig.missingPersonsEndpoint);
    final payload = {
      'name': name,
      'age': age,
      'gender': gender,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'is_minor': isMinor,
      'reported_by': reportedBy ?? 'volunteer_demo',
      'additional_info': additionalInfo,
      'photo_url': photoUrl,
    };

    try {
      debugPrint('[ApiClient] Reporting missing person at $uri with: $payload');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return MissingPersonCreateResult(
          isSuccess: true,
          caseId: data['case_id'] as String?,
          status: data['status'] as String?,
          createdAt: data['created_at'] as String?,
          alertCreated: data['alert_created'] == true,
        );
      } else {
        return MissingPersonCreateResult(
          isSuccess: false,
          errorMessage: 'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] createMissingPerson failed: $e');
      return MissingPersonCreateResult(
        isSuccess: false,
        errorMessage: 'Network error: could not submit report ($e)',
      );
    }
  }

  /// Fetches volunteer operational tasks from backend.
  Future<List<AppTask>> fetchTasks({String? status}) async {
    String url = ApiConfig.tasksEndpoint;
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      url += '?status=${Uri.encodeComponent(status)}';
    }
    final uri = Uri.parse(url);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list
            .map((item) => AppTask.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchTasks failed: $e');
      return [];
    }
  }

  /// Updates task status (PENDING, IN PROGRESS, COMPLETED).
  Future<AppTask?> updateTaskStatus(String taskId, String newStatus) async {
    final uri = Uri.parse(ApiConfig.taskStatusEndpoint(taskId));
    try {
      final response = await _client
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': newStatus.toUpperCase()}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AppTask.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiClient] updateTaskStatus failed: $e');
      return null;
    }
  }

  /// Fetches missing persons cases from the backend.
  Future<List<LostFoundCase>> fetchMissingPersons({String? status}) async {
    String url = ApiConfig.missingPersonsEndpoint;
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      url += '?status=${Uri.encodeComponent(status)}';
    }
    final uri = Uri.parse(url);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list
            .map((item) => LostFoundCase.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] fetchMissingPersons failed: $e');
      return [];
    }
  }

  /// Fetches all Halts and Camp Readiness data.
  Future<List<HaltReadiness>> fetchHalts() async {
    final uri = Uri.parse(ApiConfig.haltsEndpoint);
    debugPrint('[ApiClient] Fetching halts from $uri');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      debugPrint('[ApiClient] fetchHalts response code: ${response.statusCode}, body length: ${response.body.length}');
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        final result = list
            .map((item) => HaltReadiness.fromMap(item as Map<String, dynamic>))
            .toList();
        debugPrint('[ApiClient] fetchHalts parsed ${result.length} halts');
        return result;
      }
      return [];
    } catch (e, stack) {
      debugPrint('[ApiClient] fetchHalts failed: $e\n$stack');
      return [];
    }
  }

  /// Fetches single halt readiness by ID.
  Future<HaltReadiness?> fetchHaltReadiness(String haltId) async {
    final uri = Uri.parse(ApiConfig.haltReadinessEndpoint(haltId));
    debugPrint('[ApiClient] Fetching single halt readiness from $uri');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return HaltReadiness.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiClient] fetchHaltReadiness failed: $e');
      return null;
    }
  }

  /// Updates resource quantities for a halt and retrieves the recomputed readiness.
  Future<HaltReadiness?> updateHaltReadiness(
    String haltId, {
    int? waterLiters,
    int? foodPackets,
    int? toilets,
    int? medicalTeams,
    int? crowdMarshals,
  }) async {
    final uri = Uri.parse(ApiConfig.haltReadinessEndpoint(haltId));
    final payload = <String, dynamic>{};
    if (waterLiters != null) payload['water_capacity_liters'] = waterLiters;
    if (foodPackets != null) payload['food_packets_available'] = foodPackets;
    if (toilets != null) payload['sanitation_facilities'] = toilets;
    if (medicalTeams != null) payload['medical_teams'] = medicalTeams;
    if (crowdMarshals != null) payload['crowd_marshals'] = crowdMarshals;

    try {
      final response = await _client
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return HaltReadiness.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiClient] updateHaltReadiness failed: $e');
      return null;
    }
  }
}

class MissingPersonCreateResult {
  final bool isSuccess;
  final String? caseId;
  final String? status;
  final String? createdAt;
  final bool alertCreated;
  final String? errorMessage;

  const MissingPersonCreateResult({
    required this.isSuccess,
    this.caseId,
    this.status,
    this.createdAt,
    this.alertCreated = false,
    this.errorMessage,
  });
}

class CrowdReportCreateResult {
  final bool isSuccess;
  final String? reportId;
  final String? status;
  final String? createdAt;
  final String? errorMessage;

  const CrowdReportCreateResult({
    required this.isSuccess,
    this.reportId,
    this.status,
    this.createdAt,
    this.errorMessage,
  });
}

class CrowdSummaryResult {
  final int total;
  final int normal;
  final int moderate;
  final int high;
  final int critical;

  const CrowdSummaryResult({
    required this.total,
    required this.normal,
    required this.moderate,
    required this.high,
    required this.critical,
  });
}

class CrowdReportEntry {
  final String id;
  final String crowdLevel;
  final int? estimatedHeadcount;
  final String? movementDirection;
  final String description;
  final double latitude;
  final double longitude;
  final String reportedBy;
  final DateTime createdAt;

  const CrowdReportEntry({
    required this.id,
    required this.crowdLevel,
    this.estimatedHeadcount,
    this.movementDirection,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.reportedBy,
    required this.createdAt,
  });

  factory CrowdReportEntry.fromJson(Map<String, dynamic> json) {
    return CrowdReportEntry(
      id: json['id'] as String? ?? '',
      crowdLevel: json['crowd_level'] as String? ?? 'normal',
      estimatedHeadcount: json['estimated_headcount'] as int?,
      movementDirection: json['movement_direction'] as String?,
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      reportedBy: json['reported_by'] as String? ?? 'volunteer_demo',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class IncidentCreateResult {
  final bool isSuccess;
  final String? incidentId;
  final String? status;
  final String? createdAt;
  final String? errorMessage;

  const IncidentCreateResult({
    required this.isSuccess,
    this.incidentId,
    this.status,
    this.createdAt,
    this.errorMessage,
  });
}

class BackendHealthResult {
  final bool isConnected;
  final String status;
  final String message;
  final String endpoint;

  const BackendHealthResult({
    required this.isConnected,
    required this.status,
    required this.message,
    required this.endpoint,
  });
}

class RoutePointData {
  final double latitude;
  final double longitude;

  const RoutePointData({
    required this.latitude,
    required this.longitude,
  });

  factory RoutePointData.fromJson(Map<String, dynamic> json) {
    return RoutePointData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class CrowdHotspotDetailData {
  final String id;
  final String crowdLevel;
  final String locationName;
  final String description;
  final int? estimatedHeadcount;
  final double latitude;
  final double longitude;
  final String createdAt;

  const CrowdHotspotDetailData({
    required this.id,
    required this.crowdLevel,
    required this.locationName,
    required this.description,
    this.estimatedHeadcount,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory CrowdHotspotDetailData.fromJson(Map<String, dynamic> json) {
    return CrowdHotspotDetailData(
      id: json['id'] as String? ?? '',
      crowdLevel: json['crowd_level'] as String? ?? 'normal',
      locationName: json['location_name'] as String? ?? 'Wari Corridor',
      description: json['description'] as String? ?? '',
      estimatedHeadcount: json['estimated_headcount'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class RouteOptionData {
  final String id;
  final String name;
  final String viaRoad;
  final String description;
  final double distanceKm;
  final int estimatedTimeMins;
  final List<RoutePointData> points;
  final double crowdPenalty;
  final String crowdRisk;
  final double totalScore;
  final bool isRecommended;
  final String recommendationReason;
  final int affectedReportsCount;
  final int avoidedHotspotsCount;

  const RouteOptionData({
    required this.id,
    required this.name,
    required this.viaRoad,
    required this.description,
    required this.distanceKm,
    required this.estimatedTimeMins,
    required this.points,
    required this.crowdPenalty,
    required this.crowdRisk,
    required this.totalScore,
    required this.isRecommended,
    required this.recommendationReason,
    required this.affectedReportsCount,
    this.avoidedHotspotsCount = 0,
  });

  factory RouteOptionData.fromJson(Map<String, dynamic> json) {
    return RouteOptionData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      viaRoad: json['via_road'] as String? ?? 'Pandharpur Corridor Road',
      description: json['description'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedTimeMins: (json['estimated_time_mins'] as num?)?.toInt() ?? 0,
      points: (json['points'] as List? ?? [])
          .map((p) => RoutePointData.fromJson(p))
          .toList(),
      crowdPenalty: (json['crowd_penalty'] as num?)?.toDouble() ?? 0.0,
      crowdRisk: json['crowd_risk'] as String? ?? 'low',
      totalScore: (json['total_score'] as num?)?.toDouble() ?? 0.0,
      isRecommended: json['is_recommended'] as bool? ?? false,
      recommendationReason: json['recommendation_reason'] as String? ?? '',
      affectedReportsCount: (json['affected_reports_count'] as num?)?.toInt() ?? 0,
      avoidedHotspotsCount: (json['avoided_hotspots_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class RouteRecommendResult {
  final bool isSuccess;
  final RouteOptionData? recommendedRoute;
  final List<RouteOptionData> alternatives;
  final List<CrowdHotspotDetailData> hotspots;
  final int totalOptions;
  final int activeReportsConsidered;
  final String? errorMessage;

  const RouteRecommendResult({
    required this.isSuccess,
    this.recommendedRoute,
    this.alternatives = const [],
    this.hotspots = const [],
    this.totalOptions = 0,
    this.activeReportsConsidered = 0,
    this.errorMessage,
  });

  factory RouteRecommendResult.fromJson(Map<String, dynamic> json) {
    return RouteRecommendResult(
      isSuccess: true,
      recommendedRoute: json['recommended_route'] != null
          ? RouteOptionData.fromJson(json['recommended_route'])
          : null,
      alternatives: (json['alternatives'] as List? ?? [])
          .map((a) => RouteOptionData.fromJson(a))
          .toList(),
      hotspots: (json['hotspots'] as List? ?? [])
          .map((h) => CrowdHotspotDetailData.fromJson(h))
          .toList(),
      totalOptions: (json['total_options'] as num?)?.toInt() ?? 0,
      activeReportsConsidered:
          (json['active_crowd_reports_considered'] as num?)?.toInt() ?? 0,
    );
  }
}

class RoutePresetData {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;

  const RoutePresetData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  factory RoutePresetData.fromJson(Map<String, dynamic> json) {
    return RoutePresetData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'] as String? ?? 'origin',
    );
  }
}

class SupplyItemData {
  final String id;
  final String resource;
  final String resourceName;
  final int quantity;
  final int requiredQuantity;
  final String unit;
  final String location;
  final String status;
  final String updatedAt;

  const SupplyItemData({
    required this.id,
    required this.resource,
    required this.resourceName,
    required this.quantity,
    required this.requiredQuantity,
    required this.unit,
    required this.location,
    required this.status,
    required this.updatedAt,
  });

  bool get isAvailable => status.toUpperCase() == 'AVAILABLE';
  bool get isLow => status.toUpperCase() == 'LOW';
  bool get isCritical => status.toUpperCase() == 'CRITICAL';

  double get fulfillmentRatio =>
      requiredQuantity > 0 ? (quantity / requiredQuantity).clamp(0.0, 1.0) : 1.0;

  factory SupplyItemData.fromJson(Map<String, dynamic> json) {
    return SupplyItemData(
      id: json['id'] as String? ?? '',
      resource: json['resource'] as String? ?? 'water',
      resourceName: json['resource_name'] as String? ?? 'Resource',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      requiredQuantity: (json['required_quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? 'Units',
      location: json['location'] as String? ?? 'Wakhari Phata',
      status: (json['status'] as String? ?? 'AVAILABLE').toUpperCase(),
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class SupplyUpdateResult {
  final bool isSuccess;
  final String? message;
  final SupplyItemData? supply;
  final String? errorMessage;

  const SupplyUpdateResult({
    required this.isSuccess,
    this.message,
    this.supply,
    this.errorMessage,
  });
}

class FacilityItemData {
  final String id;
  final String name;
  final String type;
  final String locationName;
  final double latitude;
  final double longitude;
  final String status;
  final String? description;
  final String? contactInfo;
  final String updatedAt;

  const FacilityItemData({
    required this.id,
    required this.name,
    required this.type,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.description,
    this.contactInfo,
    required this.updatedAt,
  });

  bool get isOpen => status.toUpperCase() == 'OPEN' || status.toUpperCase() == 'AVAILABLE';
  bool get isLimited => status.toUpperCase() == 'LIMITED';
  bool get isClosed => status.toUpperCase() == 'CLOSED';

  factory FacilityItemData.fromJson(Map<String, dynamic> json) {
    return FacilityItemData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      locationName: json['location_name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.6775,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 75.3278,
      status: (json['status'] as String? ?? 'OPEN').toUpperCase(),
      description: json['description'] as String?,
      contactInfo: json['contact_info'] as String?,
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
