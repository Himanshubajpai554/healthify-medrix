import '../../enums/domain_enums.dart';
import '../../models/hospital_model.dart';
import '../../models/facility_model.dart';
import '../../models/bed_model.dart';
import '../../models/appointment_model.dart';
import '../../models/blood_model.dart';
import '../../models/patient_model.dart';
import '../../queries/domain_queries.dart';
import '../repositories/bed_repository.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/blood_repository.dart';
import '../repositories/admission_repository.dart';
import '../../models/staff_model.dart';
import '../repositories/department_repository.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/facility_repository.dart';
import '../repositories/shift_roster_repository.dart';
import '../repositories/staff_repository.dart';
import 'hospital_operational_repository.dart';

class ServerpodDepartmentRepository implements DepartmentRepository {
  ServerpodDepartmentRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<Department>> getDepartments(String hospitalId) async =>
      (await records.list('departments')).map(_department).toList();

  @override
  Future<Department?> getDepartmentById(String id) async {
    final row = await records.get('departments', id);
    return row == null ? null : _department(row);
  }

  @override
  Future<void> createDepartment(Department department) async =>
      records.save('departments', department.id, _departmentJson(department));

  @override
  Future<void> updateDepartment(Department department) async =>
      records.save('departments', department.id, _departmentJson(department));

  @override
  Future<void> updateDepartmentStatus(String departmentId, bool isActive) async {
    final row = await records.get('departments', departmentId);
    if (row == null) throw StateError('Department not found.');
    row['isActive'] = isActive;
    await records.save('departments', departmentId, row);
  }

  @override
  Future<void> assignDepartmentHead(String departmentId, String doctorId) async {
    final row = await records.get('departments', departmentId);
    if (row == null) throw StateError('Department not found.');
    row['headDoctorId'] = doctorId;
    await records.save('departments', departmentId, row);
  }

  Department _department(Map<String, dynamic> value) => Department(
        id: value['id'] as String,
        hospitalId: records.hospitalKey,
        name: value['name'] as String? ?? '',
        code: value['code'] as String? ?? '',
        headDoctorId: value['headDoctorId'] as String?,
        totalStaff: _int(value['totalStaff']),
        description: value['description'] as String? ?? '',
        location: value['location'] as String?,
        contactPhone: value['contactPhone'] as String?,
        isOpdAvailable: value['isOpdAvailable'] as bool? ?? true,
        isEmergencyAvailable: value['isEmergencyAvailable'] as bool? ?? true,
        doctorCount: _int(value['doctorCount']),
        isActive: value['isActive'] as bool? ?? true,
        createdAt: _date(value['createdAt']),
        updatedAt: _date(value['updatedAt']),
      );

  Map<String, dynamic> _departmentJson(Department value) => {
        'id': value.id,
        'name': value.name,
        'code': value.code,
        'headDoctorId': value.headDoctorId,
        'totalStaff': value.totalStaff,
        'description': value.description,
        'location': value.location,
        'contactPhone': value.contactPhone,
        'isOpdAvailable': value.isOpdAvailable,
        'isEmergencyAvailable': value.isEmergencyAvailable,
        'doctorCount': value.doctorCount,
        'isActive': value.isActive,
        'createdAt': value.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
}

class ServerpodStaffRepository implements StaffRepository {
  ServerpodStaffRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<StaffModel>> getStaffList() async =>
      (await records.list('staff')).map(_staff).toList();

  @override
  Future<StaffModel?> getStaffById(String id) async {
    final row = await records.get('staff', id);
    return row == null ? null : _staff(row);
  }

  @override
  Future<StaffModel> addStaff(StaffModel staff) async {
    await records.save('staff', staff.id, _staffJson(staff));
    return staff;
  }

  @override
  Future<void> updateStaff(StaffModel staff) async =>
      records.save('staff', staff.id, _staffJson(staff));

  @override
  Future<void> updateStaffStatus(String staffId, StaffStatus status) async {
    final row = await records.get('staff', staffId);
    if (row == null) throw StateError('Staff member not found.');
    row['status'] = status.name;
    await records.save('staff', staffId, row);
  }

  @override
  Future<void> assignStaffDepartment(String staffId, String departmentId) async {
    final row = await records.get('staff', staffId);
    if (row == null) throw StateError('Staff member not found.');
    row['department'] = departmentId;
    await records.save('staff', staffId, row);
  }

  StaffModel _staff(Map<String, dynamic> value) => StaffModel(
        id: value['id'] as String,
        name: value['name'] as String? ?? '',
        role: StaffRole.values.firstWhere(
          (item) => item.name == value['role'],
          orElse: () => StaffRole.support,
        ),
        department: value['department'] as String? ?? '',
        status: StaffStatus.values.firstWhere(
          (item) => item.name == value['status'],
          orElse: () => StaffStatus.active,
        ),
        phone: value['phone'] as String? ?? '',
        shift: value['shift'] as String? ?? '',
      );

