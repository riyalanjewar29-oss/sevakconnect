import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/config/api_config.dart';
import 'package:sevak_connect/core/network/api_client.dart';

void main() {
  test('ApiConfig produces valid health and root endpoints', () {
    expect(ApiConfig.port, 8000);
    expect(ApiConfig.healthEndpoint, contains('/health'));
    expect(ApiConfig.rootEndpoint, contains('/'));
  });

  test('ApiClient verifies backend health check format', () async {
    final result = await ApiClient.instance.checkHealth();
    // Verify result properties are populated without crashing
    expect(result.endpoint, contains('/health'));
    expect(result.status.isNotEmpty, true);
  });
}
