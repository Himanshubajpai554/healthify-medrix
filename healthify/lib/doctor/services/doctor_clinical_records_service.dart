import '../../core/provider/repository_provider.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/patient_profile_models.dart';

/// Doctor-scoped clinical writes built on the authenticated tenant repository.
class DoctorClinicalRecordsService {
  DoctorClinicalRecordsService._();

  static final instance = DoctorClinicalRecordsService._();

  Future<void> saveAvailability(DoctorAvailability status) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    final doctorId = container.currentDoctorId;
    if (records == null || doctorId.isEmpty) {
      throw StateError('Doctor account is not connected to the clinical backend.');
    }
    final now = DateTime.now().toUtc();
    final day = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final key = '$doctorId:$day';
    final existing = await records.get('doctorSchedules', key) ?? <String, dynamic>{};
    await records.save('doctorSchedules', key, {
      ...existing,
      'id': key,
      'doctorId': doctorId,
      'date': day,
      'availabilityStatus': status.name,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> saveAvailabilityConfig(DoctorAvailabilityConfig config) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    final doctorId = container.currentDoctorId;
    if (records == null || doctorId.isEmpty) {
      throw StateError('Doctor account is not connected to the clinical backend.');
    }
    final now = DateTime.now().toUtc();
    final day = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final key = '$doctorId:$day';
    final existing = await records.get('doctorSchedules', key) ?? <String, dynamic>{};
    await records.save('doctorSchedules', key, {
      ...existing,
      'id': key,
      'doctorId': doctorId,
      'date': day,
      'availabilityStatus': config.status.name,
      'workingHoursStart': config.workingHoursStart,
      'workingHoursEnd': config.workingHoursEnd,
      'breakStart': config.breakStart,
      'breakEnd': config.breakEnd,
      'slotDurationMinutes': config.slotDurationMinutes,
      'nextAvailableSlot': config.nextAvailableSlot,
      'workingDays': config.workingDays,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<DoctorAvailabilityConfig?> loadAvailabilityConfig() async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    final doctorId = container.currentDoctorId;
    if (records == null || doctorId.isEmpty) return null;
    final now = DateTime.now().toUtc();
    final day = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final row = await records.get('doctorSchedules', '$doctorId:$day');
    if (row == null) return null;
    final status = DoctorAvailability.values.where((item) => item.name == row['availabilityStatus']).firstOrNull ?? DoctorAvailability.available;
    return DoctorAvailabilityConfig(
      status: status,
      workingHoursStart: '${row['workingHoursStart'] ?? '09:00 AM'}',
      workingHoursEnd: '${row['workingHoursEnd'] ?? '05:00 PM'}',
      breakStart: '${row['breakStart'] ?? '01:00 PM'}',
      breakEnd: '${row['breakEnd'] ?? '02:00 PM'}',
      slotDurationMinutes: (row['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      nextAvailableSlot: '${row['nextAvailableSlot'] ?? ''}',
      workingDays: (row['workingDays'] as List? ?? const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']).map((e) => '$e').toList(),
    );
  }

  Future<List<PatientNoteModel>> getNotes(String patientId) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    if (records == null || container.currentDoctorId.isEmpty) return const [];
    final rows = await records.list('clinicalNotes', limit: 500);
    final notes = rows.where((row) => '${row['patientId'] ?? ''}' == patientId).toList()
      ..sort((a, b) => '${b['createdAt'] ?? ''}'.compareTo('${a['createdAt'] ?? ''}'));
    return notes.map((row) {
      final type = ClinicalNoteType.values.where((value) => value.name == row['noteType']).firstOrNull ?? ClinicalNoteType.internalNote;
      final createdAt = DateTime.tryParse('${row['createdAt'] ?? ''}') ?? DateTime.now();
      return PatientNoteModel(
        id: '${row['id'] ?? ''}',
        date: createdAt.toLocal().toString(),
        authorDoctor: '${row['doctorName'] ?? ''}',
        authorSpecialty: '${row['specialty'] ?? ''}',
        content: '${row['content'] ?? ''}',
        isInternalPrivate: row['isInternalPrivate'] as bool? ?? true,
        noteType: type,
      );
    }).toList(growable: false);
  }

  Future<void> saveNote({
    required PatientModel patient,
    String? patientRecordId,
    required ClinicalNoteType type,
    required String content,
  }) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    final doctorId = container.currentDoctorId;
    if (records == null || doctorId.isEmpty) {
      throw StateError('Doctor account is not connected to the clinical backend.');
    }
    final now = DateTime.now().toUtc();
    final id = 'NOTE-${now.microsecondsSinceEpoch}';
    await records.save('clinicalNotes', id, {
      'id': id,
      'patientId': patientRecordId ?? patient.id,
      'patientName': patient.name,
      'patientMrn': patient.mrn,
      'doctorId': doctorId,
      'authorDoctorId': doctorId,
      'doctorName': container.currentDoctorName,
      'specialty': container.currentDoctorSpecialty,
      'noteType': type.name,
      'isInternalPrivate': type == ClinicalNoteType.internalNote,
      'content': content.trim(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> saveQuickPrescription({
    required PatientModel patient,
    required String medicine,
    required String dosage,
    required String duration,
  }) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    final doctorId = container.currentDoctorId;
    if (records == null || doctorId.isEmpty) {
      throw StateError('Doctor account is not connected to the clinical backend.');
    }
    final now = DateTime.now().toUtc();
    final id = 'RX-${now.microsecondsSinceEpoch}';
    await records.save('prescriptions', id, {
      'id': id,
      'patientId': patient.id,
      'patientName': patient.name,
      'doctorId': doctorId,
      'doctorName': container.currentDoctorName,
      'department': patient.department,
      'prescriptionReference': id,
      'signedAt': now.toIso8601String(),
      'status': 'active',
      'pharmacyFulfillmentStatus': 'pending',
      'medications': [
        {
          'medicationName': medicine.trim(),
          'dosage': dosage.trim(),
          'frequency': dosage.trim(),
          'durationDays': int.tryParse(RegExp(r'\d+').firstMatch(duration)?.group(0) ?? '') ?? 0,
          'instructions': duration.trim(),
        },
      ],
      'clinicalNotes': patient.primaryConcern,
      'instructions': '',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }
}