  Map<String, dynamic> _staffJson(StaffModel value) => {
        'id': value.id,
        'name': value.name,
        'role': value.role.name,
        'department': value.department,
        'status': value.status.name,
        'phone': value.phone,
        'shift': value.shift,
      };
}

class ServerpodShiftRosterRepository implements ShiftRosterRepository {
  ServerpodShiftRosterRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<ShiftRoster>> getShiftRoster({String? departmentId, DateTime? date}) async {
    final departmentByStaff = <String, String>{
      for (final staff in await records.list('staff'))
        if (staff['id'] != null && (staff['department'] ?? staff['departmentId']) != null)
          staff['id'].toString(): (staff['department'] ?? staff['departmentId']).toString(),
    };
    final shifts = (await records.list('shifts')).map(_shift).where((shift) {
      final sameDate = date == null ||
          (shift.startTime.year == date.year &&
              shift.startTime.month == date.month &&
              shift.startTime.day == date.day);
      return sameDate && (departmentId == null ||
          shift.ward == departmentId || departmentByStaff[shift.staffId] == departmentId);
    }).toList();
    return shifts;
  }

  @override
  Future<List<ShiftRoster>> getStaffShifts(String staffId) async =>
      (await records.list('shifts'))
          .map(_shift)
          .where((shift) => shift.staffId == staffId)
          .toList();

  @override
  Future<ShiftRoster> createShift(ShiftRoster shift) async {
    await records.save('shifts', shift.id, _shiftJson(shift));
    return shift;
  }

  @override
  Future<void> updateShift(ShiftRoster shift) async =>
      records.save('shifts', shift.id, _shiftJson(shift));

  @override
  Future<void> reassignShift(String shiftId, String newStaffId) async {
    final row = await records.get('shifts', shiftId);
    if (row == null) throw StateError('Shift not found.');
    row['staffId'] = newStaffId;
    await records.save('shifts', shiftId, row);
  }

  @override
  Future<void> cancelShift(String shiftId) async {
    final row = await records.get('shifts', shiftId);
    if (row == null) throw StateError('Shift not found.');
    row['shiftStatus'] = ShiftStatus.cancelled.name;
    await records.save('shifts', shiftId, row);
  }

  @override
  Future<double> getDepartmentCoverage(String departmentId) async {
    final staff = await records.list('staff');
    final activeStaff = staff.where((item) =>
        item['department'] == departmentId && item['status'] != StaffStatus.terminated.name);
    if (activeStaff.isEmpty) return 0;
    final shifts = await records.list('shifts');
    final onShift = shifts.where((item) =>
        activeStaff.any((member) => member['id'] == item['staffId']) &&
        item['shiftStatus'] != ShiftStatus.cancelled.name);
    return (onShift.length / activeStaff.length).clamp(0.0, 1.0);
  }

  ShiftRoster _shift(Map<String, dynamic> value) => ShiftRoster(
        id: value['id'] as String,
        staffId: value['staffId'] as String? ?? '',
        hospitalId: records.hospitalKey,
        startTime: _date(value['startTime']),
        endTime: _date(value['endTime']),
        shiftStatus: ShiftStatus.values.firstWhere(
          (item) => item.name == value['shiftStatus'],
          orElse: () => ShiftStatus.scheduled,
        ),
        ward: value['ward'] as String? ?? '',
        createdAt: _date(value['createdAt']),
        updatedAt: _date(value['updatedAt']),
      );

  Map<String, dynamic> _shiftJson(ShiftRoster value) => {
        'id': value.id,
        'staffId': value.staffId,
        'startTime': value.startTime.toIso8601String(),
        'endTime': value.endTime.toIso8601String(),
        'shiftStatus': value.shiftStatus.name,
        'ward': value.ward,
        'createdAt': value.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
}

class ServerpodFacilityRepository implements FacilityRepository {
  ServerpodFacilityRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<FacilityModel>> getFacilities() async =>
      (await records.list('facilities')).map(_facility).toList();

  @override
  Future<FacilityModel?> getFacilityById(String id) async {
    final row = await records.get('facilities', id);
    return row == null ? null : _facility(row);
  }

  @override
  Future<FacilityModel> addFacility(FacilityModel facility) async {
    await records.save('facilities', facility.id, _facilityJson(facility));
    return facility;
  }

  @override
  Future<void> updateFacility(FacilityModel facility) async =>
      records.save('facilities', facility.id, _facilityJson(facility));

  @override
  Future<void> deleteFacility(String facilityId) async =>
      records.delete('facilities', facilityId);

  @override
  Future<void> updateFacilityStatus(String facilityId, FacilityStatus status) async {
    final row = await records.get('facilities', facilityId);
    if (row == null) throw StateError('Facility not found.');
    row['availability'] = status.name;
    row['lastUpdated'] = DateTime.now().toIso8601String();
    await records.save('facilities', facilityId, row);
  }

  @override
  Future<void> setPatientVisibility(String facilityId, bool isVisible) async {
    final row = await records.get('facilities', facilityId);
    if (row == null) throw StateError('Facility not found.');
    row['isVisibleToPatients'] = isVisible;
    await records.save('facilities', facilityId, row);
  }

  FacilityModel _facility(Map<String, dynamic> row) => FacilityModel(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        category: row['category'] as String? ?? '',
        availability: row['availability'] as String? ?? 'Available',
        capacity: row['capacity'] as String? ?? '0',
        operatingHours: row['operatingHours'] as String? ?? '',
        location: row['location'] as String? ?? '',
        description: row['description'] as String? ?? '',
        isVisibleToPatients: row['isVisibleToPatients'] as bool? ?? false,
        lastUpdated: row['lastUpdated'] as String? ?? '',
      );

