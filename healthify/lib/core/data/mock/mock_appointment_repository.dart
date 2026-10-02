import '../repositories/appointment_repository.dart';
import '../../models/appointment_model.dart';
import '../../enums/domain_enums.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockAppointmentRepository implements AppointmentRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<AppointmentItem>> getAppointments({AppointmentQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.appointments.toList();

    if (query != null) {
      if (query.searchQuery != null && query.searchQuery!.trim().isNotEmpty) {
        final q = query.searchQuery!.trim().toLowerCase();
        list = list.where((a) =>
            a.patientName.toLowerCase().contains(q) ||
            a.doctorName.toLowerCase().contains(q) ||
            a.id.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q)).toList();
      }

      if (query.status != null) {
        final statusStr = query.status!.name.toLowerCase();
        list = list.where((a) => a.status.toLowerCase() == statusStr).toList();
      }

      if (query.doctorId != null && query.doctorId!.isNotEmpty) {
        list = list.where((a) => a.doctorName.contains(query.doctorId!)).toList();
      }

      if (query.departmentId != null && query.departmentId!.isNotEmpty) {
        list = list.where((a) => a.department.contains(query.departmentId!)).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<AppointmentItem?> getAppointmentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matches = _store.appointments.where((a) => a.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<List<AppointmentItem>> getAppointmentsByDoctor(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.appointments.where((a) => a.doctorName.contains(doctorId) || doctorId.isEmpty).toList();
  }

  @override
  Future<List<AppointmentItem>> getAppointmentsByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.appointments.where((a) => a.patientName.contains(patientId) || patientId.isEmpty).toList();
  }

  @override
  Future<AppointmentItem> bookAppointment(AppointmentItem appointment) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.appointments.insert(0, appointment);
    return appointment;
  }

  @override
  Future<AppointmentItem> createWalkIn(AppointmentItem appointment) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final walkInItem = AppointmentItem(
      id: appointment.id.startsWith('APT') ? appointment.id : 'WALK-${DateTime.now().millisecondsSinceEpoch}',
      patientName: appointment.patientName,
      doctorName: appointment.doctorName,
      department: appointment.department,
      dateTime: appointment.dateTime,
      status: AppointmentStatus.checkedIn.name,
      type: 'WalkIn',
    );
    _store.appointments.insert(0, walkInItem);
    return walkInItem;
  }

  @override
  Future<void> scheduleAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.appointments.insert(
      0,
      AppointmentItem(
        id: appointment.id,
        patientName: appointment.patientName,
        doctorName: appointment.doctorName,
        department: appointment.departmentId,
        dateTime: appointment.appointmentDateTime,
        status: appointment.status.name,
        type: appointment.type,
      ),
    );
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final old = _store.appointments[index];
      _store.appointments[index] = AppointmentItem(
        id: old.id,
        patientName: old.patientName,
        doctorName: old.doctorName,
        department: old.department,
        dateTime: old.dateTime,
        status: status.name,
        type: old.type,
      );
    }
  }

  @override
  Future<void> checkInAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.checkedIn);
  }

  @override
  Future<void> startConsultation(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.inConsultation);
  }

  @override
  Future<void> completeAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.completed);
  }

  @override
  Future<void> cancelAppointment(String appointmentId, [String? reason]) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  @override
  Future<void> markNoShow(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.noShow);
  }

  @override
  Future<AppointmentSummary> getAppointmentSummary() async {
    await Future.delayed(const Duration(milliseconds: 100));
    int scheduled = 0;
    int checkedIn = 0;
    int inConsultation = 0;
    int completed = 0;
    int cancelled = 0;
    int noShow = 0;

    for (final a in _store.appointments) {
      final s = a.status.toLowerCase();
      if (s == 'scheduled') {
        scheduled++;
      } else if (s == 'checkedin' || s == 'checked-in') {
        checkedIn++;
      } else if (s == 'inconsultation' || s == 'in-consultation' || s == 'inprogress') {
        inConsultation++;
      } else if (s == 'completed') {
        completed++;
      } else if (s == 'cancelled') {
        cancelled++;
      } else if (s == 'noshow' || s == 'no-show' || s == 'missed') {
        noShow++;
      }
    }

    return AppointmentSummary(
      total: _store.appointments.length,
      scheduled: scheduled,
      checkedIn: checkedIn,
      inConsultation: inConsultation,
      completed: completed,
      cancelled: cancelled,
      noShow: noShow,
    );
  }
}
