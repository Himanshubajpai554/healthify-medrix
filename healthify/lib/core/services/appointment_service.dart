import '../data/repositories/repositories.dart';
import '../enums/domain_enums.dart';
import '../errors/domain_errors.dart';
import '../models/core_models.dart';

class AppointmentService {
  final AppointmentRepository appointmentRepository;
  final DoctorRepository doctorRepository;
  final PatientRepository patientRepository;

  AppointmentService({
    required this.appointmentRepository,
    required this.doctorRepository,
    required this.patientRepository,
  });

  Future<Appointment> scheduleAppointment({
    required String hospitalId,
    required String patientId,
    required String doctorId,
    required String departmentId,
    required DateTime dateTime,
    required String reason,
    String type = 'Consultation',
  }) async {
    final doctors = await doctorRepository.getDoctors();
    final doctorExists = doctors.any((d) => d.id == doctorId);
    if (!doctorExists) {
      throw NotFoundError(entityName: 'Doctor', entityId: doctorId);
    }

    final appointment = Appointment(
      id: 'APT-${DateTime.now().millisecondsSinceEpoch}',
      hospitalId: hospitalId,
      patientId: patientId,
      doctorId: doctorId,
      departmentId: departmentId,
      appointmentDateTime: dateTime,
      status: AppointmentStatus.scheduled,
      reason: reason,
      notes: '',
      type: type,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await appointmentRepository.scheduleAppointment(appointment);
    return appointment;
  }

  Future<AppointmentItem> createWalkIn({
    required String patientName,
    required String doctorName,
    required String department,
    required DateTime dateTime,
    required String reason,
  }) async {
    final item = AppointmentItem(
      id: 'WALK-${DateTime.now().millisecondsSinceEpoch}',
      patientName: patientName,
      doctorName: doctorName,
      department: department,
      dateTime: dateTime,
      status: AppointmentStatus.checkedIn.name,
      type: 'WalkIn',
    );
    return await appointmentRepository.createWalkIn(item);
  }

  Future<void> checkInAppointment(String appointmentId) async {
    await appointmentRepository.checkInAppointment(appointmentId);
  }

  Future<void> startConsultation(String appointmentId) async {
    await appointmentRepository.startConsultation(appointmentId);
  }

  Future<void> completeAppointment(String appointmentId) async {
    await appointmentRepository.completeAppointment(appointmentId);
  }

  Future<void> cancelAppointment(String appointmentId, [String? reason]) async {
    await appointmentRepository.cancelAppointment(appointmentId, reason);
  }

  Future<void> markNoShow(String appointmentId) async {
    await appointmentRepository.markNoShow(appointmentId);
  }

  Future<AppointmentSummary> getSummary() async {
    return await appointmentRepository.getAppointmentSummary();
  }
}
