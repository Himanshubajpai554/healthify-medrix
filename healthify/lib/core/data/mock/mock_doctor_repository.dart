import '../repositories/doctor_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/doctor_model.dart';
import 'mock_data_store.dart';

class MockDoctorRepository implements DoctorRepository {
  static MockDoctorRepository Function()? serverpodFactory;
  factory MockDoctorRepository() => serverpodFactory?.call() ?? MockDoctorRepository.fallback();
  MockDoctorRepository.fallback();

  final MockDataStore _store = MockDataStore();

  @override
  Future<List<DoctorItem>> getDoctors() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store.doctors);
  }

  @override
  Future<DoctorItem?> getDoctorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _store.doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DoctorItem> addDoctor(DoctorItem doctor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.doctors.insert(0, doctor);
    return doctor;
  }

  @override
  Future<void> updateDoctorStatus(String doctorId, DoctorStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final doc = await getDoctorById(doctorId);
    if (doc != null) {
      doc.status = status;
    }
  }

  @override
  Future<DoctorSchedule> getDoctorSchedule(String doctorId, String date) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final doc = await getDoctorById(doctorId);
    return DoctorSchedule(
      doctorId: doctorId,
      date: date,
      availableSlots: const ['09:00 AM', '10:30 AM', '02:00 PM', '04:00 PM'],
      bookedSlots: const ['09:30 AM', '11:00 AM', '03:00 PM'],
      shiftHours: doc?.shiftHours ?? '08:00 AM - 04:00 PM',
    );
  }

  @override
  Future<void> linkDoctorAffiliation(DoctorAffiliation affiliation) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> updateDoctorAffiliation(DoctorAffiliation affiliation) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> setDoctorSchedule(DoctorSchedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> requestDoctorLeave(String doctorId, Map<String, dynamic> leaveDetails) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final doc = await getDoctorById(doctorId);
    if (doc != null) {
      doc.status = DoctorStatus.onLeave;
    }
  }

  @override
  Future<DoctorAvailabilityStatus> getDoctorAvailability(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final doc = await getDoctorById(doctorId);
    if (doc == null) return DoctorAvailabilityStatus.offDuty;
    switch (doc.status) {
      case DoctorStatus.available:
        return DoctorAvailabilityStatus.available;
      case DoctorStatus.inSurgery:
        return DoctorAvailabilityStatus.inSurgery;
      case DoctorStatus.busy:
        return DoctorAvailabilityStatus.busy;
      case DoctorStatus.onLeave:
        return DoctorAvailabilityStatus.onLeave;
      case DoctorStatus.offDuty:
        return DoctorAvailabilityStatus.offDuty;
    }
  }

  @override
  Future<int> getDoctorWorkload(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final doc = await getDoctorById(doctorId);
    return doc?.activePatients ?? 10;
  }
}
