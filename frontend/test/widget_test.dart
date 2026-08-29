import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/main.dart';

void main() {
  testWidgets('SevakConnectApp renders home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SevakConnectApp());
    expect(find.text('SevakConnect'), findsWidgets);
  });
}
