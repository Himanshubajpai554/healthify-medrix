import 'mock_data_store.dart';

/// Reset Service for resetting shared mock dataset during demo scenarios or automated tests.
class MockDataResetService {
  static void resetAllMockData() {
    MockDataStore().resetData();
  }

  static void resetAppointments() {
    final store = MockDataStore();
    store.resetAppointments();
  }
}
