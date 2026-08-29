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

  static String get baseUrl {
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
}
