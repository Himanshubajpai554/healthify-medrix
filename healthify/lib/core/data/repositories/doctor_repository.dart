import '../../models/doctor_model.dart';
import '../../enums/domain_enums.dart';

abstract class DoctorRepository {
  Future<List<DoctorItem>> getDoctors();
  Future<DoctorItem?> getDoctorById(String id);
  Future<DoctorItem> addDoctor(DoctorItem doctor);
  Future<void> updateDoctorStatus(String doctorId, DoctorStatus status);
  Future<DoctorSchedule> getDoctorSchedule(String doctorId, String date);
  Future<void> linkDoctorAffiliation(DoctorAffiliation affiliation);
  Future<void> updateDoctorAffiliation(DoctorAffiliation affiliation);
  Future<void> setDoctorSchedule(DoctorSchedule schedule);
  Future<void> requestDoctorLeave(String doctorId, Map<String, dynamic> leaveDetails);
  Future<DoctorAvailabilityStatus> getDoctorAvailability(String doctorId);
  Future<int> getDoctorWorkload(String doctorId);
}
