import 'package:flutter_test/flutter_test.dart';
import 'package:healthify_hospital/main.dart';

void main() {
  testWidgets('HEALTHIFY Platform smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HealthifyHospitalApp());

    // Verify that branding and Patient Welcome elements render on launch.
    expect(find.text('HEALTHIFY'), findsOneWidget);
    expect(find.text('Verified Healthcare Network'), findsOneWidget);
  });
}
