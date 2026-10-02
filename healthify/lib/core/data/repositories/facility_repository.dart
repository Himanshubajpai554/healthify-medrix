import '../../enums/domain_enums.dart';
import '../../models/facility_model.dart';

abstract class FacilityRepository {
  Future<List<FacilityModel>> getFacilities();
  Future<FacilityModel?> getFacilityById(String id);
  Future<FacilityModel> addFacility(FacilityModel facility);
  Future<void> updateFacility(FacilityModel facility);
  Future<void> deleteFacility(String facilityId);
  Future<void> updateFacilityStatus(String facilityId, FacilityStatus status);
  Future<void> setPatientVisibility(String facilityId, bool isVisible);
}
