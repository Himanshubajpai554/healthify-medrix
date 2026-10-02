import '../repositories/facility_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/facility_model.dart';
import 'mock_data_store.dart';

class MockFacilityRepository implements FacilityRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<FacilityModel>> getFacilities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store.facilities);
  }

  @override
  Future<FacilityModel?> getFacilityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _store.facilities.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FacilityModel> addFacility(FacilityModel facility) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.facilities.insert(0, facility);
    return facility;
  }

  @override
  Future<void> updateFacility(FacilityModel facility) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.facilities.indexWhere((f) => f.id == facility.id);
    if (index != -1) {
      _store.facilities[index] = facility;
    }
  }

  @override
  Future<void> deleteFacility(String facilityId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.facilities.removeWhere((f) => f.id == facilityId);
  }

  @override
  Future<void> updateFacilityStatus(String facilityId, FacilityStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.facilities.indexWhere((f) => f.id == facilityId);
    if (index != -1) {
      _store.facilities[index] = _store.facilities[index].copyWith(
        availability: status.name,
        lastUpdated: 'Just now',
      );
    }
  }

  @override
  Future<void> setPatientVisibility(String facilityId, bool isVisible) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.facilities.indexWhere((f) => f.id == facilityId);
    if (index != -1) {
      _store.facilities[index] = _store.facilities[index].copyWith(
        isVisibleToPatients: isVisible,
        lastUpdated: 'Just now',
      );
    }
  }
}
