import '../../models/appointment_model.dart';
import '../../enums/domain_enums.dart';
import '../../queries/domain_queries.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentItem>> getAppointments({AppointmentQuery? query});
  Future<AppointmentItem?> getAppointmentById(String id);
  Future<List<AppointmentItem>> getAppointmentsByDoctor(String doctorId);
  Future<List<AppointmentItem>> getAppointmentsByPatient(String patientId);
  Future<AppointmentItem> bookAppointment(AppointmentItem appointment);
  Future<void> scheduleAppointment(Appointment appointment);
  Future<AppointmentItem> createWalkIn(AppointmentItem appointment);
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status);
  Future<void> checkInAppointment(String appointmentId);
  Future<void> startConsultation(String appointmentId);
  Future<void> completeAppointment(String appointmentId);
  Future<void> cancelAppointment(String appointmentId, [String? reason]);
  Future<void> markNoShow(String appointmentId);
  Future<AppointmentSummary> getAppointmentSummary();
}