  Map<String, dynamic> _facilityJson(FacilityModel value) => {
        'id': value.id,
        'name': value.name,
        'category': value.category,
        'availability': value.availability,
        'capacity': value.capacity,
        'operatingHours': value.operatingHours,
        'location': value.location,
        'description': value.description,
        'isVisibleToPatients': value.isVisibleToPatients,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
}

class ServerpodEquipmentRepository implements EquipmentRepository {
  ServerpodEquipmentRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<Equipment>> getEquipment({String? facilityId, String? departmentId}) async =>
      (await records.list('equipment'))
          .where((row) =>
              (facilityId == null || row['facilityId'] == facilityId) &&
              (departmentId == null || row['departmentId'] == departmentId ||
                  row['department'] == departmentId))
          .map(_equipment)
          .toList();

  @override
  Future<Equipment?> getEquipmentById(String id) async {
    final row = await records.get('equipment', id);
    return row == null ? null : _equipment(row);
  }

  @override
  Future<Equipment> createEquipment(Equipment equipment) async {
    await records.save('equipment', equipment.id, _equipmentJson(equipment));
    return equipment;
  }

  @override
  Future<void> updateEquipment(Equipment equipment) async =>
      records.save('equipment', equipment.id, _equipmentJson(equipment));

  @override
  Future<void> updateEquipmentStatus(String equipmentId, EquipmentStatus status) async {
    final row = await records.get('equipment', equipmentId);
    if (row == null) throw StateError('Equipment not found.');
    row['status'] = status.name;
    row['updatedAt'] = DateTime.now().toIso8601String();
    await records.save('equipment', equipmentId, row);
  }

  Equipment _equipment(Map<String, dynamic> row) => Equipment(
        id: row['id'] as String,
        facilityId: row['facilityId'] as String? ?? '',
        hospitalId: records.hospitalKey,
        name: row['name'] as String? ?? '',
        model: row['model'] as String? ?? '',
        serialNumber: row['serialNumber'] as String? ?? '',
        status: EquipmentStatus.values.firstWhere(
          (item) => item.name == row['status'],
          orElse: () => EquipmentStatus.operational,
        ),
        lastMaintenanceDate: _date(row['lastMaintenanceDate']),
        nextMaintenanceDate: _date(row['nextMaintenanceDate']),
        createdAt: _date(row['createdAt']),
        updatedAt: _date(row['updatedAt']),
      );

  Map<String, dynamic> _equipmentJson(Equipment value) => {
        'id': value.id,
        'facilityId': value.facilityId,
        'name': value.name,
        'model': value.model,
        'serialNumber': value.serialNumber,
        'status': value.status.name,
        'lastMaintenanceDate': value.lastMaintenanceDate.toIso8601String(),
        'nextMaintenanceDate': value.nextMaintenanceDate.toIso8601String(),
        'createdAt': value.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
}

class ServerpodBedRepository implements BedRepository {
  ServerpodBedRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<BedItem>> getBeds({BedQuery? query}) async {
    var beds = (await records.list('beds')).map(_bed).toList();
    if (query?.status != null) {
      beds = beds.where((bed) => bed.status == query!.status).toList();
    }
    if (query?.ward != null && query!.ward != 'All') {
      beds = beds.where((bed) => bed.ward == query.ward).toList();
    }
    if (query?.isICU == true) {
      beds = beds.where((bed) => bed.type.toUpperCase().contains('ICU')).toList();
    }
    final search = query?.searchQuery?.trim().toLowerCase();
    if (search != null && search.isNotEmpty) {
      beds = beds.where((bed) => bed.id.toLowerCase().contains(search) ||
          bed.ward.toLowerCase().contains(search) ||
          (bed.patientId?.toLowerCase().contains(search) ?? false)).toList();
    }
    return beds;
  }

  @override
  Future<List<WardCapacityItem>> getWardCapacities() async {
    final beds = await getBeds();
    final grouped = <String, List<BedItem>>{};
    for (final bed in beds) {
      grouped.putIfAbsent(bed.ward, () => []).add(bed);
    }
    return grouped.entries.map((entry) {
      final occupied = entry.value.where((bed) => bed.status == BedStatus.occupied).length;
      return WardCapacityItem(
        name: entry.key,
        occupied: occupied,
        total: entry.value.length,
        status: occupied == entry.value.length ? 'Full' : 'Available',
      );
    }).toList();
  }

  @override
  Future<List<LiveActivityItem>> getLiveActivities() async => const [];

  @override
  Future<BedItem> addBed(BedItem bed) async {
    await records.save('beds', bed.id, _bedJson(bed));
    return bed;
  }

  @override
  Future<void> updateBedStatus(String bedId, BedStatus status) async {
    final row = await _requireBed(bedId);
    row['status'] = status.name;
    row['lastUpdated'] = DateTime.now().toUtc().toIso8601String();
    if (status != BedStatus.occupied) row['patientId'] = null;
    await records.save('beds', bedId, row);
  }

