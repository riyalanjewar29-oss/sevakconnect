import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sevak_connect_dashboard/services/admin_dashboard_service.dart';
import 'package:sevak_connect_dashboard/screens/dashboard/dashboard_shell.dart';
import 'package:sevak_connect_dashboard/core/theme/app_theme.dart';
import 'package:sevak_connect_dashboard/widgets/metric_card.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Admin/Police Dashboard matches exact UI design and handles zero-data empty states', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminDashboardService(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardShell(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify 5 Navigation Tabs exist
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Live Map'), findsOneWidget);
    expect(find.text('Emergencies'), findsOneWidget);
    expect(find.text('Crowd Monitoring'), findsOneWidget);
    expect(find.text('Volunteers'), findsOneWidget);

    // Verify 4 MetricCards on Top Row
    expect(find.byType(MetricCard), findsNWidgets(4));
    expect(find.text('ACTIVE EMERGENCIES'), findsOneWidget);
    expect(find.text('CRITICAL ZONES'), findsOneWidget);
    expect(find.text('ACTIVE VOLUNTEERS'), findsOneWidget);
    expect(find.text('UNRESOLVED INCIDENTS'), findsOneWidget);

    // Verify Middle Row Cards
    expect(find.text('LIVE SITUATION'), findsOneWidget);
    expect(find.text('RECENT EMERGENCIES'), findsOneWidget);
    expect(find.text('No active emergencies'), findsNWidgets(2));

    // Verify Bottom Row Cards
    expect(find.text('CRITICAL ALERTS'), findsOneWidget);
    expect(find.text('CROWD STATUS SUMMARY'), findsOneWidget);
    expect(find.text('VOLUNTEER STATUS SUMMARY'), findsOneWidget);
    expect(find.text('No critical alerts'), findsOneWidget);

    // Switch to Emergencies Tab
    await tester.tap(find.text('Emergencies'));
    await tester.pumpAndSettle();
    expect(find.text('Emergency Incident Monitoring'), findsOneWidget);
    expect(find.text('No emergency reports found'), findsOneWidget);

    // Switch to Crowd Monitoring Tab
    await tester.tap(find.text('Crowd Monitoring'));
    await tester.pumpAndSettle();
    expect(find.text('Crowd Density & Sector Monitoring'), findsOneWidget);
    expect(find.text('No crowd condition reports found'), findsOneWidget);

    // Switch to Volunteers Tab
    await tester.tap(find.text('Volunteers'));
    await tester.pumpAndSettle();
    expect(find.text('Volunteer Force Deployment Roster'), findsOneWidget);
    expect(find.text('No volunteers registered or on duty'), findsOneWidget);
  });
}
