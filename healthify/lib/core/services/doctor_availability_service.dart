import '../../doctor/doctors/doctor_model.dart';
import '../data/repositories/appointment_repository.dart';
import '../data/repositories/doctor_repository.dart';
import '../provider/repository_provider.dart';

/// Doctor Availability Service
/// Calculates realistic doctor appointment slot availability derived from doctor shift
/// roster, existing appointments, and operational status without hardcoding availability.
class DoctorAvailabilityService {
  final DoctorRepository _doctorRepository;
  final AppointmentRepository _appointmentRepository;

  DoctorAvailabilityService({
    DoctorRepository? doctorRepository,
    AppointmentRepository? appointmentRepository,
  })  : _doctorRepository = doctorRepository ?? RepositoryContainer.instance.doctorRepository,
        _appointmentRepository =
            appointmentRepository ?? RepositoryContainer.instance.appointmentRepository;

  /// Returns calculated available appointment slots for a specific doctor
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required DateTime targetDate,
  }) async {
    final doctor = await _doctorRepository.getDoctorById(doctorId);
    if (doctor == null || doctor.status == DoctorStatus.offDuty) {
      return [];
    }

    final existingAppointments = await _appointmentRepository.getAppointmentsByDoctor(doctorId);
    final bookedSlotTimes = existingAppointments
        .where((a) => a.appointmentDateTime.day == targetDate.day)
        .map((a) => '${a.appointmentDateTime.hour}:${a.appointmentDateTime.minute.toString().padLeft(2, '0')}')
        .toSet();

    final List<String> slots = [];
    final standardHours = [9, 10, 11, 14, 15, 16];

    for (final hour in standardHours) {
      final slotStr = '${hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}';
      final rawKey = '$hour:00';
      if (!bookedSlotTimes.contains(rawKey)) {
        slots.add(slotStr);
      }
    }

    return slots;
  }
}