  @override
  Future<void> assignPatientToBed(String bedId, String patientId, [String? admissionId]) async {
    final row = await _requireBed(bedId);
    if (row['status'] != BedStatus.available.name &&
        row['status'] != BedStatus.reserved.name) {
      throw StateError('Only an available or reserved bed can be assigned.');
    }
    row['status'] = BedStatus.occupied.name;
    row['patientId'] = patientId;
    row['admissionId'] = admissionId;
    row['lastUpdated'] = DateTime.now().toUtc().toIso8601String();
    await records.save('beds', bedId, row);
  }

  @override
  Future<void> transferPatient(String fromBedId, String toBedId) async {
    if (fromBedId == toBedId) throw ArgumentError('Choose a different destination bed.');
    final from = await _requireBed(fromBedId);
    final to = await _requireBed(toBedId);
    if (from['status'] != BedStatus.occupied.name || from['patientId'] == null) {
      throw StateError('Source bed has no admitted patient.');
    }
    if (to['status'] != BedStatus.available.name) {
      throw StateError('Destination bed is not available.');
    }
    final patientId = from['patientId'];
    from['status'] = BedStatus.cleaning.name;
    from['patientId'] = null;
    from['lastUpdated'] = DateTime.now().toUtc().toIso8601String();
    to['status'] = BedStatus.occupied.name;
    to['patientId'] = patientId;
    to['lastUpdated'] = DateTime.now().toUtc().toIso8601String();
    await records.saveMany('beds', {fromBedId: from, toBedId: to});
  }

  @override
  Future<void> reserveBed(String bedId, String patientId) async {
    final row = await _requireBed(bedId);
    if (row['status'] != BedStatus.available.name) {
      throw StateError('Only an available bed can be reserved.');
    }
    row['status'] = BedStatus.reserved.name;
    row['patientId'] = patientId;
    await records.save('beds', bedId, row);
  }

  @override
  Future<void> releaseBed(String bedId) async {
    final row = await _requireBed(bedId);
    row['status'] = BedStatus.cleaning.name;
    row['patientId'] = null;
    await records.save('beds', bedId, row);
  }

  @override
  Future<void> startSanitization(String bedId) => updateBedStatus(bedId, BedStatus.cleaning);
  @override
  Future<void> completeSanitization(String bedId) => updateBedStatus(bedId, BedStatus.available);
  @override
  Future<void> startMaintenance(String bedId, [String? reason]) => updateBedStatus(bedId, BedStatus.maintenance);
  @override
  Future<void> completeMaintenance(String bedId) => updateBedStatus(bedId, BedStatus.available);
  @override
  Future<void> blockBed(String bedId, [String? reason]) => updateBedStatus(bedId, BedStatus.maintenance);
  @override
  Future<void> unblockBed(String bedId) => updateBedStatus(bedId, BedStatus.available);

  @override
  Future<BedOccupancySummary> getOccupancySummary() async {
    final beds = await getBeds();
    int count(BedStatus status) =>
        beds.where((bed) => bed.status == status).length;
    return BedOccupancySummary(
      total: beds.length,
      occupied: count(BedStatus.occupied),
      available: count(BedStatus.available),
      reserved: count(BedStatus.reserved),
      maintenance: count(BedStatus.maintenance),
      sanitizing: count(BedStatus.cleaning),
      blocked: 0,
    );
  }

  @override
  Future<void> togglePatientVisibility(String bedId, bool isVisible) async {
    final row = await _requireBed(bedId);
    row['isVisibleToPatientApp'] = isVisible;
    await records.save('beds', bedId, row);
  }

  Future<Map<String, dynamic>> _requireBed(String id) async =>
      await records.get('beds', id) ?? (throw StateError('Bed not found.'));

  BedItem _bed(Map<String, dynamic> row) => BedItem(
        id: row['id'] as String,
        type: row['type'] as String? ?? 'General',
        ward: row['ward'] as String? ?? '',
        floor: _int(row['floor']),
        status: BedStatus.values.firstWhere(
          (item) => item.name == row['status'],
          orElse: () => BedStatus.available,
        ),
        patientId: row['patientId'] as String?,
        equipment: (row['equipment'] as List? ?? const []).cast<String>(),
        lastUpdated: row['lastUpdated']?.toString() ?? '',
        isVisibleToPatientApp: row['isVisibleToPatientApp'] as bool? ?? true,
      );

