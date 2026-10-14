import '../../enums/domain_enums.dart';
import '../../models/ai_insight_model.dart';
import '../../models/doctor_model.dart';
import '../../models/emergency_model.dart';
import '../../models/patient_model.dart';
import '../../queries/domain_queries.dart';
import '../mock/mock_doctor_repository.dart';
import '../repositories/doctor_repository.dart';
import '../repositories/emergency_repository.dart';
import '../repositories/hospital_patient_repository.dart';
import '../repositories/patient_repository.dart';
import 'hospital_operational_repository.dart';

/// Serverpod implementation for hospital-scoped patient identity and stay data.
/// Patient identities remain tenant-scoped because this backend does not yet
/// expose a separate cross-hospital patient identity service.
class ServerpodPatientRepository
    implements PatientRepository, AtomicPatientAdmissionRepository {
  ServerpodPatientRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<PatientItem>> getPatients({PatientQuery? query}) async {
    var patients = (await records.list(
      'patients',
      limit: 500,
    )).map(_patientItem).toList();
    if (query != null) {
      final search = query.searchQuery?.trim().toLowerCase();
      if (search != null && search.isNotEmpty) {
        patients = patients
            .where(
              (p) =>
                  p.name.toLowerCase().contains(search) ||
                  p.id.toLowerCase().contains(search) ||
                  p.ward.toLowerCase().contains(search) ||
                  p.doctorName.toLowerCase().contains(search),
            )
            .toList();
      }
      final status = query.status;
      if (status != null) {
        patients = patients.where((p) => p.status == status).toList();
      }
      final label = query.statusFilter?.toLowerCase();
      if (label != null && label.isNotEmpty && label != 'all statuses') {
        patients = patients
            .where((p) => p.status.name.toLowerCase() == label)
            .toList();
      }
      final blood = query.bloodGroupFilter;
      if (blood != null && blood != 'All Blood Groups') {
        patients = patients
            .where((p) => p.bloodGroup.toLowerCase() == blood.toLowerCase())
            .toList();
      }
      final date = query.admissionDate;
      if (date != null) {
        patients = patients
            .where(
              (p) =>
                  p.admissionDate.year == date.year &&
                  p.admissionDate.month == date.month &&
                  p.admissionDate.day == date.day,
            )
            .toList();
      }
      final offset = query.pagination.offset;
      final end = (offset + query.pagination.pageSize).clamp(
        0,
        patients.length,
      );
      patients = patients.sublist(offset.clamp(0, patients.length), end);
    }
    return List.unmodifiable(patients);
  }

  @override
  Future<PatientItem?> getPatientById(String id) async {
    final row = await records.get('patients', id);
    return row == null ? null : _patientItem(row);
  }

  @override
  Future<List<Patient>> getGlobalPatients() async => (await records.list(
    'patients',
    limit: 500,
  )).map(_patient).toList(growable: false);

  @override
  Future<Patient?> findPatientByMrnOrPhone(String queryStr) async {
    final query = queryStr.trim().toLowerCase();
    if (query.isEmpty) return null;
    final patients = await getGlobalPatients();
    for (final patient in patients) {
      if (patient.id.toLowerCase() == query ||
          patient.phone.toLowerCase() == query ||
          patient.name.toLowerCase().contains(query)) {
        return patient;
      }
    }
    final links = await records.list('patientLinks', limit: 500);
    final link = links
        .where((row) => '${row['mrnNumber']}'.toLowerCase() == query)
        .firstOrNull;
    if (link == null) return null;
    return patients.where((p) => p.id == link['patientId']).firstOrNull;
  }

  @override
  Future<PatientItem> admitPatient(PatientAdmissionRequest request) async {
    final now = DateTime.now().toUtc();
    final existing = request.existingPatientId == null
        ? null
        : await records.get('patients', request.existingPatientId!);
    final id = request.existingPatientId ?? 'PT-${now.microsecondsSinceEpoch}';
    final patient = PatientItem(
      id: id,
      name: request.name,
      age: request.age,
      gender: request.gender,
      bloodGroup: request.bloodGroup,
      ward: request.ward,
      admissionDate: now,
      status: request.status,
      doctorName: request.doctorName,
      vitals: request.vitals,
    );
    final patientRow =
        existing ??
        {
          'id': id,
          'name': request.name,
          'age': request.age,
          'gender': request.gender,
          'bloodGroup': request.bloodGroup,
          'phone': '',
          'email': '',
          'address': '',
          'emergencyContact': '',
          'createdAt': now.toIso8601String(),
        };
    patientRow.addAll({
      'id': id,
      'ward': request.ward,
      'admissionDate': now.toIso8601String(),
      'status': request.status.name,
      'doctorName': request.doctorName,
      'vitals': request.vitals,
      'updatedAt': now.toIso8601String(),
    });
    final linkId = 'HPL-${now.microsecondsSinceEpoch}';
    final admissionId = 'ADM-${now.microsecondsSinceEpoch}';
    await records.createAdmissionBundle(
      patientId: id,
      admissionId: admissionId,
      patient: patientRow,
      patientLink: {
        'id': linkId,
        'hospitalId': records.hospitalKey,
        'patientId': id,
        'mrnNumber': 'MRN-${10000 + now.microsecondsSinceEpoch % 89999}',
        'linkStatus': 'Active',
        'registrationDate': now.toIso8601String(),
        'lastVisitAt': now.toIso8601String(),
        'isPrimary': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
      admission: {
        'id': admissionId,
        'patientId': id,
        'hospitalPatientLinkId': linkId,
        'bedId': '',
        'ward': request.ward,
        'attendingDoctorId': '',
        'doctorName': request.doctorName,
        'departmentId': '',
        'admissionDate': now.toIso8601String(),
        'dischargeDate': null,
        'admissionType': 'Emergency',
        'admissionStatus': AdmissionStatus.admitted.name,
        'reason': 'Hospital intake',
        'diagnosis': 'Pending clinical evaluation',
        'vitals': request.vitals,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
    );
    return patient;
  }

  @override
  Future<void> createAdmissionBundle({
    required PatientItem patient,
    required HospitalPatientLink link,
    required Admission admission,
  }) async {
    final now = DateTime.now().toUtc();
    final row =
        await records.get('patients', patient.id) ??
        {
          'id': patient.id,
          'name': patient.name,
          'age': patient.age,
          'gender': patient.gender,
          'bloodGroup': patient.bloodGroup,
          'phone': '',
          'email': '',
          'address': '',
          'emergencyContact': '',
          'createdAt': now.toIso8601String(),
        };
    row.addAll({
      'ward': patient.ward,
      'admissionDate': patient.admissionDate.toIso8601String(),
      'status': patient.status.name,
      'doctorName': patient.doctorName,
      'vitals': patient.vitals,
      'updatedAt': now.toIso8601String(),
    });
    await records.createAdmissionBundle(
      patientId: patient.id,
      admissionId: admission.id,
      patient: row,
      patientLink: {
        'id': link.id,
        'hospitalId': records.hospitalKey,
        'patientId': link.patientId,
        'mrnNumber': link.mrnNumber,
        'linkStatus': link.linkStatus,
        'registrationDate': link.registrationDate.toIso8601String(),
        'lastVisitAt': link.lastVisitAt?.toIso8601String(),
        'isPrimary': link.isPrimary,
        'createdAt': link.createdAt.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
      admission: {
        'id': admission.id,
        'patientId': admission.patientId,
        'hospitalPatientLinkId': admission.hospitalPatientLinkId,
        'bedId': admission.bedId,
        'ward': admission.ward,
        'attendingDoctorId': admission.attendingDoctorId,
        'doctorName': admission.doctorName,
        'departmentId': admission.departmentId,
        'admissionDate': admission.admissionDate.toIso8601String(),
        'dischargeDate': null,
        'admissionType': admission.admissionType,
        'admissionStatus': admission.admissionStatus.name,
        'reason': admission.reason,
        'diagnosis': admission.diagnosis,
        'vitals': admission.vitals,
        'clinicalNotes': admission.clinicalNotes,
        'createdAt': admission.createdAt.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
    );
  }

  @override
  Future<void> updatePatient(PatientItem patient) async {
    final row = await records.get('patients', patient.id);
    if (row == null) throw StateError('Patient not found.');
    row.addAll({
      'name': patient.name,
      'age': patient.age,
      'gender': patient.gender,
      'bloodGroup': patient.bloodGroup,
      'ward': patient.ward,
      'admissionDate': patient.admissionDate.toIso8601String(),
      'status': patient.status.name,
      'doctorName': patient.doctorName,
      'vitals': patient.vitals,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
    await records.save('patients', patient.id, row);
  }

  @override
  Future<void> updatePatientStatus(
    String patientId,
    PatientStatus newStatus,
  ) async => _patchPatient(patientId, {'status': newStatus.name});

  @override
  Future<void> updatePatientWard(String patientId, String newWard) async =>
      _patchPatient(patientId, {'ward': newWard});

  @override
  Future<void> dischargePatient(String patientId) async {
    final row = await records.get('patients', patientId);
    if (row == null) throw StateError('Patient not found.');
    final admissions = await records.list('admissions', limit: 500);
    final active = admissions
        .where(
          (a) =>
              a['patientId'] == patientId &&
              a['admissionStatus'] == AdmissionStatus.admitted.name,
        )
        .toList();
    final changes = <String, Map<String, dynamic>>{};
    final bedChanges = <String, Map<String, Map<String, dynamic>>>{};
    for (final admission in active) {
      admission['admissionStatus'] = AdmissionStatus.discharged.name;
      admission['dischargeDate'] = DateTime.now().toUtc().toIso8601String();
      changes['${admission['id']}'] = admission;
      final bedId = '${admission['bedId'] ?? ''}';
      if (bedId.isNotEmpty) {
        for (final collection in const ['beds', 'icu']) {
          final bed = await records.get(collection, bedId);
          if (bed != null && bed['patientId'] == patientId) {
            bed['status'] = 'cleaning';
            bed['patientId'] = null;
            bed['admissionId'] = null;
            bed['updatedAt'] = DateTime.now().toUtc().toIso8601String();
            bedChanges[collection] = {...?bedChanges[collection], bedId: bed};
            break;
          }
        }
      }
    }
    row['status'] = PatientStatus.discharged.name;
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    if (changes.isEmpty) {
      await records.save('patients', patientId, row);
    } else {
      await records.saveBatch({
        'patients': {patientId: row},
        'admissions': changes,
        ...bedChanges,
      });
    }
  }

  @override
  Future<PatientOverviewMetrics> getPatientMetrics(String hospitalId) async {
    final admissions = await records.list('admissions', limit: 500);
    final patients = await records.list('patients', limit: 500);
    final active = admissions
        .where((a) => a['admissionStatus'] == AdmissionStatus.admitted.name)
        .toList();
    final today = DateTime.now();
    bool isToday(Object? value) {
      final date = DateTime.tryParse('$value')?.toLocal();
      return date != null &&
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }

    return PatientOverviewMetrics(
      totalActiveAdmissions: active.length,
      icuPatients: active
          .where((a) => '${a['ward']}'.toLowerCase().contains('icu'))
          .length,
      admissionsToday: admissions
          .where((a) => isToday(a['admissionDate']))
          .length,
      dischargesToday: admissions
          .where(
            (a) =>
                a['admissionStatus'] == AdmissionStatus.discharged.name &&
                isToday(a['dischargeDate']),
          )
          .length,
      observationPatients: patients
          .where((p) => p['status'] == PatientStatus.observation.name)
          .length,
    );
  }

  Future<void> _patchPatient(String id, Map<String, dynamic> changes) async {
    final row = await records.get('patients', id);
    if (row == null) throw StateError('Patient not found.');
    row.addAll(changes);
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('patients', id, row);
  }

  PatientItem _patientItem(Map<String, dynamic> row) => PatientItem(
    id: '${row['id'] ?? row['_key']}',
    name: '${row['name'] ?? ''}',
    age: _int(row['age']),
    gender: '${row['gender'] ?? ''}',
    bloodGroup: '${row['bloodGroup'] ?? ''}',
    ward: '${row['ward'] ?? ''}',
    admissionDate: _date(row['admissionDate'] ?? row['createdAt']),
    status: PatientStatus.values.firstWhere(
      (e) => e.name == row['status'],
      orElse: () => PatientStatus.outpatient,
    ),
    doctorName: '${row['doctorName'] ?? ''}',
    vitals: _stringMap(row['vitals']),
  );

  Patient _patient(Map<String, dynamic> row) => Patient(
    id: '${row['id'] ?? row['_key']}',
    name: '${row['name'] ?? ''}',
    age: _int(row['age']),
    dateOfBirth: row['dateOfBirth'] == null ? null : _date(row['dateOfBirth']),
    gender: '${row['gender'] ?? ''}',
    bloodGroup: '${row['bloodGroup'] ?? ''}',
    phone: '${row['phone'] ?? ''}',
    email: '${row['email'] ?? ''}',
    address: '${row['address'] ?? ''}',
    emergencyContact: '${row['emergencyContact'] ?? ''}',
    profileImage: row['profileImage'] as String?,
    createdAt: _date(row['createdAt'] ?? row['_createdAt']),
    updatedAt: _date(row['updatedAt'] ?? row['_updatedAt']),
  );
}

class ServerpodHospitalPatientRepository implements HospitalPatientRepository {
  ServerpodHospitalPatientRepository(this.records);
  final HospitalOperationalRepository records;
  @override
  Future<List<HospitalPatientLink>> getHospitalPatientLinks(
    String hospitalId,
  ) async => hospitalId != records.hospitalKey
      ? const []
      : (await records.list(
          'patientLinks',
          limit: 500,
        )).map(_link).toList(growable: false);
  @override
  Future<HospitalPatientLink?> getLinkByPatientId(
    String hospitalId,
    String patientId,
  ) async => hospitalId != records.hospitalKey
      ? null
      : (await records.list(
          'patientLinks',
          limit: 500,
        )).where((r) => r['patientId'] == patientId).map(_link).firstOrNull;
  @override
  Future<HospitalPatientLink?> getLinkByMrn(
    String hospitalId,
    String mrnNumber,
  ) async => hospitalId != records.hospitalKey
      ? null
      : (await records.list('patientLinks', limit: 500))
            .where(
              (r) =>
                  '${r['mrnNumber']}'.toLowerCase() == mrnNumber.toLowerCase(),
            )
            .map(_link)
            .firstOrNull;
  @override
  Future<HospitalPatientLink> createLink(HospitalPatientLink link) async {
    if (link.hospitalId != records.hospitalKey) {
      throw StateError('Hospital does not match the active tenant.');
    }
    if ((await getLinkByPatientId(link.hospitalId, link.patientId)) != null) {
      throw StateError('Patient is already linked to this hospital.');
    }
    if ((await getLinkByMrn(link.hospitalId, link.mrnNumber)) != null) {
      throw StateError('MRN is already in use.');
    }
    await records.save('patientLinks', link.id, _json(link));
    return link;
  }

  @override
  Future<void> updateLinkStatus(String linkId, String newStatus) async {
    final row = await records.get('patientLinks', linkId);
    if (row == null) throw StateError('Hospital patient link not found.');
    row['linkStatus'] = newStatus;
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('patientLinks', linkId, row);
  }

  HospitalPatientLink _link(Map<String, dynamic> r) => HospitalPatientLink(
    id: '${r['id']}',
    hospitalId: records.hospitalKey,
    patientId: '${r['patientId']}',
    mrnNumber: '${r['mrnNumber'] ?? ''}',
    linkStatus: '${r['linkStatus'] ?? 'Active'}',
    registrationDate: _date(r['registrationDate'] ?? r['createdAt']),
    lastVisitAt: r['lastVisitAt'] == null ? null : _date(r['lastVisitAt']),
    isPrimary: r['isPrimary'] as bool? ?? true,
    createdAt: _date(r['createdAt']),
    updatedAt: _date(r['updatedAt']),
  );
  Map<String, dynamic> _json(HospitalPatientLink l) => {
    'id': l.id,
    'hospitalId': records.hospitalKey,
    'patientId': l.patientId,
    'mrnNumber': l.mrnNumber,
    'linkStatus': l.linkStatus,
    'registrationDate': l.registrationDate.toIso8601String(),
    'lastVisitAt': l.lastVisitAt?.toIso8601String(),
    'isPrimary': l.isPrimary,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
  };
}

class ServerpodDoctorRepository extends MockDoctorRepository
    implements DoctorRepository {
  ServerpodDoctorRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  @override
  Future<List<DoctorItem>> getDoctors() async => (await records.list(
    'doctors',
    limit: 500,
  )).map(_doctor).toList(growable: false);
  @override
  Future<DoctorItem?> getDoctorById(String id) async {
    final r = await records.get('doctors', id);
    return r == null ? null : _doctor(r);
  }

  @override
  Future<DoctorItem> addDoctor(DoctorItem doctor) async {
    await records.save('doctors', doctor.id, _doctorJson(doctor));
    return doctor;
  }

  @override
  Future<void> updateDoctorStatus(String doctorId, DoctorStatus status) async {
    final r = await records.get('doctors', doctorId);
    if (r == null) throw StateError('Doctor not found.');
    r['status'] = status.name;
    r['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('doctors', doctorId, r);
  }

  @override
  Future<DoctorSchedule> getDoctorSchedule(String doctorId, String date) async {
    final key = '$doctorId:$date';
    final row = await records.get('doctorSchedules', key);
    final doctor = await getDoctorById(doctorId);
    return DoctorSchedule(
      doctorId: doctorId,
      date: date,
      availableSlots: List<String>.from(row?['availableSlots'] ?? const []),
      bookedSlots: List<String>.from(row?['bookedSlots'] ?? const []),
      shiftHours: '${row?['shiftHours'] ?? doctor?.shiftHours ?? ''}',
    );
  }

  @override
  Future<void> linkDoctorAffiliation(DoctorAffiliation affiliation) async =>
      records.save(
        'doctorAffiliations',
        affiliation.id,
        _affiliationJson(affiliation),
      );
  @override
  Future<void> updateDoctorAffiliation(DoctorAffiliation affiliation) async =>
      records.save(
        'doctorAffiliations',
        affiliation.id,
        _affiliationJson(affiliation),
      );
  @override
  Future<void> setDoctorSchedule(DoctorSchedule schedule) async =>
      records.save('doctorSchedules', '${schedule.doctorId}:${schedule.date}', {
        'doctorId': schedule.doctorId,
        'date': schedule.date,
        'availableSlots': schedule.availableSlots,
        'bookedSlots': schedule.bookedSlots,
        'shiftHours': schedule.shiftHours,
      });
  @override
  Future<void> requestDoctorLeave(
    String doctorId,
    Map<String, dynamic> leaveDetails,
  ) async {
    final id = 'leave:$doctorId:${DateTime.now().microsecondsSinceEpoch}';
    await records.save('doctorLeaves', id, {
      'id': id,
      'doctorId': doctorId,
      ...leaveDetails,
      'status': 'requested',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<DoctorAvailabilityStatus> getDoctorAvailability(
    String doctorId,
  ) async {
    final d = await getDoctorById(doctorId);
    return switch (d?.status) {
      DoctorStatus.available => DoctorAvailabilityStatus.available,
      DoctorStatus.inSurgery => DoctorAvailabilityStatus.inSurgery,
      DoctorStatus.busy => DoctorAvailabilityStatus.busy,
      DoctorStatus.onLeave => DoctorAvailabilityStatus.onLeave,
      _ => DoctorAvailabilityStatus.offDuty,
    };
  }

  @override
  Future<int> getDoctorWorkload(String doctorId) async =>
      (await records.list('admissions', limit: 500))
          .where(
            (a) =>
                a['attendingDoctorId'] == doctorId &&
                a['admissionStatus'] == AdmissionStatus.admitted.name,
          )
          .length;
  DoctorItem _doctor(Map<String, dynamic> r) => DoctorItem(
    id: '${r['id'] ?? r['_key']}',
    name: '${r['name'] ?? ''}',
    department: '${r['department'] ?? r['specialization'] ?? ''}',
    status: DoctorStatus.values.firstWhere(
      (e) => e.name == r['status'],
      orElse: () => DoctorStatus.offDuty,
    ),
    activePatients: _int(r['activePatients']),
    phone: '${r['phone'] ?? ''}',
    email: '${r['email'] ?? ''}',
    experienceYears: _int(r['experienceYears']),
    shiftHours: '${r['shiftHours'] ?? ''}',
  );
  Map<String, dynamic> _doctorJson(DoctorItem d) => {
    'id': d.id,
    'hospitalId': records.hospitalKey,
    'name': d.name,
    'department': d.department,
    'specialization': d.department,
    'status': d.status.name,
    'activePatients': d.activePatients,
    'phone': d.phone,
    'email': d.email,
    'experienceYears': d.experienceYears,
    'shiftHours': d.shiftHours,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
  };
  Map<String, dynamic> _affiliationJson(DoctorAffiliation a) => {
    'id': a.id,
    'doctorId': a.doctorId,
    'hospitalId': records.hospitalKey,
    'affiliationStatus': a.affiliationStatus.name,
    'startDate': a.startDate.toIso8601String(),
    'endDate': a.endDate?.toIso8601String(),
    'department': a.department,
    'createdAt': a.createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
  };
}

class ServerpodEmergencyRepository implements EmergencyRepository {
  ServerpodEmergencyRepository(this.records);
  final HospitalOperationalRepository records;
  @override
  Future<List<EmergencyCaseItem>> getEmergencyCases({
    EmergencyQuery? query,
  }) async {
    var cases = (await records.list(
      'emergencies',
      limit: 500,
    )).map(_case).toList();
    if (query != null) {
      final q = query.searchQuery?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        cases = cases
            .where(
              (c) =>
                  c.patientName.toLowerCase().contains(q) ||
                  c.id.toLowerCase().contains(q) ||
                  c.chiefComplaint.toLowerCase().contains(q) ||
                  c.assignedDoctor.toLowerCase().contains(q),
            )
            .toList();
      }
      if (query.status != null) {
        cases = cases.where((c) => c.status == query.status).toList();
      }
      if (query.doctorId?.isNotEmpty == true) {
        cases = cases
            .where((c) => c.assignedDoctor.contains(query.doctorId!))
            .toList();
      }
      if (query.nurseId?.isNotEmpty == true) {
        final rows = await records.list('emergencies', limit: 500);
        final ids = rows
            .where(
              (r) =>
                  r['assignedNurseId'] == query.nurseId ||
                  r['assignedNurse'] == query.nurseId,
            )
            .map((r) => '${r['id'] ?? r['_key']}')
            .toSet();
        cases = cases.where((c) => ids.contains(c.id)).toList();
      }
      if (query.triageLevel != null) {
        final index = TriageLevel.values.indexOf(query.triageLevel!);
        cases = cases.where((c) => c.priority.index == index).toList();
      }
      if (query.minTriageLevel != null) {
        final index = TriageLevel.values.indexOf(query.minTriageLevel!);
        cases = cases.where((c) => c.priority.index <= index).toList();
      }
      if (query.arrivalMode != null) {
        final rows = await records.list('emergencies', limit: 500);
        final ids = rows
            .where(
              (r) =>
                  r['arrivalMode'] == '${query.arrivalMode}' ||
                  r['arrivalMode'] == '${query.arrivalMode}'.split('.').last,
            )
            .map((r) => '${r['id'] ?? r['_key']}')
            .toSet();
        cases = cases.where((c) => ids.contains(c.id)).toList();
      }
      if (query.criticalOnly == true) {
        cases = cases.where((c) => c.priority.index < 2).toList();
      }
      if (query.anonymousOnly == true) {
        cases = cases
            .where((c) => c.patientName.toLowerCase().contains('anonymous'))
            .toList();
      }
      if (query.bayId != null) {
        cases = cases.where((c) => c.locationBed == query.bayId).toList();
      }
    }
    return List.unmodifiable(cases);
  }

  @override
  Future<EmergencyCaseItem?> getEmergencyCaseById(String id) async {
    final r = await records.get('emergencies', id);
    return r == null ? null : _case(r);
  }

  @override
  Future<EmergencyCaseItem> registerEmergencyCase(EmergencyCaseItem c) async {
    await records.save('emergencies', c.id, _json(c));
    return c;
  }

  @override
  Future<EmergencyCaseItem> createAnonymousEmergencyCase(
    EmergencyCaseItem c,
  ) async {
    final item = EmergencyCaseItem(
      id: c.id,
      patientName: 'Anonymous Emergency',
      age: c.age,
      gender: c.gender,
      chiefComplaint: c.chiefComplaint,
      priority: c.priority,
      status: EmergencyStatus.triaged,
      assignedDoctor: c.assignedDoctor,
      arrivalTime: c.arrivalTime,
      locationBed: c.locationBed,
    );
    await records.save('emergencies', item.id, _json(item));
    return item;
  }

  @override
  Future<void> linkPatient(String caseId, String patientId) async => _patch(
    caseId,
    {'patientId': patientId, 'patientName': 'Patient $patientId'},
  );
  @override
  Future<void> assignTriageLevel(String caseId, TriagePriority p) async =>
      _patch(caseId, {
        'priority': p.name,
        'triageLevel': _triage(p),
        'status': EmergencyStatus.triaged.name,
      });
  @override
  Future<void> updateEmergencyStatus(
    String caseId,
    EmergencyStatus status,
  ) async => _patch(caseId, {'status': status.name});
  @override
  Future<void> assignDoctorToEmergency(
    String caseId,
    String doctorName,
  ) async => _patch(caseId, {
    'assignedDoctor': doctorName,
    'status': EmergencyStatus.assigned.name,
  });
  @override
  Future<void> assignNurse(String caseId, String nurseName) async =>
      _patch(caseId, {'assignedNurse': nurseName});
  @override
  Future<void> assignBay(String caseId, String bayName) async =>
      _patch(caseId, {'locationBed': bayName, 'assignedBayId': bayName});
  @override
  Future<EmergencyCapacitySummary> getEmergencyCapacity() async {
    final cases = await getEmergencyCases();
    final beds = await records.list('beds', limit: 500);
    final bays = beds
        .where(
          (b) =>
              '${b['ward'] ?? b['department'] ?? ''}'.toLowerCase().contains(
                'emergency',
              ) ||
              '${b['bedType'] ?? ''}'.toLowerCase().contains('emergency'),
        )
        .toList();
    int count(String status) => bays.where((b) => b['status'] == status).length;
    return EmergencyCapacitySummary(
      totalBays: bays.length,
      availableBays: count('available'),
      occupiedBays: count('occupied'),
      cleaningBays: count('cleaning'),
      maintenanceBays: count('maintenance'),
      criticalCases: cases.where((c) => c.priority.index < 2).length,
      waitingCases: cases
          .where(
            (c) =>
                c.status == EmergencyStatus.waiting ||
                c.status == EmergencyStatus.arrived,
          )
          .length,
      inTreatmentCases: cases
          .where(
            (c) =>
                c.status == EmergencyStatus.inTreatment ||
                c.status == EmergencyStatus.assigned,
          )
          .length,
    );
  }

  @override
  Future<List<EmergencyHospitalRecommendation>>
  getHospitalRecommendations() async => const [];
  @override
  Future<void> dischargeEmergencyCase(String caseId) async =>
      updateEmergencyStatus(caseId, EmergencyStatus.discharged);
  Future<void> _patch(String id, Map<String, dynamic> values) async {
    final r = await records.get('emergencies', id);
    if (r == null) throw StateError('Emergency case not found.');
    r.addAll(values);
    r['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('emergencies', id, r);
  }

  EmergencyCaseItem _case(Map<String, dynamic> r) {
    final priorityName = '${r['priority'] ?? ''}';
    final triage = '${r['triageLevel'] ?? ''}';
    final priority =
        TriagePriority.values
            .where((e) => e.name == priorityName)
            .firstOrNull ??
        switch (triage) {
          'level1Immediate' => TriagePriority.level1Resuscitation,
          'level2Emergent' => TriagePriority.level2Emergent,
          'level3Urgent' => TriagePriority.level3Urgent,
          'level4LessUrgent' => TriagePriority.level4LessUrgent,
          _ => TriagePriority.level5NonUrgent,
        };
    return EmergencyCaseItem(
      id: '${r['id'] ?? r['_key']}',
      patientName:
          '${r['patientName'] ?? (r['patientId'] == null ? 'Anonymous Emergency' : 'Patient ${r['patientId']}')}',
      age: _int(r['age']),
      gender: '${r['gender'] ?? ''}',
      chiefComplaint: '${r['chiefComplaint'] ?? ''}',
      priority: priority,
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == r['status'],
        orElse: () => EmergencyStatus.arrived,
      ),
      assignedDoctor: '${r['assignedDoctor'] ?? r['assignedDoctorId'] ?? ''}',
      arrivalTime: '${r['arrivalTime'] ?? r['createdAt'] ?? ''}',
      locationBed: '${r['locationBed'] ?? r['assignedBayId'] ?? ''}',
    );
  }

  Map<String, dynamic> _json(EmergencyCaseItem c) => {
    'id': c.id,
    'hospitalId': records.hospitalKey,
    'patientName': c.patientName,
    'age': c.age,
    'gender': c.gender,
    'chiefComplaint': c.chiefComplaint,
    'priority': c.priority.name,
    'triageLevel': _triage(c.priority),
    'status': c.status.name,
    'assignedDoctor': c.assignedDoctor,
    'arrivalTime': c.arrivalTime,
    'locationBed': c.locationBed,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
  };
  String _triage(TriagePriority p) => switch (p) {
    TriagePriority.level1Resuscitation => 'level1Immediate',
    TriagePriority.level2Emergent => 'level2Emergent',
    TriagePriority.level3Urgent => 'level3Urgent',
    TriagePriority.level4LessUrgent => 'level4LessUrgent',
    TriagePriority.level5NonUrgent => 'level5NonUrgent',
  };
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
DateTime _date(Object? value) =>
    DateTime.tryParse('$value') ?? DateTime.now().toUtc();
Map<String, String> _stringMap(Object? value) =>
    (value as Map? ?? const {}).map((k, v) => MapEntry('$k', '$v'));
