import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Centralized API Client for SevakConnect backend communication.
class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

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