  Map<String, dynamic> _bedJson(BedItem value) => {
        'id': value.id,
        'type': value.type,
        'ward': value.ward,
        'floor': value.floor,
        'status': value.status.name,
        'patientId': value.patientId,
        'equipment': value.equipment,
        'lastUpdated': DateTime.now().toUtc().toIso8601String(),
        'isVisibleToPatientApp': value.isVisibleToPatientApp,
      };
}

class ServerpodAppointmentRepository implements AppointmentRepository {
  ServerpodAppointmentRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<AppointmentItem>> getAppointments({AppointmentQuery? query}) async {
    final page = query?.pagination;
    // Filter before pagination. Applying a database offset first silently
    // drops matching rows when filters are active. Read in bounded pages so
    // records beyond the first 500 remain queryable.
    var rows = <Map<String, dynamic>>[];
    const fetchSize = 500;
    var offset = 0;
    while (true) {
      final chunk = await records.list('appointments', limit: fetchSize, offset: offset);
      rows.addAll(chunk);
      if (chunk.length < fetchSize) break;
      offset += chunk.length;
    }
    if (query != null) {
      if (query.status != null) {
        rows = rows.where((row) => row['status'] == query.status!.name).toList();
      }
      if (query.date != null) {
        rows = rows.where((row) {
          final date = _date(row['dateTime'] ?? row['appointmentDateTime']);
          return date.year == query.date!.year && date.month == query.date!.month &&
              date.day == query.date!.day;
        }).toList();
      }
      if (query.startDate != null) {
        rows = rows.where((row) =>
            !_date(row['dateTime'] ?? row['appointmentDateTime'])
                .isBefore(query.startDate!)).toList();
      }
      if (query.endDate != null) {
        rows = rows.where((row) =>
            !_date(row['dateTime'] ?? row['appointmentDateTime'])
                .isAfter(query.endDate!)).toList();
      }
      if (query.patientId != null) {
        rows = rows.where((row) => row['patientId'] == query.patientId ||
            row['patientName'] == query.patientId).toList();
      }
      if (query.doctorId != null) {
        rows = rows.where((row) => row['doctorId'] == query.doctorId ||
            row['doctorName'] == query.doctorId).toList();
      }
      if (query.departmentId != null) {
        rows = rows.where((row) => row['departmentId'] == query.departmentId ||
            row['department'] == query.departmentId).toList();
      }
      if (query.type != null) {
        rows = rows.where((row) => row['type'] == query.type).toList();
      }
      final search = query.searchQuery?.trim().toLowerCase();
      if (search != null && search.isNotEmpty) {
        rows = rows.where((row) => [
          row['id'], row['patientId'], row['patientName'], row['doctorId'],
          row['doctorName'], row['departmentId'], row['department'],
        ].any((value) => value?.toString().toLowerCase().contains(search) ?? false)).toList();
      }
    }
    final start = (page?.offset ?? 0).clamp(0, rows.length);
    final end = (start + (page?.pageSize ?? rows.length)).clamp(start, rows.length);
    return rows.sublist(start, end).map(_appointment).toList();
  }

  @override
  Future<AppointmentItem?> getAppointmentById(String id) async {
    final row = await records.get('appointments', id);
    return row == null ? null : _appointment(row);
  }

  @override
  Future<List<AppointmentItem>> getAppointmentsByDoctor(String doctorId) async =>
      (await records.list('appointments'))
          .where((row) => row['doctorId'] == doctorId ||
              (row['doctorName']?.toString().contains(doctorId) ?? false))
          .map(_appointment)
          .toList();

  @override
  Future<List<AppointmentItem>> getAppointmentsByPatient(String patientId) async =>
      (await records.list('appointments'))
          .where((row) => row['patientId'] == patientId ||
              (row['patientName']?.toString().contains(patientId) ?? false))
          .map(_appointment)
          .toList();

  @override
  Future<AppointmentItem> bookAppointment(AppointmentItem appointment) async {
    await records.save('appointments', appointment.id, _appointmentJson(appointment));
    return appointment;
  }

