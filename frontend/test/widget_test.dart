import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/main.dart';

void main() {
  testWidgets('SevakConnectApp renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SevakConnectApp());
    expect(find.byType(SevakConnectApp), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
