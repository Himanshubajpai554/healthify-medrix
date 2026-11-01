import 'package:flutter/foundation.dart';
import '../data/mock/mock_data_reset_service.dart';
import '../services/cross_app_demo_scenario_service.dart';

/// State & Controller for Development & Hackathon Demo Execution
class DemoModeController extends ChangeNotifier {
  static final DemoModeController instance = DemoModeController._internal();
  factory DemoModeController() => instance;
  DemoModeController._internal();

  final CrossAppDemoScenarioService _scenarioService = CrossAppDemoScenarioService();

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  bool _isExecuting = false;
  bool get isExecuting => _isExecuting;

  DemoScenarioExecutionReport? _lastReport;
  DemoScenarioExecutionReport? get lastReport => _lastReport;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  void toggleDemoMode() {
    _isDemoMode = !_isDemoMode;
    notifyListeners();
  }

  void setDemoMode(bool value) {
    _isDemoMode = value;
    notifyListeners();
  }

  /// Runs the full 10-step end-to-end Healthify care scenario
  Future<DemoScenarioExecutionReport> executeFullScenario() async {
    _isExecuting = true;
    notifyListeners();

    try {
      _lastReport = await _scenarioService.runFullCrossAppScenario();
      _currentStepIndex = _lastReport?.steps.length ?? 0;
    } finally {
      _isExecuting = false;
      notifyListeners();
    }

    return _lastReport!;
  }

  /// Resets mock data and clears active scenario execution state
  Future<void> resetScenario() async {
    _isExecuting = true;
    notifyListeners();

    try {
      MockDataResetService.resetAllMockData();
      _lastReport = null;
      _currentStepIndex = 0;
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }
}