  @override
  Future<void> scheduleAppointment(Appointment appointment) async {
    await records.save('appointments', appointment.id, {
      'id': appointment.id,
      'patientId': appointment.patientId,
      'patientName': appointment.patientName,
      'doctorId': appointment.doctorId,
      'doctorName': appointment.doctorName,
      'departmentId': appointment.departmentId,
      'department': appointment.departmentId,
      'dateTime': appointment.appointmentDateTime.toIso8601String(),
      'status': appointment.status.name,
      'reason': appointment.reason,
      'notes': appointment.notes,
      'type': appointment.type,
      'hospitalPatientLinkId': appointment.hospitalPatientLinkId,
      'admissionId': appointment.admissionId,
      'facilityId': appointment.facilityId,
      'createdAt': appointment.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<AppointmentItem> createWalkIn(AppointmentItem appointment) async {
    final walkIn = AppointmentItem(
      id: appointment.id,
      patientName: appointment.patientName,
      doctorName: appointment.doctorName,
      department: appointment.department,
      dateTime: appointment.dateTime,
      status: AppointmentStatus.checkedIn.name,
      type: 'walkIn',
    );
    await records.save('appointments', walkIn.id, _appointmentJson(walkIn));
    return walkIn;
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    final row = await records.get('appointments', appointmentId);
    if (row == null) throw StateError('Appointment not found.');
    row['status'] = status.name;
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('appointments', appointmentId, row);
  }

  @override
  Future<void> checkInAppointment(String appointmentId) =>
      updateAppointmentStatus(appointmentId, AppointmentStatus.checkedIn);
  @override
  Future<void> startConsultation(String appointmentId) =>
      updateAppointmentStatus(appointmentId, AppointmentStatus.inConsultation);
  @override
  Future<void> completeAppointment(String appointmentId) =>
      updateAppointmentStatus(appointmentId, AppointmentStatus.completed);
  @override
  Future<void> cancelAppointment(String appointmentId, [String? reason]) async {
    final row = await records.get('appointments', appointmentId);
    if (row == null) throw StateError('Appointment not found.');
    row['status'] = AppointmentStatus.cancelled.name;
    row['cancellationReason'] = reason;
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('appointments', appointmentId, row);
  }
  @override
  Future<void> markNoShow(String appointmentId) =>
      updateAppointmentStatus(appointmentId, AppointmentStatus.noShow);

  @override
  Future<AppointmentSummary> getAppointmentSummary() async {
    final items = await getAppointments();
    int count(String status) => items.where((item) => item.status == status).length;
    return AppointmentSummary(
      total: items.length,
      scheduled: count('scheduled'),
      checkedIn: count('checkedIn'),
      inConsultation: count('inConsultation') + count('inProgress'),
      completed: count('completed'),
      cancelled: count('cancelled'),
      noShow: count('noShow') + count('missed'),
    );
  }

  AppointmentItem _appointment(Map<String, dynamic> row) => AppointmentItem(
        id: row['id'] as String,
        patientName: row['patientName'] as String? ?? row['patientId'] as String? ?? '',
        doctorName: row['doctorName'] as String? ?? row['doctorId'] as String? ?? '',
        department: row['department'] as String? ?? row['departmentId'] as String? ?? '',
        dateTime: _date(row['dateTime'] ?? row['appointmentDateTime']),
        status: row['status'] as String? ?? AppointmentStatus.scheduled.name,
        type: row['type'] as String? ?? '',
      );

  Map<String, dynamic> _appointmentJson(AppointmentItem value) => {
        'id': value.id,
        'patientName': value.patientName,
        'doctorName': value.doctorName,
        'department': value.department,
        'dateTime': value.dateTime.toIso8601String(),
        'status': value.status,
        'type': value.type,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
}

class ServerpodBloodRepository implements BloodRepository {
  ServerpodBloodRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<BloodGroupSummaryItem>> getBloodSummaries() async {
    final units = await getInventoryUnits();
    final groups = <String, List<BloodInventoryUnit>>{};
    for (final unit in units) {
      groups.putIfAbsent(unit.bloodGroup, () => []).add(unit);
    }
    return groups.entries.map((entry) {
      final available = entry.value
          .where((unit) => unit.status == InventoryUnitStatus.available)
          .fold<int>(0, (sum, unit) => sum + unit.quantityUnits);
      final reserved = entry.value
          .where((unit) => unit.status == InventoryUnitStatus.reserved)
          .fold<int>(0, (sum, unit) => sum + unit.quantityUnits);
      const threshold = 10;
      return BloodGroupSummaryItem(
        bloodGroup: entry.key,
        available: available,
        reserved: reserved,
        minRequired: threshold,
        status: available == 0 ? 'Critical' : available < threshold ? 'Limited' : 'Healthy',
      );
    }).toList();
  }

  @override
  Future<List<BloodInventoryUnit>> getInventoryUnits({BloodInventoryQuery? query}) async {
    var units = (await records.list('bloodInventory')).map(_unit).toList();
    if (query?.bloodGroup != null) {
      units = units.where((unit) => unit.bloodGroup == query!.bloodGroup).toList();
    }
    if (query?.status != null) {
      units = units.where((unit) => unit.status.name == query!.status!.name).toList();
    }
    return units;
  }

  @override
  Future<List<DonationRecordItem>> getDonationRecords() async =>
      (await records.list('donations')).map(_donation).toList();

  @override
  Future<List<BloodRequestItem>> getBloodRequests() async =>
      (await records.list('bloodRequests')).map(_request).toList();

  @override
  Future<BloodInventoryUnit> addInventoryUnit(BloodInventoryUnit unit) async {
    await records.save('bloodInventory', unit.unitId, _unitJson(unit));
    return unit;
  }

  @override
  Future<BloodRequestItem> createBloodRequest(BloodRequestItem request) async {
    await records.save('bloodRequests', request.requestId, _requestJson(request));
    return request;
  }

  @override
  Future<DonationRecordItem> recordDonation(DonationRecordItem donation) async {
    final key = '${donation.donorId}-${DateTime.now().microsecondsSinceEpoch}';
    await records.save('donations', key, {
      'id': key,
      'donorId': donation.donorId,
      'bloodGroup': donation.bloodGroup,
      'donationType': donation.donationType,
      'units': donation.units,
      'donationDate': donation.donationDate,
      'screeningStatus': donation.screeningStatus,
      'storageStatus': donation.storageStatus,
    });
    return donation;
  }

  @override
  Future<void> updateRequestStatus(String requestId, RequestStatus status, int allocatedUnits) async {
    final row = await records.get('bloodRequests', requestId);
    if (row == null) throw StateError('Blood request not found.');
    row['status'] = status.name;
    row['allocatedUnits'] = allocatedUnits;
    await records.save('bloodRequests', requestId, row);
  }

  @override
  Future<void> reserveUnit(String unitId, String requestId) async {
    final row = await _unitRow(unitId);
    if (row['status'] != InventoryUnitStatus.available.name) {
      throw StateError('Only available blood units can be reserved.');
    }
    row['status'] = InventoryUnitStatus.reserved.name;
    row['requestId'] = requestId;
    await records.save('bloodInventory', unitId, row);
  }

  @override
  Future<void> allocateUnits(String requestId, List<String> unitIds) async {
    if (unitIds.isEmpty || unitIds.toSet().length != unitIds.length) {
      throw ArgumentError('Select one or more distinct blood units.');
    }
    final request = await records.get('bloodRequests', requestId);
    if (request == null) throw StateError('Blood request not found.');
    final updates = <String, Map<String, dynamic>>{};
    for (final id in unitIds) {
      final row = await _unitRow(id);
      if (row['status'] != InventoryUnitStatus.available.name) {
        throw StateError('Only available blood units can be allocated.');
      }
      row['status'] = InventoryUnitStatus.reserved.name;
      row['requestId'] = requestId;
      updates[id] = row;
    }
    request['status'] = RequestStatus.allocated.name;
    request['allocatedUnits'] = unitIds.length;
    await records.saveBatch({
      'bloodInventory': updates,
      'bloodRequests': {requestId: request},
    });
  }

  @override
  Future<void> issueUnits(String requestId, List<String> unitIds) async {
    final request = await records.get('bloodRequests', requestId);
    if (request == null) throw StateError('Blood request not found.');
    if (unitIds.length < _int(request['allocatedUnits'])) {
      throw StateError('Issued unit count does not match the allocation.');
    }
    if (unitIds.isEmpty || unitIds.toSet().length != unitIds.length) {
      throw ArgumentError('Select one or more distinct blood units.');
    }
    final updates = <String, Map<String, dynamic>>{};
    for (final id in unitIds) {
      final row = await _unitRow(id);
      if (row['status'] != InventoryUnitStatus.reserved.name || row['requestId'] != requestId) {
        throw StateError('A selected unit is not reserved for this request.');
      }
      row['status'] = 'issued';
      row['requestId'] = requestId;
      updates[id] = row;
    }
    request['status'] = RequestStatus.completed.name;
    await records.saveBatch({
      'bloodInventory': updates,
      'bloodRequests': {requestId: request},
    });
  }

  @override
  Future<void> quarantineUnit(String unitId, [String? reason]) async =>
      _setUnitStatus(unitId, InventoryUnitStatus.quarantine, reason: reason);
  @override
  Future<void> releaseFromQuarantine(String unitId) async =>
      _setUnitStatus(unitId, InventoryUnitStatus.available);
  @override
  Future<void> discardUnit(String unitId, [String? reason]) async =>
      _setUnitStatus(unitId, InventoryUnitStatus.discarded, reason: reason);

  @override
  Future<BloodInventorySummary> getInventorySummary() async {
    final units = await getInventoryUnits();
    int sumWhere(bool Function(BloodInventoryUnit) test) => units
        .where(test)
        .fold<int>(0, (sum, unit) => sum + unit.quantityUnits);
    final now = DateTime.now();
    return BloodInventorySummary(
      totalUnits: sumWhere((_) => true),
      availableUnits: sumWhere((unit) => unit.status == InventoryUnitStatus.available),
      reservedUnits: sumWhere((unit) => unit.status == InventoryUnitStatus.reserved),
      expiringUnits: sumWhere((unit) => unit.status == InventoryUnitStatus.expiringSoon ||
          unit.expiryDate.isBefore(now.add(const Duration(days: 7)))),
      criticalUnits: sumWhere((unit) => unit.status == InventoryUnitStatus.quarantine),
      lastUpdated: now,
    );
  }

  Future<Map<String, dynamic>> _unitRow(String id) async =>
      await records.get('bloodInventory', id) ?? (throw StateError('Blood unit not found.'));

  Future<void> _setUnitStatus(String id, InventoryUnitStatus status, {String? reason}) async {
    final row = await _unitRow(id);
    row['status'] = status.name;
    row['statusReason'] = reason;
    await records.save('bloodInventory', id, row);
  }

  BloodInventoryUnit _unit(Map<String, dynamic> row) => BloodInventoryUnit(
        unitId: row['id'] as String,
        bloodGroup: row['bloodGroup'] as String? ?? '',
        component: row['component'] as String? ?? 'Whole Blood',
        quantityUnits: _int(row['quantityUnits']),
        collectionDate: _date(row['collectionDate']),
        expiryDate: _date(row['expiryDate']),
        status: InventoryUnitStatus.values.firstWhere(
          (value) => value.name == row['status'],
          orElse: () => InventoryUnitStatus.available,
        ),
        storageLocation: row['storageLocation'] as String? ?? '',
        lastUpdated: row['lastUpdated']?.toString() ?? '',
      );

  Map<String, dynamic> _unitJson(BloodInventoryUnit unit) => {
        'id': unit.unitId,
        'bloodGroup': unit.bloodGroup,
        'component': unit.component,
        'quantityUnits': unit.quantityUnits,
        'collectionDate': unit.collectionDate.toIso8601String(),
        'expiryDate': unit.expiryDate.toIso8601String(),
        'status': unit.status.name,
        'storageLocation': unit.storageLocation,
        'lastUpdated': DateTime.now().toUtc().toIso8601String(),
      };

  DonationRecordItem _donation(Map<String, dynamic> row) => DonationRecordItem(
        donorId: row['donorId'] as String? ?? '',
        bloodGroup: row['bloodGroup'] as String? ?? '',
        donationType: row['donationType'] as String? ?? '',
        units: _int(row['units']),
        donationDate: row['donationDate']?.toString() ?? '',
        screeningStatus: row['screeningStatus'] as String? ?? 'Pending',
        storageStatus: row['storageStatus'] as String? ?? 'Stored',
      );

  BloodRequestItem _request(Map<String, dynamic> row) => BloodRequestItem(
        requestId: row['id'] as String,
        bloodGroup: row['bloodGroup'] as String? ?? '',
        requiredUnits: _int(row['requiredUnits']),
        allocatedUnits: _int(row['allocatedUnits']),
        department: row['department'] as String? ?? '',
        priority: RequestPriority.values.firstWhere(
          (item) => item.name == row['priority'],
          orElse: () => RequestPriority.normal,
        ),
        status: RequestStatus.values.firstWhere(
          (item) => item.name == row['status'],
          orElse: () => RequestStatus.pending,
        ),
      );

  Map<String, dynamic> _requestJson(BloodRequestItem request) => {
        'id': request.requestId,
        'bloodGroup': request.bloodGroup,
        'requiredUnits': request.requiredUnits,
        'allocatedUnits': request.allocatedUnits,
        'department': request.department,
        'priority': request.priority.name,
        'status': request.status.name,
      };
}

class ServerpodAdmissionRepository implements AdmissionRepository {
  ServerpodAdmissionRepository(this.records);
  final HospitalOperationalRepository records;

  @override
  Future<List<Admission>> getAdmissions({String? patientId, String? bedId, String? hospitalId}) async =>
      (hospitalId != null && hospitalId != records.hospitalKey
          ? <Map<String, dynamic>>[]
          : await records.list('admissions')).map(_admission).where((item) =>
          (patientId == null || item.patientId == patientId) &&
          (bedId == null || item.bedId == bedId)).toList();

  @override
  Future<Admission?> getAdmissionById(String id) async {
    final row = await records.get('admissions', id);
    return row == null ? null : _admission(row);
  }

  @override
  Future<Admission?> getActiveAdmissionForPatient(String patientId) async =>
      (await getAdmissions(patientId: patientId)).where((row) =>
          row.admissionStatus == AdmissionStatus.admitted).firstOrNull;

  @override
  Future<List<Admission>> getAdmissionHistory(String patientId) async =>
      getAdmissions(patientId: patientId);

  @override
  Future<Admission> createAdmission(Admission admission) async {
    if (admission.admissionStatus == AdmissionStatus.admitted) {
      final active = await getActiveAdmissionForPatient(admission.patientId);
      if (active != null) throw StateError('Patient already has an active admission.');
    }
    await records.save('admissions', admission.id, _admissionJson(admission));
    return admission;
  }

  @override
  Future<void> updateAdmission(Admission admission) async =>
      records.save('admissions', admission.id, _admissionJson(admission));

  @override
  Future<void> dischargeAdmission(String admissionId) async {
    final row = await records.get('admissions', admissionId);
    if (row == null) throw StateError('Admission not found.');
    row['admissionStatus'] = AdmissionStatus.discharged.name;
    row['dischargeDate'] = DateTime.now().toUtc().toIso8601String();
    row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('admissions', admissionId, row);
  }

  Admission _admission(Map<String, dynamic> row) => Admission(
        id: row['id'] as String,
        hospitalId: records.hospitalKey,
        patientId: row['patientId'] as String? ?? '',
        hospitalPatientLinkId: row['hospitalPatientLinkId'] as String? ?? '',
        bedId: row['bedId'] as String? ?? '',
        ward: row['ward'] as String? ?? 'General Ward A',
        attendingDoctorId: row['attendingDoctorId'] as String? ?? '',
        doctorName: row['doctorName'] as String? ?? '',
        departmentId: row['departmentId'] as String? ?? '',
        admissionDate: _date(row['admissionDate']),
        dischargeDate: row['dischargeDate'] == null ? null : _date(row['dischargeDate']),
        admissionType: row['admissionType'] as String? ?? 'Emergency',
        admissionStatus: AdmissionStatus.values.firstWhere(
          (item) => item.name == row['admissionStatus'],
          orElse: () => AdmissionStatus.pending,
        ),
        reason: row['reason'] as String? ?? '',
        diagnosis: row['diagnosis'] as String? ?? '',
        vitals: (row['vitals'] as Map? ?? const {}).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
        clinicalNotes: row['clinicalNotes'] as String?,
        createdAt: _date(row['createdAt']),
        updatedAt: _date(row['updatedAt']),
      );

  Map<String, dynamic> _admissionJson(Admission value) => {
        'id': value.id,
        'patientId': value.patientId,
        'hospitalPatientLinkId': value.hospitalPatientLinkId,
        'bedId': value.bedId,
        'ward': value.ward,
        'attendingDoctorId': value.attendingDoctorId,
        'doctorName': value.doctorName,
        'departmentId': value.departmentId,
        'admissionDate': value.admissionDate.toIso8601String(),
        'dischargeDate': value.dischargeDate?.toIso8601String(),
        'admissionType': value.admissionType,
        'admissionStatus': value.admissionStatus.name,
        'reason': value.reason,
        'diagnosis': value.diagnosis,
        'vitals': value.vitals,
        'clinicalNotes': value.clinicalNotes,
        'createdAt': value.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
}

int _int(Object? value) => value is num ? value.toInt() : 0;
DateTime _date(Object? value) => value is String
    ? DateTime.tryParse(value) ?? DateTime.now().toUtc()
    : DateTime.now().toUtc();
