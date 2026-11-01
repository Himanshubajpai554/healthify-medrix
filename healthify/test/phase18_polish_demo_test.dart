import 'package:flutter_test/flutter_test.dart';
import 'package:healthify_hospital/core/demo/demo_mode_controller.dart';
import 'package:healthify_hospital/core/data/mock/mock_data_reset_service.dart';
import 'package:healthify_hospital/core/utils/datetime_service.dart';
import 'package:healthify_hospital/core/widgets/freshness_badge.dart';

void main() {
  group('Phase 18 — Healthify Final Frontend Hardening & Demo Readiness Tests', () {
    setUp(() {
      MockDataResetService.resetAllMockData();
    });

    test('1. DemoModeController State Toggle & Execution', () async {
      final demoController = DemoModeController.instance;
      expect(demoController.isDemoMode, isFalse);

      demoController.setDemoMode(true);
      expect(demoController.isDemoMode, isTrue);

      final report = await demoController.executeFullScenario();
      expect(report.allPassed, isTrue);
      expect(report.steps.length, equals(10));
      expect(demoController.lastReport, isNotNull);

      await demoController.resetScenario();
      expect(demoController.lastReport, isNull);
    });

    test('2. FreshnessBadge Relative Time Formatting', () {
      final now = DateTime.now();
      final fiveMinAgo = now.subtract(const Duration(minutes: 5));
      final badgeText = DateTimeService.formatRelativeTime(fiveMinAgo);

      expect(badgeText, equals('Updated 5 min ago'));

      const badge = FreshnessBadge(isLive: true);
      expect(badge.isLive, isTrue);
    });
  });
}
