import 'package:flutter/foundation.dart';
import '../../core/data/repositories/patient_discovery_repository.dart';
import '../../core/models/ai_insight_model.dart';
import '../../core/models/appointment_model.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/hospital_model.dart';
import '../../core/models/location_model.dart';
import '../../core/models/notification_model.dart';
import '../../core/models/report_model.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/patient_discovery_service.dart';

enum ViewStatus { initial, loading, success, empty, error }

/// Patient Home State Controller
class PatientHomeNotifier extends ChangeNotifier {
  final PatientDiscoveryService _discoveryService;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  GeoLocation _currentLocation = GeoLocation.defaultDemo();
  List<Hospital> _nearbyHospitals = [];
  List<Doctor> _recommendedDoctors = [];
  final List<Appointment> _recentAppointments = [];
  final List<DiagnosticReport> _recentReports = [];
  final List<NotificationRecord> _recentNotifications = [];
  HealthConcernMappingResult? _healthConcernResult;

  PatientHomeNotifier({PatientDiscoveryService? discoveryService})
      : _discoveryService = discoveryService ?? PatientDiscoveryService();

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  GeoLocation get currentLocation => _currentLocation;
  List<Hospital> get nearbyHospitals => _nearbyHospitals;
  List<Doctor> get recommendedDoctors => _recommendedDoctors;
  List<Appointment> get recentAppointments => _recentAppointments;
  List<DiagnosticReport> get recentReports => _recentReports;
  List<NotificationRecord> get recentNotifications => _recentNotifications;
  HealthConcernMappingResult? get healthConcernResult => _healthConcernResult;

  Future<void> loadDashboardData({String patientId = 'PAT-8842'}) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _nearbyHospitals = await _discoveryService.searchHospitals(
        const HospitalSearchQuery(pageSize: 5, sortBy: 'distance'),
      );

      _recommendedDoctors = await _discoveryService.searchDoctors(
        const DoctorSearchQuery(pageSize: 5, sortBy: 'rating'),
      );

      _status = ViewStatus.success;
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to load dashboard: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> updateLocation(GeoLocation newLocation) async {
    _currentLocation = newLocation;
    notifyListeners();
  }

  Future<void> searchHealthConcern(String text) async {
    if (text.trim().isEmpty) {
      _healthConcernResult = null;
      notifyListeners();
      return;
    }

    try {
      _healthConcernResult = await _discoveryService.discoverForHealthConcern(text);
    } catch (e) {
      _errorMessage = 'Discovery failed for concern: ${e.toString()}';
    }
    notifyListeners();
  }
}

/// Hospital Discovery State Controller
class HospitalDiscoveryNotifier extends ChangeNotifier {
  final PatientDiscoveryService _discoveryService;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  HospitalSearchQuery _query = const HospitalSearchQuery();
  List<Hospital> _hospitals = [];

  HospitalDiscoveryNotifier({PatientDiscoveryService? discoveryService})
      : _discoveryService = discoveryService ?? PatientDiscoveryService();

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  HospitalSearchQuery get query => _query;
  List<Hospital> get hospitals => _hospitals;

  Future<void> search(HospitalSearchQuery query) async {
    _query = query;
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _hospitals = await _discoveryService.searchHospitals(_query);
      if (_hospitals.isEmpty) {
        _status = ViewStatus.empty;
      } else {
        _status = ViewStatus.success;
      }
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to search hospitals: ${e.toString()}';
    }
    notifyListeners();
  }

  void updateSearchText(String text) {
    search(_query = HospitalSearchQuery(
      searchText: text,
      departmentId: _query.departmentId,
      emergencyOnly: _query.emergencyOnly,
      minimumRating: _query.minimumRating,
      maximumDistance: _query.maximumDistance,
      bedsAvailable: _query.bedsAvailable,
      icuAvailable: _query.icuAvailable,
      bloodAvailable: _query.bloodAvailable,
      facilityIds: _query.facilityIds,
      openNow: _query.openNow,
      sortBy: _query.sortBy,
    ));
  }
}

/// Doctor Discovery State Controller
class DoctorDiscoveryNotifier extends ChangeNotifier {
  final PatientDiscoveryService _discoveryService;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  DoctorSearchQuery _query = const DoctorSearchQuery();
  List<Doctor> _doctors = [];

  DoctorDiscoveryNotifier({PatientDiscoveryService? discoveryService})
      : _discoveryService = discoveryService ?? PatientDiscoveryService();

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DoctorSearchQuery get query => _query;
  List<Doctor> get doctors => _doctors;

  Future<void> search(DoctorSearchQuery query) async {
    _query = query;
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _doctors = await _discoveryService.searchDoctors(_query);
      if (_doctors.isEmpty) {
        _status = ViewStatus.empty;
      } else {
        _status = ViewStatus.success;
      }
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to search doctors: ${e.toString()}';
    }
    notifyListeners();
  }
}

/// Emergency Recommendation State Controller
class EmergencyRecommendationNotifier extends ChangeNotifier {
  final PatientDiscoveryService _discoveryService;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  List<EmergencyHospitalRecommendation> _recommendations = [];

  EmergencyRecommendationNotifier({PatientDiscoveryService? discoveryService})
      : _discoveryService = discoveryService ?? PatientDiscoveryService();

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<EmergencyHospitalRecommendation> get recommendations => _recommendations;

  Future<void> fetchRecommendations({String? category}) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await _discoveryService.getEmergencyRecommendations(category: category);
      _status = _recommendations.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to load emergency recommendations: ${e.toString()}';
    }
    notifyListeners();
  }
}
