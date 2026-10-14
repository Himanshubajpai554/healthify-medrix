import 'package:serverpod/serverpod.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../delivery/outbound_delivery_service.dart';
import '../generated/protocol.dart';

/// Hospital APIs are always authenticated and every tenant read/write is
/// checked against the signed-in account's active hospital membership.
class HospitalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _operationalCollections = {
    'appointments',
    'beds',
    'icu',
    'admissions',
    'patients',
    'doctors',
    'staff',
    'shifts',
    'bloodInventory',
    'bloodRequests',
    'donations',
    'facilities',
    'equipment',
    'emergencies',
    'diagnosticReports',
    'prescriptions',
    'notifications',
    'insights',
    'auditEvents',
    'resources',
    'departments',
    'settings',
    'securityEvents',
    'operationalAlerts',
    'notificationDispatches',
    'notificationPreferences',
    'notificationRoutingRules',
    'documentActivities',
    'resourceRequests',
    'resourceRecommendations',
    'breakGlassRequests',
    'securityRolePermissions',
    'patientLinks',
    'doctorSchedules',
    'doctorAffiliations',
    'doctorLeaves',
    'clinicalNotes',
    'doctorFollowUps',
    'userSessions',
  };

  static const _patientCollections = {
    'patientProfiles',
    'patientAppointments',
    'patientReports',
    'patientPrescriptions',
    'patientFavorites',
    'patientBloodRequests',
  };

  /// Returns only verified hospitals that have enabled patient discovery.
  /// Doctor records are drawn from those hospitals' own operational rows.
  Future<String> getPatientDirectory(Session session, String collection) async {
    _userIdentifier(session);
    if (collection != 'hospitals' &&
        collection != 'doctors' &&
        collection != 'beds' &&
        collection != 'bloodInventory') {
      throw Exception('Unsupported patient directory collection.');
    }
    final profiles = await HospitalProfileRecord.db.find(
      session,
      where: (row) => row.verificationStatus.equals('verified'),
      limit: 500,
    );
    final settings = await HospitalSettingsRecord.db.find(session, limit: 500);
    final discoverableKeys = profiles
        .where(
          (profile) => settings.any(
            (setting) =>
                setting.hospitalKey == profile.hospitalKey &&
                setting.isHospitalDiscoverable,
          ),
        )
        .map((profile) => profile.hospitalKey)
        .toSet();
    final reviewRows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) => row.collection.equals('patientReviews'),
      limit: 5000,
    );
    final ratingTotals = <String, (double, int)>{};
    for (final row in reviewRows) {
      final review = jsonDecode(row.payload);
      if (review is! Map<String, dynamic> ||
          review['targetType'] == null ||
          review['targetId'] == null ||
          review['ratingScore'] is! num) {
        continue;
      }
      final key = '${review['targetType']}:${review['targetId']}';
      final current = ratingTotals[key] ?? (0.0, 0);
      ratingTotals[key] = (
        current.$1 + (review['ratingScore'] as num).toDouble(),
        current.$2 + 1,
      );
    }
    double ratingFor(String type, String id) {
      final current = ratingTotals['$type:$id'];
      return current == null
          ? 0.0
          : double.parse((current.$1 / current.$2).toStringAsFixed(1));
    }

    int reviewCountFor(String type, String id) =>
        ratingTotals['$type:$id']?.$2 ?? 0;
    if (collection == 'hospitals') {
      final result = <Map<String, dynamic>>[];
      for (final profile in profiles.where(
        (item) => discoverableKeys.contains(item.hospitalKey),
      )) {
        final doctorCount = await HospitalOperationalRecord.db.count(
          session,
          where: (row) =>
              row.hospitalKey.equals(profile.hospitalKey) &
              row.collection.equals('doctors'),
        );
        result.add({
          'id': profile.hospitalKey,
          'name': profile.displayName.isEmpty
              ? profile.name
              : profile.displayName,
          'legalName': profile.legalName,
          'address': profile.address,
          'city': profile.city,
          'state': profile.state,
          'country': profile.country,
          'phone': profile.receptionPhone,
          'emergencyPhone': profile.emergencyHelpline,
          'email': profile.email,
          'website': profile.website,
          'type': profile.hospitalType,
          'rating': ratingFor('hospital', profile.hospitalKey),
          'reviewCount': reviewCountFor('hospital', profile.hospitalKey),
          'totalBeds': profile.totalBeds,
          'icuBeds': profile.icuBeds,
          'totalDoctors': doctorCount,
          'latitude': profile.latitude,
          'longitude': profile.longitude,
          'has247Emergency': profile.has247Emergency,
          'traumaLevel': profile.traumaLevel,
          'opdTimings': profile.opdTimings,
          'operatingStatus': profile.operatingStatus,
          'verified': true,
          'createdAt': profile.verifiedDate?.toIso8601String(),
          'updatedAt': profile.verifiedDate?.toIso8601String(),
          'establishmentDate': profile.establishmentDate,
          'operatingTheatres': profile.operatingTheatres,
          'emergencyCapacity': profile.emergencyCapacity,
          'hasAmbulance': profile.hasAmbulance,
          'verifiedDate': profile.verifiedDate?.toIso8601String(),
        });
      }
      return jsonEncode(result);
    }

    if (collection == 'beds') {
      final bedRows = await HospitalOperationalRecord.db.find(
        session,
        where: (row) => row.collection.equals('beds'),
        limit: 10000,
      );
      final hospitalNames = {
        for (final profile in profiles.where(
          (item) => discoverableKeys.contains(item.hospitalKey),
        ))
          profile.hospitalKey: profile.displayName.isEmpty
              ? profile.name
              : profile.displayName,
      };
      final grouped = <String, Map<String, dynamic>>{};
      for (final row in bedRows) {
        if (!discoverableKeys.contains(row.hospitalKey)) {
          continue;
        }
        final bed = jsonDecode(row.payload);
        if (bed is! Map<String, dynamic> ||
            bed['isVisibleToPatientApp'] != true) {
          continue;
        }
        final type = '${bed['type'] ?? 'General'}';
        final key = '${row.hospitalKey}:$type';
        final group = grouped.putIfAbsent(
          key,
          () => {
            'hospitalId': row.hospitalKey,
            'hospitalName': hospitalNames[row.hospitalKey] ?? 'Hospital',
            'type': type,
            'available': 0,
            'total': 0,
            'lastUpdated': null,
          },
        );
        group['total'] = (group['total'] as int) + 1;
        if (bed['status'] == 'available') {
          group['available'] = (group['available'] as int) + 1;
        }
        final updated = DateTime.tryParse('${bed['lastUpdated'] ?? ''}');
        final previous = DateTime.tryParse('${group['lastUpdated'] ?? ''}');
        if (updated != null &&
            (previous == null || updated.isAfter(previous))) {
          group['lastUpdated'] = updated.toIso8601String();
        }
      }
      return jsonEncode(grouped.values.toList());
    }

    if (collection == 'bloodInventory') {
      // Expose only aggregate availability from verified, discoverable
      // hospitals. Never return unit IDs, storage locations, or donor data.
      final inventoryRows = await HospitalOperationalRecord.db.find(
        session,
        where: (row) => row.collection.equals('bloodInventory'),
        limit: 20000,
      );
      final profilesByKey = {
        for (final profile in profiles)
          if (discoverableKeys.contains(profile.hospitalKey))
            profile.hospitalKey: profile,
      };
      final hospitals = <String, Map<String, dynamic>>{};
      for (final row in inventoryRows) {
        if (!discoverableKeys.contains(row.hospitalKey)) continue;
        final unit = jsonDecode(row.payload);
        if (unit is! Map<String, dynamic> ||
            unit['isVisibleToPatientApp'] == false ||
            unit['status'] != 'available') {
          continue;
        }
        final expiry = DateTime.tryParse('${unit['expiryDate'] ?? ''}');
        if (expiry == null || !expiry.isAfter(DateTime.now().toUtc())) continue;
        final bloodGroup = '${unit['bloodGroup'] ?? ''}'.trim();
        final component = '${unit['component'] ?? 'Whole Blood'}'.trim();
        if (bloodGroup.isEmpty) continue;
        final profile = profilesByKey[row.hospitalKey];
        if (profile == null) continue;
        final result = hospitals.putIfAbsent(
          row.hospitalKey,
          () => {
            'id': row.hospitalKey,
            'name': profile.displayName.isEmpty
                ? profile.name
                : profile.displayName,
            'type': profile.hospitalType,
            'address': profile.address,
            'phone': profile.receptionPhone,
            'is24x7': profile.has247Emergency,
            'lastUpdated': null,
            'stocks': <String, Map<String, dynamic>>{},
          },
        );
        final stocks = result['stocks'] as Map<String, Map<String, dynamic>>;
        final stock = stocks.putIfAbsent(
          bloodGroup,
          () => {
            'bloodGroup': bloodGroup,
            'unitsAvailable': 0,
            'componentUnits': <String, int>{},
            'lastUpdated': null,
          },
        );
        final quantity = (unit['quantityUnits'] as num?)?.toInt() ?? 0;
        stock['unitsAvailable'] = (stock['unitsAvailable'] as int) + quantity;
        final componentUnits = stock['componentUnits'] as Map<String, int>;
        componentUnits[component] = (componentUnits[component] ?? 0) + quantity;
        final updated = DateTime.tryParse('${unit['lastUpdated'] ?? ''}');
        final oldUpdated = DateTime.tryParse('${stock['lastUpdated'] ?? ''}');
        if (updated != null &&
            (oldUpdated == null || updated.isAfter(oldUpdated))) {
          stock['lastUpdated'] = updated.toIso8601String();
        }
        final hospitalUpdated = DateTime.tryParse(
          '${result['lastUpdated'] ?? ''}',
        );
        if (updated != null &&
            (hospitalUpdated == null || updated.isAfter(hospitalUpdated))) {
          result['lastUpdated'] = updated.toIso8601String();
        }
      }
      final result = hospitals.values.map((hospital) {
        final stocks =
            (hospital.remove('stocks') as Map<String, Map<String, dynamic>>)
                .values
                .toList();
        for (final stock in stocks) {
          final units = stock['unitsAvailable'] as int;
          stock['status'] = units >= 10
              ? 'Available'
              : units > 0
              ? 'Limited'
              : 'Unavailable';
        }
        return {...hospital, 'stocks': stocks};
      }).toList();
      return jsonEncode(result);
    }

    final doctorRows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) => row.collection.equals('doctors'),
      limit: 2000,
    );
    final hospitalsByKey = {
      for (final profile in profiles)
        if (discoverableKeys.contains(profile.hospitalKey))
          profile.hospitalKey: profile,
    };
    final doctors = <Map<String, dynamic>>[];
    for (final row in doctorRows) {
      final hospital = hospitalsByKey[row.hospitalKey];
      if (hospital == null) continue;
      final doctor = jsonDecode(row.payload);
      if (doctor is! Map<String, dynamic>) continue;
      doctors.add({
        'id': row.recordKey,
        'hospitalId': row.hospitalKey,
        'hospitalName': hospital.displayName.isEmpty
            ? hospital.name
            : hospital.displayName,
        'departmentId': doctor['departmentId'] ?? doctor['department'] ?? '',
        'department': doctor['department'] ?? doctor['specialization'] ?? '',
        'name': doctor['name'] ?? '',
        'specialization':
            doctor['specialization'] ?? doctor['department'] ?? '',
        'qualification': doctor['qualification'] ?? '',
        'email': doctor['email'] ?? '',
        'phone': doctor['phone'] ?? '',
        'experienceYears': doctor['experienceYears'] ?? 0,
        'consultationFee': doctor['consultationFee'] ?? 0,
        'status': doctor['status'] ?? 'offDuty',
        'availabilityStatus': doctor['availabilityStatus'] ?? doctor['status'],
        'affiliationStatus': doctor['affiliationStatus'] ?? 'fullTime',
        'rating': ratingFor('doctor', row.recordKey),
        'reviewCount': reviewCountFor('doctor', row.recordKey),
        'profileImageUrl': doctor['profileImageUrl'],
        'createdAt': doctor['createdAt'],
        'updatedAt': doctor['updatedAt'],
      });
    }
    return jsonEncode(doctors);
  }

  /// Patient portal data is partitioned by the authenticated Serverpod user.
  /// The caller never supplies the partition key, so one patient cannot read
  /// or overwrite another patient's records.
  Future<List<HospitalOperationalRecord>> listMyPatientRecords(
    Session session,
    String collection, {
    int limit = 100,
    int offset = 0,
  }) async {
    final partition = 'PATIENT:${_userIdentifier(session)}';
    _validatePatientCollection(collection);
    if (limit < 1 || limit > 500 || offset < 0) {
      throw Exception('Invalid pagination values.');
    }
    return HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals(partition) & row.collection.equals(collection),
      orderBy: (row) => row.updatedAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }

  Future<HospitalOperationalRecord?> getMyPatientRecord(
    Session session,
    String collection,
    String recordKey,
  ) async {
    final partition = 'PATIENT:${_userIdentifier(session)}';
    _validatePatientCollection(collection);
    _validateRecordKey(recordKey);
    return HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(partition) &
          row.collection.equals(collection) &
          row.recordKey.equals(recordKey),
    );
  }

  Future<HospitalOperationalRecord> saveMyPatientRecord(
    Session session,
    String collection,
    String recordKey,
    String payload,
  ) async {
    final identifier = _userIdentifier(session);
    final partition = 'PATIENT:$identifier';
    _validatePatientCollection(collection);
    _validateRecordKey(recordKey);
    if (utf8.encode(payload).length > 256 * 1024) {
      throw Exception('Record payload exceeds 256 KB.');
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic> ||
        (decoded['id'] != null && decoded['id'].toString() != recordKey)) {
      throw Exception('Patient record must be an object with a matching id.');
    }
    if (collection == 'patientAppointments' &&
        !{
          'requested',
          'cancelled',
        }.contains('${decoded['status'] ?? ''}'.toLowerCase())) {
      throw Exception('Patients can only request or cancel appointments.');
    }
    if (collection == 'patientReports' &&
        decoded['isExternalUploaded'] != true) {
      throw Exception(
        'Patient-submitted records must be marked as external uploads.',
      );
    }
    if (collection == 'patientPrescriptions') {
      throw Exception(
        'Only a treating provider can create or change prescriptions.',
      );
    }
    if (collection == 'patientBloodRequests') {
      final group = '${decoded['bloodGroup'] ?? ''}';
      final component = '${decoded['componentType'] ?? ''}';
      final urgency = '${decoded['urgencyLevel'] ?? ''}';
      final units = decoded['unitsNeeded'];
      if (!{'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'}.contains(group) ||
          !{
            'Whole Blood',
            'PRBC',
            'Platelets',
            'SDP',
            'FFP',
          }.contains(component) ||
          units is! int ||
          units < 1 ||
          units > 10 ||
          !{'Routine', 'Urgent', 'Emergency SOS'}.contains(urgency) ||
          '${decoded['hospitalName'] ?? ''}'.trim().isEmpty ||
          '${decoded['contactPhone'] ?? ''}'.trim().isEmpty) {
        throw Exception('Blood request details are invalid.');
      }
      decoded['patientId'] = identifier;
      decoded['status'] = 'Pending';
      decoded.remove('matchedBankName');
    }
    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      if (collection == 'patientAppointments') {
        await _syncPatientAppointmentToHospital(
          session,
          identifier,
          recordKey,
          decoded,
          now,
          transaction,
        );
      }
      if (collection == 'patientBloodRequests') {
        await _syncPatientBloodRequestToHospital(
          session, identifier, recordKey, decoded, now, transaction,
        );
      }
      return _upsertOperationalRecord(
        session,
        HospitalOperationalRecord(
          hospitalKey: partition,
          collection: collection,
          recordKey: recordKey,
          payload: jsonEncode({...decoded, '_owner': identifier}),
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
    });
  }

  Future<void> _syncPatientBloodRequestToHospital(
    Session session,
    String patientIdentifier,
    String patientRecordKey,
    Map<String, dynamic> request,
    DateTime now,
    Transaction transaction,
  ) async {
    final hospitalKey = '${request['hospitalId'] ?? ''}'.trim();
    if (hospitalKey.isEmpty) {
      throw Exception('Select a verified hospital for this blood request.');
    }
    final hospital = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.verificationStatus.equals('verified'),
      transaction: transaction,
    );
    final settings = await HospitalSettingsRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
      transaction: transaction,
    );
    if (hospital == null || settings?.isHospitalDiscoverable != true) {
      throw Exception('This hospital is not currently accepting patient requests.');
    }
    final units = request['unitsNeeded'];
    if (units is! int || units < 1 || units > 10) {
      throw Exception('Blood request units are invalid.');
    }
    final requestKey = 'patient-$patientIdentifier-$patientRecordKey';
    final current = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('bloodRequests') &
          row.recordKey.equals(requestKey),
      transaction: transaction,
    );
    if (current != null) {
      final previous = jsonDecode(current.payload);
      if (previous is! Map<String, dynamic> ||
          previous['patientOwner'] != patientIdentifier) {
        throw Exception('Blood request key is already in use.');
      }
    }
    await _upsertOperationalRecord(
      session,
      HospitalOperationalRecord(
        hospitalKey: hospitalKey,
        collection: 'bloodRequests',
        recordKey: requestKey,
        payload: jsonEncode({
          'id': requestKey,
          'patientRequestId': patientRecordKey,
          'patientOwner': patientIdentifier,
          'patientName': request['patientName'],
          'bloodGroup': request['bloodGroup'],
          'componentType': request['componentType'],
          'requiredUnits': units,
          'allocatedUnits': 0,
          'department': 'Patient request',
          'priority': request['urgencyLevel'] == 'Emergency SOS'
              ? 'critical'
              : request['urgencyLevel'] == 'Urgent' ? 'urgent' : 'normal',
          'status': 'pending',
          'contactPhone': request['contactPhone'],
          'hospitalName': hospital.name,
          'createdAt': request['createdAt'] ?? now.toIso8601String(),
        }),
        createdAt: current?.createdAt ?? now,
        updatedAt: now,
      ),
      transaction: transaction,
    );
  }

  Future<void> _syncPatientAppointmentToHospital(
    Session session,
    String patientIdentifier,
    String patientRecordKey,
    Map<String, dynamic> request,
    DateTime now,
    Transaction transaction,
  ) async {
    final hospitalKey = '${request['hospitalId'] ?? ''}'.trim();
    final doctorKey = '${request['doctorId'] ?? ''}'.trim();
    if (hospitalKey.isEmpty || doctorKey.isEmpty) {
      throw Exception(
        'Select a published hospital and doctor before requesting an appointment.',
      );
    }
    final hospital = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.verificationStatus.equals('verified'),
      transaction: transaction,
    );
    final settings = await HospitalSettingsRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
      transaction: transaction,
    );
    if (hospital == null || settings?.isHospitalDiscoverable != true) {
      throw Exception(
        'This hospital is not currently accepting patient requests.',
      );
    }
    final doctorRow = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('doctors') &
          row.recordKey.equals(doctorKey),
      transaction: transaction,
    );
    if (doctorRow == null)
      throw Exception('Selected doctor is not part of this hospital.');
    final doctor = jsonDecode(doctorRow.payload);
    if (doctor is! Map<String, dynamic>)
      throw Exception('Doctor record is invalid.');
    final doctorStatus =
        '${doctor['availabilityStatus'] ?? doctor['status'] ?? ''}'
            .toLowerCase();
    if (doctorStatus.isNotEmpty &&
        !{'available', 'onduty', 'on duty'}.contains(doctorStatus)) {
      throw Exception(
        'This doctor is not currently accepting appointment requests.',
      );
    }
    final requestedAt = DateTime.tryParse('${request['dateTime'] ?? ''}');
    if (requestedAt == null || !requestedAt.isAfter(now)) {
      throw Exception('Choose a valid future appointment time.');
    }
    final linkedKey = 'patient-$patientIdentifier-$patientRecordKey';
    final existing = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('appointments') &
          row.recordKey.equals(linkedKey),
      transaction: transaction,
    );
    final status = '${request['status']}'.toLowerCase();
    if (status == 'cancelled') {
      if (existing == null) return;
      final current = jsonDecode(existing.payload);
      if (current is! Map<String, dynamic> ||
          current['patientOwner'] != patientIdentifier ||
          !{'pending', 'scheduled'}.contains('${current['status']}')) {
        throw Exception(
          'This appointment can no longer be cancelled from the patient app.',
        );
      }
      await HospitalOperationalRecord.db.updateRow(
        session,
        existing.copyWith(
          payload: jsonEncode({
            ...current,
            'status': 'cancelled',
            'updatedAt': now.toIso8601String(),
          }),
          updatedAt: now,
        ),
        transaction: transaction,
      );
      return;
    }
    final payload = {
      'id': linkedKey,
      'patientRequestId': patientRecordKey,
      'patientOwner': patientIdentifier,
      'patientId': patientIdentifier,
      'patientName': '${request['patientName'] ?? 'Patient'}',
      'doctorId': doctorKey,
      'doctorName': '${doctor['name'] ?? request['doctorName'] ?? ''}',
      'department':
          '${doctor['department'] ?? doctor['specialization'] ?? request['specialty'] ?? ''}',
      'dateTime': requestedAt.toUtc().toIso8601String(),
      'status': 'pending',
      'type': '${request['consultationType'] ?? 'In-person consultation'}',
      'reason': '${request['reasonForVisit'] ?? ''}',
      'updatedAt': now.toIso8601String(),
    };
    await _upsertOperationalRecord(
      session,
      HospitalOperationalRecord(
        hospitalKey: hospitalKey,
        collection: 'appointments',
        recordKey: linkedKey,
        payload: jsonEncode(payload),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
      transaction: transaction,
    );
  }

  Future<bool> deleteMyPatientRecord(
    Session session,
    String collection,
    String recordKey,
  ) async {
    final row = await getMyPatientRecord(session, collection, recordKey);
    if (row == null) return false;
    await HospitalOperationalRecord.db.deleteRow(session, row);
    return true;
  }

  /// Starts a claim for a hospital patient record. A hospital administrator
  /// must verify the patient's identity and approve the request before any
  /// clinical data is connected to this account.
  Future<String> requestHospitalPatientAccountLink(
    Session session,
    String hospitalKey,
    String patientId,
  ) async {
    final user = _userIdentifier(session);
    _validateRecordKey(patientId);
    if (hospitalKey.trim().isEmpty || hospitalKey.length > 160) {
      throw Exception('Hospital selection is invalid.');
    }
    final hospital = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.verificationStatus.equals('verified'),
    );
    final settings = await HospitalSettingsRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
    if (hospital == null || settings?.isHospitalDiscoverable != true) {
      throw Exception('This hospital is not accepting account-link requests.');
    }
    final now = DateTime.now().toUtc();
    final existing = await HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinkRequests'),
      limit: 5000,
    );
    final prior = existing.where((row) {
      final value = jsonDecode(row.payload);
      return value is Map<String, dynamic> &&
          value['requesterUserIdentifier'] == user &&
          value['patientId'] == patientId &&
          value['status'] == 'pending';
    }).firstOrNull;
    if (prior != null) return 'pending';
    final recentRequests = existing.where((row) {
      final value = jsonDecode(row.payload);
      final created = row.createdAt;
      return value is Map<String, dynamic> &&
          value['requesterUserIdentifier'] == user &&
          created.isAfter(now.subtract(const Duration(hours: 1)));
    }).length;
    if (recentRequests >= 5) {
      throw Exception('Too many account-link requests. Try again later.');
    }
    final active = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinks') &
          row.recordKey.equals(patientId),
    );
    if (active != null) {
      final value = jsonDecode(active.payload);
      if (value is Map<String, dynamic> &&
          value['status'] == 'active' &&
          value['patientOwner'] == user) {
        return 'linked';
      }
    }
    final key = 'claim-${now.microsecondsSinceEpoch}-${user.hashCode.abs()}';
    await session.db.transaction((transaction) async {
      await HospitalOperationalRecord.db.insertRow(
        session,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'patientAccountLinkRequests',
          recordKey: key,
          payload: jsonEncode({
            'id': key,
            'patientId': patientId,
            'requesterUserIdentifier': user,
            'status': 'pending',
            'requestedAt': now.toIso8601String(),
          }),
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      await _appendOperationalAudit(
        session, transaction, hospitalKey, 'patientAccountLinkRequests', key,
        'patient_account_link_requested',
      );
    });
    return 'pending';
  }

  /// Lists pending claims for staff authorized to manage hospital accounts.
  Future<String> listHospitalPatientAccountLinkRequests(
    Session session,
    String hospitalKey,
  ) async {
    await _requireAdministrator(session, hospitalKey);
    final rows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinkRequests'),
      orderBy: (row) => row.createdAt,
      orderDescending: true,
      limit: 500,
    );
    return jsonEncode(
      rows
          .map((row) => jsonDecode(row.payload))
          .where(
            (value) =>
                value is Map<String, dynamic> && value['status'] == 'pending',
          )
          .toList(),
    );
  }

  /// Approves or rejects a claim. Approval is blocked unless the hospital
  /// patient record exists and is not already linked to another account.
  Future<bool> reviewHospitalPatientAccountLinkRequest(
    Session session,
    String hospitalKey,
    String requestId,
    bool approve,
  ) async {
    final actor = await _requireAdministrator(session, hospitalKey);
    final request = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinkRequests') &
          row.recordKey.equals(requestId),
    );
    if (request == null) throw Exception('Account-link request not found.');
    final data = jsonDecode(request.payload);
    if (data is! Map<String, dynamic> || data['status'] != 'pending') {
      throw Exception('This account-link request has already been reviewed.');
    }
    final patientId = '${data['patientId'] ?? ''}';
    final user = '${data['requesterUserIdentifier'] ?? ''}';
    if (patientId.isEmpty || user.isEmpty)
      throw Exception('Account-link request is invalid.');
    final patient = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patients') &
          row.recordKey.equals(patientId),
    );
    if (approve && patient == null) {
      throw Exception('The hospital patient record could not be verified.');
    }
    final now = DateTime.now().toUtc();
    await session.db.transaction((transaction) async {
      // Serialize approval of competing accounts for the same patient record.
      // The unique lock-row upsert waits for a concurrent reviewer, after which
      // this transaction rechecks both the request and current link.
      await _upsertOperationalRecord(
        session,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'patientAccountLinkLocks',
          recordKey: patientId,
          payload: '{}',
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      final currentRequest = await HospitalOperationalRecord.db.findFirstRow(
        session,
        where: (row) => row.hospitalKey.equals(hospitalKey) &
            row.collection.equals('patientAccountLinkRequests') &
            row.recordKey.equals(requestId),
        transaction: transaction,
      );
      final lockedRequest = currentRequest == null
          ? null
          : jsonDecode(currentRequest.payload);
      if (currentRequest == null || lockedRequest is! Map<String, dynamic> ||
          lockedRequest['status'] != 'pending') {
        throw Exception('This account-link request has already been reviewed.');
      }
      final lockedUser = '${lockedRequest['requesterUserIdentifier'] ?? ''}';
      if (lockedUser != user) {
        throw Exception('Account-link request is invalid.');
      }
      if ('${lockedRequest['patientId'] ?? ''}' != patientId) {
        throw Exception('Account-link request is invalid.');
      }
      if (approve) {
        final currentPatient = await HospitalOperationalRecord.db.findFirstRow(
          session,
          where: (row) => row.hospitalKey.equals(hospitalKey) &
              row.collection.equals('patients') &
              row.recordKey.equals(patientId),
          transaction: transaction,
        );
        if (currentPatient == null) {
          throw Exception('The hospital patient record could not be verified.');
        }
      }
      final currentLink = await HospitalOperationalRecord.db.findFirstRow(
        session,
        where: (row) => row.hospitalKey.equals(hospitalKey) &
            row.collection.equals('patientAccountLinks') &
            row.recordKey.equals(patientId),
        transaction: transaction,
      );
      final existingLink = currentLink == null ? null : jsonDecode(currentLink.payload);
      if (approve && existingLink is Map<String, dynamic> &&
          existingLink['status'] == 'active' &&
          existingLink['patientOwner'] != user) {
        throw Exception('This patient record is already linked to another account.');
      }
      await _upsertOperationalRecord(
        session,
        currentRequest.copyWith(
          payload: jsonEncode({
            ...lockedRequest,
            'status': approve ? 'approved' : 'rejected',
            'reviewedAt': now.toIso8601String(),
            'reviewedBy': actor.userIdentifier,
            'verificationMethod': 'hospital_admin_review',
          }),
          updatedAt: now,
        ),
        transaction: transaction,
      );
      if (approve) {
        await _upsertOperationalRecord(
          session,
          HospitalOperationalRecord(
            hospitalKey: hospitalKey,
            collection: 'patientAccountLinks',
            recordKey: patientId,
            payload: jsonEncode({
              'patientId': patientId,
              'patientOwner': user,
              'status': 'active',
              'linkedAt': now.toIso8601String(),
              'approvedBy': actor.userIdentifier,
            }),
            createdAt: currentLink?.createdAt ?? now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      }
      await _appendOperationalAudit(
        session, transaction, hospitalKey, 'patientAccountLinkRequests', requestId,
        approve ? 'patient_account_link_approved' : 'patient_account_link_rejected',
      );
    });
    return true;
  }

  /// Returns only the current user's approved hospital links.
  Future<String> listMyHospitalPatientAccountLinks(Session session) async {
    final user = _userIdentifier(session);
    final rows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) => row.collection.equals('patientAccountLinks'),
      limit: 5000,
    );
    final links = <Map<String, dynamic>>[];
    for (final row in rows) {
      final value = jsonDecode(row.payload);
      if (value is Map<String, dynamic> &&
          value['status'] == 'active' &&
          value['patientOwner'] == user) {
        links.add({
          'hospitalKey': row.hospitalKey,
          'patientId': value['patientId'],
          'linkedAt': value['linkedAt'],
        });
      }
    }
    return jsonEncode(links);
  }

  Future<String> listMyHospitalPatientAccountLinkRequests(
    Session session,
  ) async {
    final user = _userIdentifier(session);
    final rows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) => row.collection.equals('patientAccountLinkRequests'),
      limit: 5000,
    );
    final requests = <Map<String, dynamic>>[];
    for (final row in rows) {
      final value = jsonDecode(row.payload);
      if (value is Map<String, dynamic> &&
          value['requesterUserIdentifier'] == user) {
        requests.add({
          'requestId': row.recordKey,
          'hospitalKey': row.hospitalKey,
          'patientId': value['patientId'],
          'status': value['status'],
          'requestedAt': value['requestedAt'],
          'reviewedAt': value['reviewedAt'],
        });
      }
    }
    return jsonEncode(requests);
  }

  /// A patient can revoke only links owned by their authenticated account.
  Future<bool> revokeMyHospitalPatientAccountLink(
    Session session,
    String hospitalKey,
    String patientId,
  ) async {
    final user = _userIdentifier(session);
    final link = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinks') &
          row.recordKey.equals(patientId),
    );
    if (link == null) return false;
    final data = jsonDecode(link.payload);
    if (data is! Map<String, dynamic> ||
        data['patientOwner'] != user ||
        data['status'] != 'active') {
      throw Exception('This account link is not owned by your account.');
    }
    final now = DateTime.now().toUtc();
    final partition = 'PATIENT:$user';
    await session.db.transaction((transaction) async {
      await HospitalOperationalRecord.db.updateRow(
        session,
        link.copyWith(
          payload: jsonEncode({
            ...data,
            'status': 'revoked',
            'revokedAt': now.toIso8601String(),
          }),
          updatedAt: now,
        ),
        transaction: transaction,
      );
      await _appendOperationalAudit(
        session, transaction, hospitalKey, 'patientAccountLinks', patientId,
        'patient_account_link_revoked',
      );
      for (final collection in ['patientReports', 'patientPrescriptions']) {
        final patientRows = await HospitalOperationalRecord.db.find(
          session,
          where: (row) =>
              row.hospitalKey.equals(partition) &
              row.collection.equals(collection),
          limit: 5000,
          transaction: transaction,
        );
        for (final patientRow in patientRows) {
          final payload = jsonDecode(patientRow.payload);
          final sourceHospital = payload is Map<String, dynamic>
              ? '${payload['sourceHospitalKey'] ?? payload['hospitalId'] ?? ''}'
              : '';
          if (sourceHospital == hospitalKey) {
            await HospitalOperationalRecord.db.deleteRow(
              session,
              patientRow,
              transaction: transaction,
            );
          }
        }
      }
      final reports = await HospitalOperationalRecord.db.find(
        session,
        where: (row) =>
            row.hospitalKey.equals(hospitalKey) &
            row.collection.equals('diagnosticReports'),
        limit: 5000,
        transaction: transaction,
      );
      for (final report in reports) {
        final payload = jsonDecode(report.payload);
        if (payload is Map<String, dynamic> &&
            '${payload['patientId'] ?? ''}' == patientId &&
            payload['releasedToPatient'] == true) {
          await HospitalOperationalRecord.db.updateRow(
            session,
            report.copyWith(
              payload: jsonEncode({
                ...payload,
                'releasedToPatient': false,
                'sharedWithPatientAt': null,
              }),
              updatedAt: now,
            ),
            transaction: transaction,
          );
        }
      }
    });
    return true;
  }

  Future<bool> checkMyPatientReviewEligibility(
    Session session,
    String targetType,
    String targetId,
  ) async {
    final identifier = _userIdentifier(session);
    if (!_isReviewTargetValid(targetType, targetId)) return false;
    final appointments = await HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals('PATIENT:$identifier') &
          row.collection.equals('patientAppointments'),
      limit: 500,
    );
    for (final row in appointments) {
      final appointment = jsonDecode(row.payload);
      if (appointment is! Map<String, dynamic> ||
          '${appointment['status']}'.toLowerCase() != 'completed') {
        continue;
      }
      if (targetType == 'hospital') {
        final profile = await HospitalProfileRecord.db.findFirstRow(
          session,
          where: (item) =>
              item.hospitalKey.equals(targetId) &
              item.verificationStatus.equals('verified'),
        );
        if (profile != null &&
            (_sameText(appointment['hospitalName'], profile.displayName) ||
                _sameText(appointment['hospitalName'], profile.name))) {
          return true;
        }
      } else {
        final doctors = await HospitalOperationalRecord.db.find(
          session,
          where: (item) => item.collection.equals('doctors'),
          limit: 2000,
        );
        for (final doctorRow in doctors.where(
          (item) => item.recordKey == targetId,
        )) {
          final doctor = jsonDecode(doctorRow.payload);
          final profile = await HospitalProfileRecord.db.findFirstRow(
            session,
            where: (item) =>
                item.hospitalKey.equals(doctorRow.hospitalKey) &
                item.verificationStatus.equals('verified'),
          );
          if (doctor is Map<String, dynamic> &&
              profile != null &&
              _sameText(appointment['doctorName'], doctor['name']) &&
              _sameText(appointment['hospitalName'], profile.displayName)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<String> listPatientReviews(
    Session session,
    String targetType,
    String targetId,
  ) async {
    _userIdentifier(session);
    if (!_isReviewTargetValid(targetType, targetId)) return '[]';
    final rows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) => row.collection.equals('patientReviews'),
      orderBy: (row) => row.updatedAt,
      orderDescending: true,
      limit: 5000,
    );
    final reviews = <Map<String, dynamic>>[];
    for (final row in rows) {
      final value = jsonDecode(row.payload);
      if (value is! Map<String, dynamic> ||
          value['targetType'] != targetType ||
          value['targetId'] != targetId) {
        continue;
      }
      reviews.add({
        'id': row.recordKey,
        'hospitalId': targetId,
        'patientId': 'Patient',
        'ratingScore': value['ratingScore'],
        'feedback': value['feedback'],
        'date': value['createdAt'],
        'createdAt': value['createdAt'],
        'updatedAt': value['updatedAt'],
      });
    }
    return jsonEncode(reviews);
  }

  Future<String> createPatientReview(
    Session session,
    String targetType,
    String targetId,
    double rating,
    String feedback,
  ) async {
    final identifier = _userIdentifier(session);
    if (rating < 1 ||
        rating > 5 ||
        !rating.isFinite ||
        feedback.trim().isEmpty ||
        feedback.trim().length > 2000 ||
        !_isReviewTargetValid(targetType, targetId)) {
      throw Exception('Review details are invalid.');
    }
    if (!await checkMyPatientReviewEligibility(session, targetType, targetId)) {
      throw Exception(
        'A completed appointment at this hospital or with this doctor is required to review.',
      );
    }
    final partition = 'PATIENT:$identifier';
    final reviewKey = 'review:$targetType:$targetId';
    final lockKey = 'review-lock:$targetType:$targetId';
    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      await _upsertOperationalRecord(
        session,
        HospitalOperationalRecord(
          hospitalKey: partition,
          collection: 'patientReviews',
          recordKey: lockKey,
          payload: '{}',
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      final existing = await HospitalOperationalRecord.db.findFirstRow(
        session,
        where: (row) =>
            row.hospitalKey.equals(partition) &
            row.collection.equals('patientReviews') &
            row.recordKey.equals(reviewKey),
        transaction: transaction,
      );
      if (existing != null)
        throw Exception('You have already reviewed this provider.');
      final payload = {
        'id': reviewKey,
        'targetType': targetType,
        'targetId': targetId,
        'ratingScore': rating,
        'feedback': feedback.trim(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      await HospitalOperationalRecord.db.insertRow(
        session,
        HospitalOperationalRecord(
          hospitalKey: partition,
          collection: 'patientReviews',
          recordKey: reviewKey,
          payload: jsonEncode(payload),
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      return jsonEncode({
        ...payload,
        'hospitalId': targetId,
        'patientId': 'Patient',
        'date': now.toIso8601String(),
      });
    });
  }

  bool _sameText(Object? first, Object? second) =>
      '${first ?? ''}'.trim().toLowerCase() ==
      '${second ?? ''}'.trim().toLowerCase();

  bool _isReviewTargetValid(String targetType, String targetId) {
    return targetId.isNotEmpty &&
        targetId.length <= 139 &&
        (targetType == 'hospital' || targetType == 'doctor');
  }

  void _validatePatientCollection(String collection) {
    if (!_patientCollections.contains(collection)) {
      throw Exception('Unsupported patient portal collection.');
    }
  }

  Future<List<HospitalOperationalRecord>> listOperationalRecords(
    Session session,
    String hospitalKey,
    String collection, {
    int limit = 100,
    int offset = 0,
  }) async {
    final membership = await _requireMembership(session, hospitalKey);
    _validateCollection(collection);
    _authorizeOperationalRead(membership.role, collection);
    if (limit < 1 || limit > 500 || offset < 0) {
      throw Exception('Invalid pagination values.');
    }
    final rows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals(collection),
      orderBy: (row) => row.updatedAt,
      orderDescending: true,
      limit: membership.role == 'doctor' ? 10000 : limit,
      offset: membership.role == 'doctor' ? 0 : offset,
    );
    if (membership.role != 'doctor') return rows;
    final doctorRow = await _myDoctorRecord(session, hospitalKey);
    final doctor = jsonDecode(doctorRow.payload) as Map<String, dynamic>;
    final scoped = rows
        .where(
          (row) => _doctorOwnsRecord(
            row,
            doctorRow.recordKey,
            '${doctor['name'] ?? ''}',
          ),
        )
        .toList();
    return scoped.skip(offset).take(limit).toList(growable: false);
  }

  Future<HospitalOperationalRecord?> getOperationalRecord(
    Session session,
    String hospitalKey,
    String collection,
    String recordKey,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    _validateCollection(collection);
    _validateRecordKey(recordKey);
    _authorizeOperationalRead(membership.role, collection);
    final row = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals(collection) &
          row.recordKey.equals(recordKey),
    );
    if (membership.role != 'doctor' || row == null) return row;
    final doctorRow = await _myDoctorRecord(session, hospitalKey);
    final doctor = jsonDecode(doctorRow.payload) as Map<String, dynamic>;
    if (!_doctorOwnsRecord(
      row,
      doctorRow.recordKey,
      '${doctor['name'] ?? ''}',
    )) {
      throw Exception('This record is outside your assigned patient care.');
    }
    return row;
  }

  /// Tenant-scoped JSON records back hospital operational modules. The
  /// database uniqueness constraint makes concurrent upserts deterministic.
  Future<HospitalOperationalRecord> saveOperationalRecord(
    Session session,
    String hospitalKey,
    String collection,
    String recordKey,
    String payload,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    _validateCollection(collection);
    _validateRecordKey(recordKey);
    await _authorizeOperationalWrite(session, hospitalKey, membership.role, collection);
    if (utf8.encode(payload).length > 256 * 1024) {
      throw Exception('Record payload exceeds 256 KB.');
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic> && decoded is! List) {
      throw Exception(
        'Operational record payload must be a JSON object or list.',
      );
    }
    _validateOperationalPayload(collection, recordKey, decoded);
    if (collection == 'admissions' &&
        decoded is Map<String, dynamic> &&
        decoded['admissionStatus'] == 'admitted') {
      throw Exception(
        'Use the patient-scoped admission endpoint to create or update active admissions.',
      );
    }
    final existing = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals(collection) &
          row.recordKey.equals(recordKey),
    );
    if (membership.role == 'doctor') {
      final profile = await _myDoctorRecord(session, hospitalKey);
      final doctor = jsonDecode(profile.payload) as Map<String, dynamic>;
      final allowed = existing != null
          ? _doctorOwnsRecord(
              existing,
              profile.recordKey,
              '${doctor['name'] ?? ''}',
            )
          : _doctorOwnsPayload(
              collection,
              recordKey,
              payload,
              profile.recordKey,
              '${doctor['name'] ?? ''}',
            );
      if (!allowed)
        throw Exception(
          'You can only change records assigned to your doctor profile.',
        );
    }
    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      final saved = await _upsertOperationalRecord(
        session,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: collection,
          recordKey: recordKey,
          payload: payload,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      if (collection == 'appointments' && decoded is Map<String, dynamic>) {
        await _syncLinkedPatientAppointment(
          session,
          hospitalKey,
          recordKey,
          decoded,
          now,
          transaction,
        );
      }
      if (collection == 'bloodRequests' && decoded is Map<String, dynamic>) {
        await _syncHospitalBloodRequestStatusToPatient(
          session, decoded, now, transaction,
        );
      }
      if (collection == 'prescriptions' &&
          membership.role == 'doctor' &&
          decoded is Map<String, dynamic>) {
        await _syncDoctorPrescriptionToPatient(
          session,
          hospitalKey,
          recordKey,
          decoded,
          now,
          transaction,
        );
      }
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        collection,
        recordKey,
        existing == null ? 'create' : 'update',
      );
      return saved;
    });
  }

  /// Mirrors provider decisions to the patient's private appointment record.
  /// The link is written only by the patient booking transaction and is scoped
  /// to that patient's partition; callers cannot select another partition.
  Future<void> _syncLinkedPatientAppointment(
    Session session,
    String hospitalKey,
    String hospitalRecordKey,
    Map<String, dynamic> appointment,
    DateTime now,
    Transaction transaction,
  ) async {
    final owner = '${appointment['patientOwner'] ?? ''}'.trim();
    final requestKey = '${appointment['patientRequestId'] ?? ''}'.trim();
    if (owner.isEmpty ||
        requestKey.isEmpty ||
        hospitalRecordKey != 'patient-$owner-$requestKey') {
      return;
    }

    final patientPartition = 'PATIENT:$owner';
    final patientRow = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(patientPartition) &
          row.collection.equals('patientAppointments') &
          row.recordKey.equals(requestKey),
      transaction: transaction,
    );
    if (patientRow == null) return;
    final patientAppointment = jsonDecode(patientRow.payload);
    if (patientAppointment is! Map<String, dynamic> ||
        patientAppointment['_owner'] != owner ||
        '${patientAppointment['hospitalId'] ?? ''}' != hospitalKey) {
      return;
    }

    final priorDate = patientAppointment['dateTime'];
    final nextDate = appointment['dateTime'];
    final hospitalStatus = '${appointment['status'] ?? ''}'.toLowerCase();
    var patientStatus = switch (hospitalStatus) {
      'pending' => 'Requested',
      'scheduled' ||
      'confirmed' ||
      'checkedin' ||
      'checked_in' ||
      'waiting' ||
      'inconsultation' ||
      'in_consultation' ||
      'inprogress' => 'Confirmed',
      'completed' => 'Completed',
      'cancelled' || 'rejected' => 'Cancelled',
      'noshow' || 'no_show' || 'missed' => 'Missed',
      _ => '${patientAppointment['status'] ?? 'Requested'}',
    };
    patientAppointment['status'] = patientStatus;
    patientAppointment['updatedAt'] = now.toIso8601String();
    if (nextDate != null) patientAppointment['dateTime'] = nextDate;
    if (priorDate != null &&
        nextDate != null &&
        priorDate.toString() != nextDate.toString()) {
      if (patientStatus == 'Confirmed') patientStatus = 'Rescheduled';
      patientAppointment['status'] = patientStatus;
      patientAppointment['rescheduledFrom'] = priorDate;
      patientAppointment['rescheduledAt'] = now.toIso8601String();
    }
    if (appointment['cancellationReason'] != null) {
      patientAppointment['cancellationReason'] =
          appointment['cancellationReason'];
    }
    await _upsertOperationalRecord(
      session,
      HospitalOperationalRecord(
        hospitalKey: patientPartition,
        collection: 'patientAppointments',
        recordKey: requestKey,
        payload: jsonEncode(patientAppointment),
        createdAt: patientRow.createdAt,
        updatedAt: now,
      ),
      transaction: transaction,
    );
  }

  /// Copies a treating doctor's signed prescription to the patient's private
  /// portal only when an approved hospital account link is active.
  Future<void> _syncDoctorPrescriptionToPatient(
    Session session,
    String hospitalKey,
    String prescriptionKey,
    Map<String, dynamic> prescription,
    DateTime now,
    Transaction transaction,
  ) async {
    final patientIdentifier = '${prescription['patientId'] ?? ''}'.trim();
    if (patientIdentifier.isEmpty ||
        '${prescription['status'] ?? ''}'.toLowerCase() == 'draft') {
      return;
    }
    final link = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinks') &
          row.recordKey.equals(patientIdentifier),
      transaction: transaction,
    );
    if (link == null) return;
    final linkData = jsonDecode(link.payload);
    if (linkData is! Map<String, dynamic> || linkData['status'] != 'active')
      return;
    final patientOwner = '${linkData['patientOwner'] ?? ''}';
    if (patientOwner.isEmpty) return;
    final patientPartition = 'PATIENT:$patientOwner';
    final doctorProfile = await _myDoctorRecord(session, hospitalKey);

    final patientPayload = <String, dynamic>{
      'id': prescriptionKey,
      'patientId': patientOwner,
      'hospitalId': hospitalKey,
      'doctorId': doctorProfile.recordKey,
      'doctorName': prescription['doctorName'] ?? '',
      'appointmentId': prescription['appointmentId'],
      'prescriptionReference':
          prescription['prescriptionReference'] ?? prescriptionKey,
      'signedAt': prescription['signedAt'] ?? now.toIso8601String(),
      'status': prescription['status'] ?? 'active',
      'pharmacyFulfillmentStatus':
          prescription['pharmacyFulfillmentStatus'] ?? 'pending',
      'medications': prescription['medications'] ?? const [],
      'clinicalNotes': prescription['clinicalNotes'],
      'instructions': prescription['instructions'] ?? '',
      'createdAt': prescription['createdAt'] ?? now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      '_owner': patientOwner,
    };
    final existing = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(patientPartition) &
          row.collection.equals('patientPrescriptions') &
          row.recordKey.equals(prescriptionKey),
      transaction: transaction,
    );
    await _upsertOperationalRecord(
      session,
      HospitalOperationalRecord(
        hospitalKey: patientPartition,
        collection: 'patientPrescriptions',
        recordKey: prescriptionKey,
        payload: jsonEncode(patientPayload),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
      transaction: transaction,
    );
  }

  /// Saves a related set of operational rows and their audit events as one
  /// database transaction. Used for bed transfers and blood allocation so a
  /// failed write cannot leave only half of a workflow persisted.
  Future<List<HospitalOperationalRecord>> saveOperationalRecords(
    Session session,
    String hospitalKey,
    List<String> collections,
    List<String> recordKeys,
    List<String> payloads,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    if (recordKeys.isEmpty ||
        recordKeys.length != payloads.length ||
        recordKeys.length != collections.length ||
        recordKeys.length > 100) {
      throw Exception(
        'A batch must contain between 1 and 100 matching collections, keys and payloads.',
      );
    }
    final parsed = <Map<String, dynamic>>[];
    for (var i = 0; i < recordKeys.length; i++) {
      final key = recordKeys[i];
      final collection = collections[i];
      final payload = payloads[i];
      _validateCollection(collection);
      await _authorizeOperationalWrite(session, hospitalKey, membership.role, collection);
      _validateRecordKey(key);
      if (utf8.encode(payload).length > 256 * 1024) {
        throw Exception('Record payload exceeds 256 KB.');
      }
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Operational record payload must be a JSON object.');
      }
      _validateOperationalPayload(collection, key, decoded);
      if (collection == 'admissions' &&
          decoded['admissionStatus'] == 'admitted') {
        throw Exception(
          'Use the patient-scoped admission endpoint to create or update active admissions.',
        );
      }
      parsed.add(decoded);
    }
    if (List.generate(
          recordKeys.length,
          (i) => '${collections[i]}:${recordKeys[i]}',
        ).toSet().length !=
        recordKeys.length) {
      throw Exception('A batch cannot contain duplicate records.');
    }
    final existingByKey = <String, HospitalOperationalRecord?>{};
    for (var i = 0; i < recordKeys.length; i++) {
      final key = recordKeys[i];
      final collection = collections[i];
      existingByKey['$collection:$key'] = await HospitalOperationalRecord.db
          .findFirstRow(
            session,
            where: (row) =>
                row.hospitalKey.equals(hospitalKey) &
                row.collection.equals(collection) &
                row.recordKey.equals(key),
          );
    }
    if (membership.role == 'doctor') {
      final profile = await _myDoctorRecord(session, hospitalKey);
      final doctor = jsonDecode(profile.payload) as Map<String, dynamic>;
      for (var i = 0; i < recordKeys.length; i++) {
        final existing = existingByKey['${collections[i]}:${recordKeys[i]}'];
        final allowed = existing != null
            ? _doctorOwnsRecord(
                existing,
                profile.recordKey,
                '${doctor['name'] ?? ''}',
              )
            : _doctorOwnsPayload(
                collections[i],
                recordKeys[i],
                jsonEncode(parsed[i]),
                profile.recordKey,
                '${doctor['name'] ?? ''}',
              );
        if (!allowed)
          throw Exception(
            'You can only change records assigned to your doctor profile.',
          );
      }
    }
    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      final saved = <HospitalOperationalRecord>[];
      for (var i = 0; i < recordKeys.length; i++) {
        final key = recordKeys[i];
        final collection = collections[i];
        final existing = existingByKey['$collection:$key'];
        final row = await _upsertOperationalRecord(
          session,
          HospitalOperationalRecord(
            hospitalKey: hospitalKey,
            collection: collection,
            recordKey: key,
            payload: jsonEncode(parsed[i]),
            createdAt: now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
        await _appendOperationalAudit(
          session,
          transaction,
          hospitalKey,
          collection,
          key,
          existing == null ? 'create' : 'update',
        );
        if (collection == 'bloodRequests') {
          await _syncHospitalBloodRequestStatusToPatient(
            session, parsed[i], now, transaction,
          );
        }
        saved.add(row);
      }
      return saved;
    });
  }

  Future<void> _syncHospitalBloodRequestStatusToPatient(
    Session session,
    Map<String, dynamic> request,
    DateTime now,
    Transaction transaction,
  ) async {
    final owner = '${request['patientOwner'] ?? ''}'.trim();
    final patientRequestId = '${request['patientRequestId'] ?? ''}'.trim();
    if (owner.isEmpty || patientRequestId.isEmpty) return;
    final partition = 'PATIENT:$owner';
    final patientRecord = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(partition) &
          row.collection.equals('patientBloodRequests') &
          row.recordKey.equals(patientRequestId),
      transaction: transaction,
    );
    if (patientRecord == null) return;
    final patientPayload = jsonDecode(patientRecord.payload);
    if (patientPayload is! Map<String, dynamic> ||
        patientPayload['_owner'] != owner) return;
    final hospitalStatus = '${request['status'] ?? 'pending'}';
    final status = switch (hospitalStatus.toLowerCase()) {
      'fulfilled' || 'allocated' || 'completed' => 'Fulfilled',
      'partiallyallocated' || 'partially allocated' => 'Partially Matched',
      'rejected' || 'cancelled' => 'Cancelled',
      _ => 'Pending',
    };
    await _upsertOperationalRecord(
      session,
      patientRecord.copyWith(
        payload: jsonEncode({...patientPayload, 'status': status}),
        updatedAt: now,
      ),
      transaction: transaction,
    );
  }

  /// Creates an active admission while serializing competing admissions for
  /// the same patient. A private lock row is upserted first inside the same
  /// transaction; PostgreSQL's unique-key conflict lock makes a concurrent
  /// request wait, then re-check the committed active admission.
  Future<HospitalOperationalRecord> createAdmission(
    Session session,
    String hospitalKey,
    String patientId,
    String recordKey,
    String payload,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    await _authorizeOperationalWrite(session, hospitalKey, membership.role, 'admissions');
    _validateRecordKey(patientId);
    _validateRecordKey(recordKey);
    if (utf8.encode(payload).length > 256 * 1024) {
      throw Exception('Record payload exceeds 256 KB.');
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Admission payload must be an object.');
    }
    final admission = decoded['admission'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(decoded['admission'] as Map)
        : decoded;
    final isUpdate = decoded['operation'] == 'update';
    if (admission['id']?.toString() != recordKey ||
        admission['patientId']?.toString() != patientId) {
      throw Exception('Admission id and patient id must match the request.');
    }
    if (admission['admissionStatus'] != 'admitted') {
      throw Exception('This endpoint only creates active admissions.');
    }
    final rows = <(String, String, Map<String, dynamic>)>[];
    if (decoded['patient'] is Map<String, dynamic> &&
        decoded['patientLink'] is Map<String, dynamic>) {
      final patient = Map<String, dynamic>.from(decoded['patient'] as Map);
      final patientLink = Map<String, dynamic>.from(
        decoded['patientLink'] as Map,
      );
      rows.add(('patients', patientId, patient));
      rows.add(('patientLinks', '${patientLink['id']}', patientLink));
    }
    rows.add(('admissions', recordKey, admission));
    for (final (collection, key, value) in rows) {
      await _authorizeOperationalWrite(session, hospitalKey, membership.role, collection);
      _validateRecordKey(key);
      _validateOperationalPayload(collection, key, value);
    }

    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      // The lock collection is internal and intentionally not exposed by the
      // operational collection allowlist.
      await _upsertOperationalRecord(
        session,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'admissionLocks',
          recordKey: patientId,
          payload: '{}',
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );

      final matchingLinks = rows
          .where((row) => row.$1 == 'patientLinks')
          .toList();
      final patientLink = matchingLinks.isEmpty ? null : matchingLinks.first;
      if (patientLink != null) {
        final mrn = patientLink.$3['mrnNumber']?.toString();
        if (mrn != null && mrn.isNotEmpty) {
          await _upsertOperationalRecord(
            session,
            HospitalOperationalRecord(
              hospitalKey: hospitalKey,
              collection: 'admissionLocks',
              recordKey: 'mrn:$mrn',
              payload: '{}',
              createdAt: now,
              updatedAt: now,
            ),
            transaction: transaction,
          );
          final existingLinks = await HospitalOperationalRecord.db.find(
            session,
            where: (row) =>
                row.hospitalKey.equals(hospitalKey) &
                row.collection.equals('patientLinks'),
            transaction: transaction,
          );
          final duplicateLink = existingLinks.any((row) {
            if (row.recordKey == patientLink.$2) return false;
            final value = jsonDecode(row.payload);
            return value is Map<String, dynamic> &&
                (value['patientId']?.toString() == patientId ||
                    value['mrnNumber']?.toString().toLowerCase() ==
                        mrn.toLowerCase());
          });
          if (duplicateLink) {
            throw Exception(
              'Patient already has a hospital link or MRN is already in use.',
            );
          }
        }
      }

      final existingAdmissions = await HospitalOperationalRecord.db.find(
        session,
        where: (row) =>
            row.hospitalKey.equals(hospitalKey) &
            row.collection.equals('admissions'),
        transaction: transaction,
      );
      final matchingAdmissions = existingAdmissions
          .where((row) => row.recordKey == recordKey)
          .toList();
      final existingAdmission = matchingAdmissions.isEmpty
          ? null
          : matchingAdmissions.first;
      final existingAdmissionPayload = existingAdmission == null
          ? null
          : jsonDecode(existingAdmission.payload);
      if (isUpdate &&
          (existingAdmissionPayload is! Map<String, dynamic> ||
              existingAdmissionPayload['patientId']?.toString() != patientId ||
              existingAdmissionPayload['admissionStatus'] != 'admitted')) {
        throw Exception(
          'Only an existing active admission can be updated this way.',
        );
      }
      final hasActiveAdmission =
          !isUpdate &&
          existingAdmissions.any((row) {
            final value = jsonDecode(row.payload);
            return value is Map<String, dynamic> &&
                value['patientId']?.toString() == patientId &&
                value['admissionStatus'] == 'admitted';
          });
      if (hasActiveAdmission) {
        throw Exception('Patient already has an active admission.');
      }

      if ('${admission['bedId'] ?? ''}'.isEmpty) {
        final availableBedRows = await HospitalOperationalRecord.db.find(
          session,
          where: (row) =>
              row.hospitalKey.equals(hospitalKey) &
              (row.collection.equals('beds') | row.collection.equals('icu')),
          transaction: transaction,
        );
        final ward = '${admission['ward'] ?? ''}'.trim().toLowerCase();
        final candidates = availableBedRows.where((row) {
          final value = jsonDecode(row.payload);
          if (value is! Map<String, dynamic> ||
              value['status'] != 'available') {
            return false;
          }
          final bedWard = '${value['ward'] ?? ''}'.trim().toLowerCase();
          return ward.isEmpty || bedWard.isEmpty || bedWard == ward;
        }).toList();
        for (final candidate in candidates) {
          await _upsertOperationalRecord(
            session,
            HospitalOperationalRecord(
              hospitalKey: hospitalKey,
              collection: 'admissionLocks',
              recordKey: 'bed:${candidate.collection}:${candidate.recordKey}',
              payload: '{}',
              createdAt: now,
              updatedAt: now,
            ),
            transaction: transaction,
          );
          final bed = await HospitalOperationalRecord.db.findFirstRow(
            session,
            where: (row) =>
                row.hospitalKey.equals(hospitalKey) &
                row.collection.equals(candidate.collection) &
                row.recordKey.equals(candidate.recordKey),
            transaction: transaction,
          );
          if (bed == null) continue;
          final value = Map<String, dynamic>.from(
            jsonDecode(bed.payload) as Map,
          );
          if (value['status'] != 'available') continue;
          value['status'] = 'occupied';
          value['patientId'] = patientId;
          value['admissionId'] = recordKey;
          value['updatedAt'] = now.toIso8601String();
          admission['bedId'] = bed.recordKey;
          rows.add((bed.collection, bed.recordKey, value));
          _validateOperationalPayload(bed.collection, bed.recordKey, value);
          break;
        }
      }

      HospitalOperationalRecord? savedAdmission;
      for (final (collection, key, value) in rows) {
        final existing = await HospitalOperationalRecord.db.findFirstRow(
          session,
          where: (row) =>
              row.hospitalKey.equals(hospitalKey) &
              row.collection.equals(collection) &
              row.recordKey.equals(key),
          transaction: transaction,
        );
        final saved = await _upsertOperationalRecord(
          session,
          HospitalOperationalRecord(
            hospitalKey: hospitalKey,
            collection: collection,
            recordKey: key,
            payload: jsonEncode(value),
            createdAt: now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
        await _appendOperationalAudit(
          session,
          transaction,
          hospitalKey,
          collection,
          key,
          existing == null ? 'create' : 'update',
        );
        if (collection == 'admissions') savedAdmission = saved;
      }
      return savedAdmission!;
    });
  }

  Future<bool> deleteOperationalRecord(
    Session session,
    String hospitalKey,
    String collection,
    String recordKey,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    _validateCollection(collection);
    _validateRecordKey(recordKey);
    await _authorizeOperationalWrite(session, hospitalKey, membership.role, collection);
    final row = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (item) =>
          item.hospitalKey.equals(hospitalKey) &
          item.collection.equals(collection) &
          item.recordKey.equals(recordKey),
    );
    if (row == null) return false;
    return session.db.transaction((transaction) async {
      await HospitalOperationalRecord.db.deleteRow(
        session,
        row,
        transaction: transaction,
      );
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        collection,
        recordKey,
        'delete',
      );
      return true;
    });
  }

  Future<List<HospitalAuditEvent>> getOperationalAuditEvents(
    Session session,
    String hospitalKey, {
    int limit = 100,
    int offset = 0,
  }) async {
    await _requireAdministrator(session, hospitalKey);
    if (limit < 1 || limit > 500 || offset < 0) {
      throw Exception('Invalid pagination values.');
    }
    return HospitalAuditEvent.db.find(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
      orderBy: (row) => row.occurredAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }

  Future<void> logAuditAction(
    Session session,
    String hospitalKey,
    String action,
    String targetEntityType,
    String targetEntityId,
    String details,
  ) async {
    await _requireMembership(session, hospitalKey);
    const allowedActions = {
      'create',
      'read',
      'update',
      'delete',
      'login',
      'logout',
      'permissionDenied',
    };
    if (!allowedActions.contains(action))
      throw Exception('Unsupported audit action.');
    _validateRecordKey(targetEntityType);
    _validateRecordKey(targetEntityId);
    if (utf8.encode(details).length > 16 * 1024)
      throw Exception('Audit details exceed 16 KB.');
    await HospitalAuditEvent.db.insertRow(
      session,
      HospitalAuditEvent(
        hospitalKey: hospitalKey,
        actorUserIdentifier: _userIdentifier(session),
        action: action,
        collection: targetEntityType,
        recordKey: targetEntityId,
        occurredAt: DateTime.now().toUtc(),
        details: details,
      ),
    );
  }

  Future<void> _appendOperationalAudit(
    Session session,
    Transaction transaction,
    String hospitalKey,
    String collection,
    String recordKey,
    String action,
  ) async {
    await HospitalAuditEvent.db.insertRow(
      session,
      HospitalAuditEvent(
        hospitalKey: hospitalKey,
        actorUserIdentifier: _userIdentifier(session),
        action: action,
        collection: collection,
        recordKey: recordKey,
        occurredAt: DateTime.now().toUtc(),
        details: '',
      ),
      transaction: transaction,
    );
  }

  Future<HospitalOperationalRecord> _upsertOperationalRecord(
    Session session,
    HospitalOperationalRecord incoming, {
    Transaction? transaction,
  }) async {
    final inserted = await HospitalOperationalRecord.db.insert(
      session,
      [incoming],
      transaction: transaction,
      ignoreConflicts: true,
    );
    if (inserted.isNotEmpty) return inserted.first;
    final existing = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(incoming.hospitalKey) &
          row.collection.equals(incoming.collection) &
          row.recordKey.equals(incoming.recordKey),
      transaction: transaction,
    );
    if (existing == null) {
      throw StateError('Record conflict could not be resolved.');
    }
    return HospitalOperationalRecord.db.updateRow(
      session,
      existing.copyWith(
        payload: incoming.payload,
        updatedAt: incoming.updatedAt,
      ),
      transaction: transaction,
    );
  }

  void _validateCollection(String collection) {
    if (!_operationalCollections.contains(collection)) {
      throw Exception('Unsupported hospital record collection.');
    }
  }

  void _validateOperationalPayload(
    String collection,
    String key,
    Object? payload,
  ) {
    if (payload is! Map<String, dynamic>) return;
    final id = payload['id'];
    if (id != null && id.toString() != key) {
      throw Exception('Record id must match its database key.');
    }
    final status = payload['status']?.toString();
    final allowedStatuses = switch (collection) {
      'appointments' => {
        'scheduled',
        'checkedIn',
        'inConsultation',
        'inProgress',
        'completed',
        'cancelled',
        'noShow',
        'missed',
      },
      'beds' || 'icu' => {
        'available',
        'occupied',
        'maintenance',
        'reserved',
        'cleaning',
        'sanitizing',
        'blocked',
      },
      'bloodInventory' => {
        'available',
        'reserved',
        'dispatched',
        'expired',
        'quarantined',
        'quarantine',
        'expiringSoon',
        'discarded',
        'issued',
      },
      'bloodRequests' => {
        'pending',
        'approved',
        'fulfilled',
        'rejected',
        'cancelled',
        'partiallyAllocated',
        'allocated',
        'completed',
      },
      'staff' => {
        'active',
        'inShift',
        'onLeave',
        'suspended',
        'terminated',
        'offDuty',
      },
      'emergencies' => {
        'arrived',
        'triaged',
        'waiting',
        'assigned',
        'inTreatment',
        'stabilizing',
        'transferred',
        'discharged',
        'deceased',
        'triage',
        'admitted',
        'cancelled',
      },
      _ => null,
    };
    if (status != null &&
        allowedStatuses != null &&
        !allowedStatuses.contains(status)) {
      throw Exception('Unsupported status for hospital $collection record.');
    }
    for (final field in const [
      'quantity',
      'quantityUnits',
      'units',
      'requiredUnits',
      'allocatedUnits',
      'count',
      'dailyRate',
      'totalBedCapacity',
      'icuCapacity',
      'activeDoctorCount',
      'totalStaffCount',
    ]) {
      final value = payload[field];
      if (value is num && (!value.isFinite || value < 0)) {
        throw Exception('$field must be a non-negative number.');
      }
    }
  }

  void _validateRecordKey(String key) {
    if (key.isEmpty || key.length > 160 || key.trim() != key) {
      throw Exception('Invalid hospital record key.');
    }
  }

  void _validateHospitalInfo(HospitalInfoRecord info) {
    if (info.name.trim().isEmpty ||
        info.code.trim().isEmpty ||
        info.email.trim().isEmpty ||
        info.address.trim().isEmpty ||
        info.totalBedCapacity < 0 ||
        info.icuCapacity < 0 ||
        info.icuCapacity > info.totalBedCapacity ||
        info.activeDoctorCount < 0 ||
        info.totalStaffCount < 0) {
      throw Exception('Hospital information contains invalid values.');
    }
  }

  void _validateHospitalProfile(HospitalProfileRecord profile) {
    if (profile.name.trim().isEmpty ||
        profile.legalName.trim().isEmpty ||
        profile.email.trim().isEmpty ||
        profile.country.trim().isEmpty ||
        profile.latitude < -90 ||
        profile.latitude > 90 ||
        profile.longitude < -180 ||
        profile.longitude > 180 ||
        profile.totalBeds < 0 ||
        profile.icuBeds < 0 ||
        profile.icuBeds > profile.totalBeds ||
        profile.operatingTheatres < 0 ||
        profile.emergencyCapacity < 0) {
      throw Exception('Hospital profile contains invalid values.');
    }
  }

  /// Uploads a file for a patient-owned external medical report and stores it
  /// in private storage. The storage path is derived from the authenticated
  /// user's identifier — the caller never supplies it. After a successful
  /// store the corresponding patientReports record payload is updated with a
  /// [fileReference] block so that the app can show download status.
  ///
  /// Constraints:
  ///  - File must be PDF, PNG, or JPEG and pass a magic-byte check.
  ///  - Max size: 20 MB.
  ///  - The [recordKey] must already exist in the caller's patientReports
  ///    partition (the metadata record is saved first via [saveMyPatientRecord],
  ///    then this endpoint attaches the bytes).
  Future<String> uploadPatientReportFile(
    Session session,
    String recordKey,
    String fileName,
    String mimeType,
    ByteData fileBytes,
  ) async {
    final identifier = _userIdentifier(session);
    _validateRecordKey(recordKey);
    const maxBytes = 20 * 1024 * 1024;
    if (fileBytes.lengthInBytes == 0 || fileBytes.lengthInBytes > maxBytes) {
      throw Exception('Patient report files must be between 1 byte and 20 MB.');
    }
    final extension = fileName.split('.').last.toLowerCase();
    const allowedTypes = {
      'pdf': 'application/pdf',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
    };
    if (allowedTypes[extension] != mimeType.toLowerCase() ||
        !_matchesFileSignature(fileBytes, extension)) {
      throw Exception(
        'Only PDF, PNG, and JPEG files are accepted and the contents must '
        'match the file type.',
      );
    }
    final partition = 'PATIENT:$identifier';
    // Ensure the metadata record exists and belongs to this patient.
    final existing = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(partition) &
          row.collection.equals('patientReports') &
          row.recordKey.equals(recordKey),
    );
    if (existing == null) {
      throw Exception(
        'Save the report metadata record before attaching a file.',
      );
    }
    final path =
        'patient-reports/$identifier/'
        '${DateTime.now().microsecondsSinceEpoch}.$extension';
    await session.storage.storeFile(
      storageId: 'private',
      path: path,
      byteData: fileBytes,
      preventOverwrite: true,
    );
    try {
      final data =
          jsonDecode(existing.payload) as Map<String, dynamic>;
      final now = DateTime.now().toUtc();
      data['fileReference'] = {
        'storagePath': path,
        'fileName': fileName.split(RegExp(r'[/\\]')).last,
        'mimeType': mimeType.toLowerCase(),
        'sizeBytes': fileBytes.lengthInBytes,
        'uploadedAt': now.toIso8601String(),
      };
      data['hasAttachedFile'] = true;
      await _upsertOperationalRecord(
        session,
        HospitalOperationalRecord(
          hospitalKey: partition,
          collection: 'patientReports',
          recordKey: recordKey,
          payload: jsonEncode(data),
          createdAt: existing.createdAt,
          updatedAt: now,
        ),
      );
      return jsonEncode(data['fileReference']);
    } catch (_) {
      await session.storage.deleteFile(storageId: 'private', path: path);
      rethrow;
    }
  }

  /// Returns the raw bytes for a patient's own uploaded report file.
  /// Only the account that owns the patientReports partition can download.
  Future<ByteData> getPatientReportFileBytes(
    Session session,
    String recordKey,
  ) async {
    final identifier = _userIdentifier(session);
    _validateRecordKey(recordKey);
    final partition = 'PATIENT:$identifier';
    final record = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(partition) &
          row.collection.equals('patientReports') &
          row.recordKey.equals(recordKey),
    );
    if (record == null) throw Exception('Report not found.');
    final payload = jsonDecode(record.payload) as Map<String, dynamic>;
    final reference = payload['fileReference'];
    if (reference is! Map || reference['storagePath'] is! String) {
      throw Exception('This report does not have an attached file.');
    }
    final bytes = await session.storage.retrieveFile(
      storageId: 'private',
      path: reference['storagePath'] as String,
    );
    if (bytes == null) {
      throw Exception('Report file is missing from private storage.');
    }
    return bytes;
  }

  bool _matchesFileSignature(ByteData bytes, String extension) {
    final data = bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    if (extension == 'pdf') {
      return data.length >= 5 && String.fromCharCodes(data.take(5)) == '%PDF-';
    }
    if (extension == 'png') {
      const signature = [137, 80, 78, 71, 13, 10, 26, 10];
      if (data.length < signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (data[i] != signature[i]) return false;
      }
      return true;
    }
    return (extension == 'jpg' || extension == 'jpeg') &&
        data.length >= 3 &&
        data[0] == 0xff &&
        data[1] == 0xd8 &&
        data[2] == 0xff;
  }

  Future<void> _authorizeOperationalWrite(
    Session session,
    String hospitalKey,
    String role,
    String collection,
  ) async {
    const administrators = {
      'hospitalOwner',
      'hospitalAdmin',
      'hospitalManager',
    };

    // ── Dynamic Configurable Permission Check (P1-8) ────────────────────────
    // If hospital administrators have saved custom permission overrides in
    // securityRolePermissions, enforce those as the primary source of truth.
    final customRule = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('securityRolePermissions') &
          row.recordKey.equals('$role:$collection'),
    );
    if (customRule != null) {
      final decoded = jsonDecode(customRule.payload);
      if (decoded is Map<String, dynamic> && decoded['allowed'] is bool) {
        if (decoded['allowed'] == false) {
          throw Exception(
            'Action prohibited by configured hospital security policy for role "$role".',
          );
        }
        if (decoded['allowed'] == true) {
          return; // Granted by tenant administrator override
        }
      }
    }

    final allowed = switch (collection) {
      'settings' ||
      'securityEvents' ||
      'userSessions' ||
      'securityRolePermissions' => {'hospitalOwner', 'hospitalAdmin'},
      'breakGlassRequests' => {
        ...administrators,
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
      },
      'staff' ||
      'shifts' ||
      'departments' ||
      'resources' ||
      'equipment' ||
      'facilities' ||
      'insights' ||
      'notifications' ||
      'operationalAlerts' ||
      'notificationDispatches' ||
      'notificationPreferences' ||
      'notificationRoutingRules' ||
      'resourceRequests' ||
      'resourceRecommendations' ||
      'documentActivities' ||
      'doctorAffiliations' ||
      'doctorLeaves' => administrators,
      'clinicalNotes' => {...administrators, 'doctor'},
      'doctorFollowUps' => {...administrators, 'doctor'},
      'doctors' => administrators,
      'doctorSchedules' => {
        'hospitalOwner',
        'hospitalAdmin',
        'hospitalManager',
        'doctor',
      },
      'patientLinks' => {
        'hospitalOwner',
        'hospitalAdmin',
        'hospitalManager',
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
      },
      'appointments' => {
        ...administrators,
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
      },
      'patients' || 'admissions' || 'beds' || 'icu' => {
        ...administrators,
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
      },
      'diagnosticReports' => {
        ...administrators,
        'doctor',
        'nurse',
        'labTechnician',
      },
      'prescriptions' => {...administrators, 'doctor', 'pharmacist'},
      'bloodInventory' || 'bloodRequests' || 'donations' => {
        ...administrators,
        'bloodBankStaff',
      },
      'emergencies' => {
        ...administrators,
        'doctor',
        'nurse',
        'triageNurse',
        'erCoordinator',
      },
      'auditEvents' => <String>{},
      _ => <String>{},
    };
    if (!allowed.contains(role)) {
      throw Exception('This hospital role cannot modify $collection records.');
    }
  }

  void _authorizeOperationalRead(String role, String collection) {
    if ({'hospitalOwner', 'hospitalAdmin', 'hospitalManager'}.contains(role)) {
      return;
    }
    final allowed = switch (collection) {
      'appointments' => {
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
      },
      'patients' || 'admissions' || 'beds' || 'icu' => {
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'erCoordinator',
      },
      'doctors' => {
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
        'erCoordinator',
      },
      'diagnosticReports' => {'doctor', 'nurse', 'labTechnician'},
      'clinicalNotes' => {'doctor'},
      'doctorFollowUps' => {'doctor'},
      'prescriptions' => {'doctor', 'pharmacist'},
      'bloodInventory' || 'bloodRequests' || 'donations' => {'bloodBankStaff'},
      'emergencies' => {
        'doctor',
        'nurse',
        'triageNurse',
        'erCoordinator',
      },
      'departments' ||
      'facilities' ||
      'resources' ||
      'equipment' ||
      'notifications' => {
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
        'billingStaff',
        'bloodBankStaff',
        'labTechnician',
        'pharmacist',
        'erCoordinator',
      },
      'staff' ||
      'shifts' ||
      'doctorAffiliations' ||
      'doctorLeaves' => {'hospitalOwner', 'hospitalAdmin', 'hospitalManager'},
      'doctorSchedules' => {
        'hospitalOwner',
        'hospitalAdmin',
        'hospitalManager',
        'doctor',
      },
      'patientLinks' => {
        'hospitalOwner',
        'hospitalAdmin',
        'hospitalManager',
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
      },
      'securityEvents' ||
      'breakGlassRequests' ||
      'securityRolePermissions' => {'hospitalOwner', 'hospitalAdmin'},
      'operationalAlerts' ||
      'notificationDispatches' ||
      'notificationPreferences' ||
      'notificationRoutingRules' => {
        'doctor',
        'nurse',
        'inpatientNurse',
        'triageNurse',
        'receptionist',
        'receptionStaff',
        'billingStaff',
        'bloodBankStaff',
        'labTechnician',
        'pharmacist',
        'erCoordinator',
      },
      'resourceRequests' || 'resourceRecommendations' => {
        'hospitalOwner',
        'hospitalAdmin',
        'hospitalManager',
      },
      'documentActivities' => {'doctor', 'nurse', 'labTechnician'},
      _ => <String>{},
    };
    if (!allowed.contains(role)) {
      throw Exception('This hospital role cannot read $collection records.');
    }
  }

  Future<HospitalMembershipRecord?> getMyHospital(Session session) async {
    final userIdentifier = _userIdentifier(session);
    return HospitalMembershipRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.userIdentifier.equals(userIdentifier) & row.isActive.equals(true),
    );
  }

  /// Resolves the signed-in doctor to the doctor profile assigned by their
  /// hospital. A doctor cannot choose another profile by sending an ID.
  Future<String> getMyDoctorProfile(
    Session session,
    String hospitalKey,
  ) async {
    final profile = await _myDoctorRecord(session, hospitalKey);
    final doctor = jsonDecode(profile.payload) as Map<String, dynamic>;
    return jsonEncode({...doctor, 'id': profile.recordKey});
  }

  Future<HospitalOperationalRecord> _myDoctorRecord(
    Session session,
    String hospitalKey,
  ) async {
    final identifier = _userIdentifier(session);
    final membership = await _requireMembership(session, hospitalKey);
    if (membership.role != 'doctor') {
      throw Exception('An active doctor account is required.');
    }
    final access = await HospitalUserAccessRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.userKey.equals(identifier) &
          row.isActive.equals(true),
    );
    final email = access?.email.trim().toLowerCase() ?? '';
    if (email.isEmpty)
      throw Exception('Your hospital user record needs a doctor email.');
    final doctors = await HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('doctors'),
      limit: 2000,
    );
    for (final row in doctors) {
      final doctor = jsonDecode(row.payload);
      if (doctor is Map<String, dynamic> &&
          '${doctor['email'] ?? ''}'.trim().toLowerCase() == email) {
        return row;
      }
    }
    throw Exception('No doctor profile is linked to your hospital account.');
  }

  bool _doctorOwnsRecord(
    HospitalOperationalRecord row,
    String doctorId,
    String doctorName,
  ) => _doctorOwnsPayload(
    row.collection,
    row.recordKey,
    row.payload,
    doctorId,
    doctorName,
  );

  bool _doctorOwnsPayload(
    String collection,
    String recordKey,
    String payload,
    String doctorId,
    String doctorName,
  ) {
    final value = jsonDecode(payload);
    if (value is! Map<String, dynamic>) return false;
    final ownerFields = switch (collection) {
      'appointments' => ['doctorId', 'assignedDoctorId'],
      'admissions' || 'patients' => [
        'attendingDoctorId',
        'primaryDoctorId',
        'assignedDoctorId',
        'doctorId',
      ],
      'diagnosticReports' ||
      'prescriptions' => ['doctorId', 'orderingDoctorId', 'prescribedById'],
      'clinicalNotes' => ['doctorId', 'authorDoctorId'],
      'doctorFollowUps' => ['doctorId', 'assignedDoctorId'],
      'emergencies' => ['assignedDoctorId', 'doctorId'],
      'doctorSchedules' => ['doctorId'],
      _ => const <String>[],
    };
    if (collection == 'doctors') return recordKey == doctorId;
    if (ownerFields.any((key) => '${value[key] ?? ''}' == doctorId))
      return true;
    if (collection == 'appointments' || collection == 'emergencies') {
      return ['doctorName', 'assignedDoctor'].any(
        (key) =>
            '${value[key] ?? ''}'.trim().toLowerCase() ==
            doctorName.trim().toLowerCase(),
      );
    }
    return false;
  }

  /// Creates the first hospital profile for the signed-in account and makes
  /// the account its initial owner. The operation is atomic.
  Future<HospitalMembershipRecord> registerHospital(
    Session session,
    HospitalInfoRecord info,
    HospitalProfileRecord profile,
  ) async {
    final userIdentifier = _userIdentifier(session);
    _validateHospitalInfo(info);
    _validateHospitalProfile(profile);
    final existingMembership = await HospitalMembershipRecord.db.findFirstRow(
      session,
      where: (row) => row.userIdentifier.equals(userIdentifier),
    );
    if (existingMembership != null) {
      throw Exception('This account is already linked to a hospital.');
    }

    final now = DateTime.now().toUtc();
    final hospitalKey = 'HOSP-${now.microsecondsSinceEpoch}';
    late HospitalMembershipRecord membership;
    await session.db.transaction((transaction) async {
      await HospitalInfoRecord.db.insertRow(
        session,
        info.copyWith(hospitalKey: hospitalKey),
        transaction: transaction,
      );
      await HospitalProfileRecord.db.insertRow(
        session,
        profile.copyWith(
          hospitalKey: hospitalKey,
          verificationStatus: 'unverified',
          submittedDate: null,
          verificationNotes:
              'Upload supporting documents and submit for verification.',
        ),
        transaction: transaction,
      );
      final settings = HospitalSettingsRecord(
        hospitalKey: hospitalKey,
        timezone: 'UTC',
        defaultCurrency: 'INR (₹)',
        opdOpeningTime: '08:00 AM',
        opdClosingTime: '08:00 PM',
        appointmentSlotDurationMinutes: 30,
        autoReleaseExpiredBeds: true,
        isEmergencyActive: true,
        emergencyHotline: info.emergencyHotline,
        traumaLevel: profile.traumaLevel,
        ambulanceCount: 0,
        isHospitalDiscoverable: true,
        showFacilitiesToPatients: true,
        showDoctorSchedulesToPatients: true,
        showBedAvailabilityToPatients: true,
        showRatingsAndReviews: true,
        sessionTimeoutMinutes: 30,
        enforceMfaForAdmin: true,
        enableAuditLogging: true,
      );
      await HospitalSettingsRecord.db.insertRow(
        session,
        settings,
        transaction: transaction,
      );
      membership = await HospitalMembershipRecord.db.insertRow(
        session,
        HospitalMembershipRecord(
          hospitalKey: hospitalKey,
          userIdentifier: userIdentifier,
          role: 'hospitalOwner',
          isActive: true,
        ),
        transaction: transaction,
      );
      await HospitalUserAccessRecord.db.insertRow(
        session,
        HospitalUserAccessRecord(
          hospitalKey: hospitalKey,
          userKey: userIdentifier,
          userName: info.name,
          email: profile.email,
          role: 'hospitalOwner',
          department: 'Administration',
          isActive: true,
          lastActive: now,
        ),
        transaction: transaction,
      );
    });
    return membership;
  }

  Future<HospitalInfoRecord?> getInfo(
    Session session,
    String hospitalKey,
  ) async {
    await _requireMembership(session, hospitalKey);
    return HospitalInfoRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
  }

  Future<HospitalInfoRecord> saveInfo(
    Session session,
    HospitalInfoRecord info,
  ) async {
    await _requireAdministrator(session, info.hospitalKey);
    _validateHospitalInfo(info);
    final existing = await HospitalInfoRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(info.hospitalKey),
    );
    return existing == null
        ? HospitalInfoRecord.db.insertRow(session, info)
        : HospitalInfoRecord.db.updateRow(
            session,
            info.copyWith(id: existing.id),
          );
  }

  Future<HospitalProfileRecord?> getProfile(
    Session session,
    String hospitalKey,
  ) async {
    await _requireMembership(session, hospitalKey);
    return HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
  }

  Future<HospitalProfileRecord> saveProfile(
    Session session,
    HospitalProfileRecord profile,
  ) async {
    await _requireAdministrator(session, profile.hospitalKey);
    _validateHospitalProfile(profile);
    final existing = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(profile.hospitalKey),
    );
    if (existing == null)
      return HospitalProfileRecord.db.insertRow(session, profile);
    return HospitalProfileRecord.db.updateRow(
      session,
      profile.copyWith(
        id: existing.id,
        verificationStatus: existing.verificationStatus,
        submittedDate: existing.submittedDate,
        verifiedDate: existing.verifiedDate,
        verificationNotes: existing.verificationNotes,
      ),
    );
  }

  Future<String> getVerificationStatus(
    Session session,
    String hospitalKey,
  ) async {
    await _requireMembership(session, hospitalKey);
    final profile = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
    return profile?.verificationStatus ?? 'unverified';
  }

  Future<VerificationDocumentRecord> uploadVerificationDocument(
    Session session,
    String hospitalKey,
    String title,
    String documentType,
    String fileName,
    String mimeType,
    ByteData fileBytes,
  ) async {
    await _requireAdministrator(session, hospitalKey);
    const maxBytes = 10 * 1024 * 1024;
    if (fileBytes.lengthInBytes == 0 || fileBytes.lengthInBytes > maxBytes) {
      throw Exception('Document must be between 1 byte and 10 MB.');
    }
    final extension = fileName.split('.').last.toLowerCase();
    const allowedTypes = {
      'pdf': 'application/pdf',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
    };
    if (!allowedTypes.containsKey(extension) ||
        allowedTypes[extension] != mimeType.toLowerCase()) {
      throw Exception('Only PDF, PNG, and JPEG documents are accepted.');
    }
    if (!_matchesFileSignature(fileBytes, extension)) {
      throw Exception('The selected file contents do not match its file type.');
    }
    final path =
        'hospital-verification/$hospitalKey/'
        '${DateTime.now().microsecondsSinceEpoch}.$extension';
    await session.storage.storeFile(
      storageId: 'private',
      path: path,
      byteData: fileBytes,
      preventOverwrite: true,
    );
    try {
      return await VerificationDocumentRecord.db.insertRow(
        session,
        VerificationDocumentRecord(
          hospitalKey: hospitalKey,
          title: title.trim().isEmpty ? fileName : title.trim(),
          documentType: documentType,
          // Kept in the legacy field name for protocol compatibility. This is
          // a private storage path, never a URL.
          fileUrl: path,
          uploadDate: DateTime.now().toUtc(),
          status: 'Uploaded',
        ),
      );
    } catch (_) {
      await session.storage.deleteFile(storageId: 'private', path: path);
      rethrow;
    }
  }

  Future<ByteData> getVerificationDocumentBytes(
    Session session,
    String hospitalKey,
    int documentId,
  ) async {
    await _requireMembership(session, hospitalKey);
    final document = await VerificationDocumentRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.id.equals(documentId) & row.hospitalKey.equals(hospitalKey),
    );
    if (document == null) throw Exception('Verification document not found.');
    final bytes = await session.storage.retrieveFile(
      storageId: 'private',
      path: document.fileUrl,
    );
    if (bytes == null)
      throw Exception('Verification document file is missing.');
    return bytes;
  }

  Future<String> uploadDoctorReportFile(
    Session session,
    String hospitalKey,
    String reportId,
    String fileName,
    String mimeType,
    ByteData fileBytes,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    if (membership.role != 'doctor') {
      throw Exception('Only the assigned doctor can attach a report file.');
    }
    _validateRecordKey(reportId);
    final report = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('diagnosticReports') &
          row.recordKey.equals(reportId),
    );
    if (report == null) throw Exception('Report not found.');
    final profile = await _myDoctorRecord(session, hospitalKey);
    final doctor = jsonDecode(profile.payload) as Map<String, dynamic>;
    if (!_doctorOwnsRecord(
      report,
      profile.recordKey,
      '${doctor['name'] ?? ''}',
    )) {
      throw Exception('This report is outside your assigned patient care.');
    }
    final reportPayload = jsonDecode(report.payload) as Map<String, dynamic>;
    final patientId = '${reportPayload['patientId'] ?? ''}'.trim();
    if (patientId.isEmpty ||
        !await _doctorHasAssignedPatient(
          session,
          hospitalKey,
          patientId,
          profile.recordKey,
          '${doctor['name'] ?? ''}',
        )) {
      throw Exception(
        'The report patient is not assigned to your doctor profile.',
      );
    }
    const maxBytes = 10 * 1024 * 1024;
    if (fileBytes.lengthInBytes == 0 || fileBytes.lengthInBytes > maxBytes) {
      throw Exception('Report files must be between 1 byte and 10 MB.');
    }
    final extension = fileName.split('.').last.toLowerCase();
    const allowedTypes = {
      'pdf': 'application/pdf',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'dcm': 'application/dicom',
    };
    if (allowedTypes[extension] != mimeType.toLowerCase() ||
        !_matchesReportFileSignature(fileBytes, extension)) {
      throw Exception(
        'Unsupported report file or file contents do not match its type.',
      );
    }
    final path =
        'doctor-reports/$hospitalKey/${report.recordKey}/'
        '${DateTime.now().microsecondsSinceEpoch}.$extension';
    await session.storage.storeFile(
      storageId: 'private',
      path: path,
      byteData: fileBytes,
      preventOverwrite: true,
    );
    try {
      final data = jsonDecode(report.payload) as Map<String, dynamic>;
      final now = DateTime.now().toUtc();
      data['fileReference'] = {
        'storagePath': path,
        'fileName': fileName.split(RegExp(r'[/\\]')).last,
        'mimeType': mimeType.toLowerCase(),
        'sizeBytes': fileBytes.lengthInBytes,
        'uploadedAt': now.toIso8601String(),
      };
      await session.db.transaction((transaction) async {
        await _upsertOperationalRecord(
          session,
          HospitalOperationalRecord(
            hospitalKey: hospitalKey,
            collection: 'diagnosticReports',
            recordKey: report.recordKey,
            payload: jsonEncode(data),
            createdAt: report.createdAt,
            updatedAt: now,
          ),
          transaction: transaction,
        );
        await _appendOperationalAudit(
          session,
          transaction,
          hospitalKey,
          'diagnosticReports',
          report.recordKey,
          'report_file_uploaded',
        );
      });
      return jsonEncode(data['fileReference']);
    } catch (_) {
      await session.storage.deleteFile(storageId: 'private', path: path);
      rethrow;
    }
  }

  Future<ByteData> getDoctorReportFileBytes(
    Session session,
    String hospitalKey,
    String reportId,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    if (membership.role != 'doctor') {
      throw Exception('Only the assigned doctor can access this report file.');
    }
    final report = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('diagnosticReports') &
          row.recordKey.equals(reportId),
    );
    if (report == null) throw Exception('Report not found.');
    final profile = await _myDoctorRecord(session, hospitalKey);
    final doctor = jsonDecode(profile.payload) as Map<String, dynamic>;
    if (!_doctorOwnsRecord(
      report,
      profile.recordKey,
      '${doctor['name'] ?? ''}',
    )) {
      throw Exception('This report is outside your assigned patient care.');
    }
    final payload = jsonDecode(report.payload) as Map<String, dynamic>;
    final reference = payload['fileReference'];
    if (reference is! Map || reference['storagePath'] is! String) {
      throw Exception('This report does not have an attached file.');
    }
    final bytes = await session.storage.retrieveFile(
      storageId: 'private',
      path: reference['storagePath'] as String,
    );
    if (bytes == null)
      throw Exception('Report file is missing from private storage.');
    await session.db.transaction((transaction) async {
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        'diagnosticReports',
        report.recordKey,
        'report_file_downloaded',
      );
    });
    return bytes;
  }

  bool _matchesReportFileSignature(ByteData bytes, String extension) {
    if (extension != 'dcm') return _matchesFileSignature(bytes, extension);
    final data = bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    return data.length >= 132 &&
        String.fromCharCodes(data.sublist(128, 132)) == 'DICM';
  }

  /// Releases a reviewed report into an explicitly linked patient account.
  /// The account owner comes from the hospital-approved link, never from the
  /// doctor request, and both portal/source rows change atomically.
  Future<String> setDoctorReportPatientSharing(
    Session session,
    String hospitalKey,
    String reportId,
    bool isShared,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    if (membership.role != 'doctor') {
      throw Exception('Only the treating doctor can share this report.');
    }
    final report = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('diagnosticReports') &
          row.recordKey.equals(reportId),
    );
    if (report == null) throw Exception('Report not found.');
    final doctorProfile = await _myDoctorRecord(session, hospitalKey);
    final doctor = jsonDecode(doctorProfile.payload) as Map<String, dynamic>;
    if (!_doctorOwnsRecord(
      report,
      doctorProfile.recordKey,
      '${doctor['name'] ?? ''}',
    )) {
      throw Exception('This report is outside your assigned patient care.');
    }
    final data = jsonDecode(report.payload) as Map<String, dynamic>;
    final patientId = '${data['patientId'] ?? ''}'.trim();
    if (isShared &&
        '${data['verificationStatus'] ?? data['status'] ?? ''}'.toLowerCase() !=
            'verified') {
      throw Exception(
        'Review and sign off the report before sharing it with the patient.',
      );
    }
    final fileReference = data['fileReference'];
    if (isShared &&
        (fileReference is! Map || fileReference['storagePath'] is! String)) {
      throw Exception(
        'Upload a report file before sharing it with the patient.',
      );
    }

    if (!isShared) {
      final priorShares = await HospitalOperationalRecord.db.find(
        session,
        where: (row) =>
            row.collection.equals('patientReports') &
            row.recordKey.equals(reportId),
        limit: 5000,
      );
      final now = DateTime.now().toUtc();
      await session.db.transaction((transaction) async {
        data['releasedToPatient'] = false;
        data['sharedWithPatientAt'] = null;
        await _upsertOperationalRecord(
          session,
          report.copyWith(payload: jsonEncode(data), updatedAt: now),
          transaction: transaction,
        );
        for (final prior in priorShares) {
          final value = jsonDecode(prior.payload);
          if (value is Map<String, dynamic> &&
              value['sourceHospitalKey'] == hospitalKey &&
              value['sourceDoctorReportId'] == reportId) {
            await HospitalOperationalRecord.db.deleteRow(
              session,
              prior,
              transaction: transaction,
            );
          }
        }
        await _appendOperationalAudit(
          session,
          transaction,
          hospitalKey,
          'diagnosticReports',
          reportId,
          'report_patient_access_revoked',
        );
      });
      return 'revoked';
    }

    final accountLink = patientId.isEmpty
        ? null
        : await HospitalOperationalRecord.db.findFirstRow(
            session,
            where: (row) =>
                row.hospitalKey.equals(hospitalKey) &
                row.collection.equals('patientAccountLinks') &
                row.recordKey.equals(patientId),
          );
    final linkData = accountLink == null
        ? null
        : jsonDecode(accountLink.payload);
    final patientOwner =
        linkData is Map<String, dynamic> && linkData['status'] == 'active'
        ? '${linkData['patientOwner'] ?? ''}'
        : '';
    if (patientOwner.isEmpty) {
      throw Exception(
        'This patient does not have a verified Healthify account link at this hospital.',
      );
    }

    final partition = 'PATIENT:$patientOwner';
    final now = DateTime.now().toUtc();
    final oldPortalReport = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(partition) &
          row.collection.equals('patientReports') &
          row.recordKey.equals(reportId),
    );
    final sharePayload = <String, dynamic>{
      'id': reportId,
      'patientId': patientOwner,
      'title': data['title'] ?? 'Medical report',
      'category': switch ('${data['reportType'] ?? ''}'.toLowerCase()) {
        'radiology' || 'imaging' => 'Imaging',
        'laboratory' || 'pathology' => 'Lab Reports',
        'prescription' => 'Prescriptions',
        _ => 'Lab Reports',
      },
      'doctorName':
          data['reviewDoctorName'] ?? doctor['name'] ?? 'Treating doctor',
      'hospitalName': data['facility'] ?? data['hospitalName'] ?? 'Hospital',
      'date': data['uploadedAt'] ?? now.toIso8601String(),
      'summary': '${data['doctorNotesPatientVisible'] ?? ''}'.trim().isNotEmpty
          ? data['doctorNotesPatientVisible']
          : '${data['impressionText'] ?? data['summary'] ?? data['findingsText'] ?? ''}',
      'fileFormat':
          '${fileReference is Map ? fileReference['fileName'] ?? '' : ''}'
              .split('.')
              .last
              .toUpperCase(),
      'fileSize':
          '${fileReference is Map ? fileReference['sizeBytes'] ?? '' : ''} bytes',
      'isExternalUploaded': false,
      'hasAttachedFile':
          fileReference is Map && fileReference['storagePath'] is String,
      'sourceHospitalKey': hospitalKey,
      'sourcePatientId': patientId,
      'sourceDoctorReportId': reportId,
      '_owner': patientOwner,
      'sharedAt': now.toIso8601String(),
      'accessLogs': const [],
      'parameters': const [],
      'sharedLinks': const [],
    };

    await session.db.transaction((transaction) async {
      data['releasedToPatient'] = isShared;
      data['sharedWithPatientAt'] = isShared ? now.toIso8601String() : null;
      await _upsertOperationalRecord(
        session,
        report.copyWith(payload: jsonEncode(data), updatedAt: now),
        transaction: transaction,
      );
      if (isShared) {
        await _upsertOperationalRecord(
          session,
          HospitalOperationalRecord(
            hospitalKey: partition,
            collection: 'patientReports',
            recordKey: reportId,
            payload: jsonEncode(sharePayload),
            createdAt: oldPortalReport?.createdAt ?? now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      } else if (oldPortalReport != null) {
        await HospitalOperationalRecord.db.deleteRow(
          session,
          oldPortalReport,
          transaction: transaction,
        );
      }
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        'diagnosticReports',
        reportId,
        isShared ? 'report_released_to_patient' : 'report_access_revoked',
      );
    });
    return jsonEncode({'releasedToPatient': isShared});
  }

  /// Returns a shared report file only while its owner-scoped portal record
  /// and the source doctor's release flag both remain active.
  Future<ByteData> getMySharedReportFileBytes(
    Session session,
    String reportId,
  ) async {
    final patientOwner = _userIdentifier(session);
    final partition = 'PATIENT:$patientOwner';
    final shared = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(partition) &
          row.collection.equals('patientReports') &
          row.recordKey.equals(reportId),
    );
    if (shared == null)
      throw Exception('This report is not available in your account.');
    final sharedData = jsonDecode(shared.payload);
    if (sharedData is! Map<String, dynamic> ||
        sharedData['_owner'] != patientOwner ||
        sharedData['sourceHospitalKey'] is! String ||
        sharedData['sourceDoctorReportId'] != reportId) {
      throw Exception('Patient report ownership could not be verified.');
    }
    final hospitalKey = sharedData['sourceHospitalKey'] as String;
    final source = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('diagnosticReports') &
          row.recordKey.equals(reportId),
    );
    if (source == null)
      throw Exception('The source report is no longer available.');
    final sourceData = jsonDecode(source.payload);
    if (sourceData is! Map<String, dynamic> ||
        sourceData['releasedToPatient'] != true ||
        '${sourceData['patientId'] ?? ''}' !=
            '${sharedData['sourcePatientId'] ?? ''}') {
      throw Exception('The doctor has revoked access to this report.');
    }
    final link = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('patientAccountLinks') &
          row.recordKey.equals('${sourceData['patientId'] ?? ''}'),
    );
    final linkData = link == null ? null : jsonDecode(link.payload);
    if (linkData is! Map<String, dynamic> ||
        linkData['status'] != 'active' ||
        linkData['patientOwner'] != patientOwner) {
      throw Exception('This hospital account link has been revoked.');
    }
    final reference = sourceData['fileReference'];
    if (reference is! Map || reference['storagePath'] is! String) {
      throw Exception('No file is attached to this shared report.');
    }
    final bytes = await session.storage.retrieveFile(
      storageId: 'private',
      path: reference['storagePath'] as String,
    );
    if (bytes == null)
      throw Exception('The report file is missing from private storage.');
    await session.db.transaction((transaction) async {
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        'diagnosticReports',
        reportId,
        'patient_downloaded_shared_report',
      );
    });
    return bytes;
  }

  Future<bool> _doctorHasAssignedPatient(
    Session session,
    String hospitalKey,
    String patientId,
    String doctorId,
    String doctorName,
  ) async {
    for (final collection in ['appointments', 'patients', 'admissions']) {
      final rows = await HospitalOperationalRecord.db.find(
        session,
        where: (row) =>
            row.hospitalKey.equals(hospitalKey) &
            row.collection.equals(collection),
        limit: 2000,
      );
      for (final row in rows) {
        if (!_doctorOwnsRecord(row, doctorId, doctorName)) continue;
        final value = jsonDecode(row.payload);
        if (value is! Map<String, dynamic>) continue;
        final assignedPatientId = collection == 'patients'
            ? '${value['id'] ?? row.recordKey}'
            : '${value['patientId'] ?? ''}';
        if (assignedPatientId == patientId) return true;
      }
    }
    // Check for an active, approved, unexpired break-glass emergency override (P1-9)
    final breakGlassRows = await HospitalOperationalRecord.db.find(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.collection.equals('breakGlassRequests'),
      limit: 100,
    );
    final now = DateTime.now().toUtc();
    for (final row in breakGlassRows) {
      final data = jsonDecode(row.payload);
      if (data is! Map<String, dynamic>) continue;
      final requestedPatientId = '${data['patientId'] ?? ''}'.trim();
      final requestedUserId = '${data['userId'] ?? ''}'.trim();
      final status = '${data['status'] ?? ''}'.toLowerCase();
      if (requestedPatientId == patientId &&
          (requestedUserId == doctorId || requestedUserId == doctorName) &&
          status == 'approved' &&
          data['expiresAt'] != null) {
        final expires = DateTime.tryParse('${data['expiresAt']}');
        if (expires != null && now.isBefore(expires)) {
          return true; // Valid active emergency break-glass grant
        }
      }
    }

    return false;
  }

  /// Approves or rejects an emergency clinical break-glass request.
  /// Approval grants a temporary time-bounded access window (60 minutes).
  Future<bool> reviewBreakGlassRequest(
    Session session,
    String hospitalKey,
    String requestId,
    bool approve,
  ) async {
    final actor = await _requireAdministrator(session, hospitalKey);
    final row = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (item) =>
          item.hospitalKey.equals(hospitalKey) &
          item.collection.equals('breakGlassRequests') &
          item.recordKey.equals(requestId),
    );
    if (row == null) throw Exception('Break-glass request not found.');
    final data = jsonDecode(row.payload) as Map<String, dynamic>;
    final now = DateTime.now().toUtc();
    final updated = {
      ...data,
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': actor.userIdentifier,
      'reviewedAt': now.toIso8601String(),
      if (approve) 'expiresAt': now.add(const Duration(minutes: 60)).toIso8601String(),
    };
    await session.db.transaction((transaction) async {
      await _upsertOperationalRecord(
        session,
        row.copyWith(payload: jsonEncode(updated), updatedAt: now),
        transaction: transaction,
      );
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        'breakGlassRequests',
        requestId,
        approve ? 'break_glass_approved' : 'break_glass_rejected',
      );
    });
    return true;
  }

  Future<HospitalProfileRecord> submitVerification(
    Session session,
    String hospitalKey,
  ) async {
    await _requireAdministrator(session, hospitalKey);
    final profile = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
    if (profile == null) throw Exception('Hospital profile not found.');
    final documents = await VerificationDocumentRecord.db.find(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
    if (documents.isEmpty) {
      throw Exception('Upload at least one verification document first.');
    }
    final now = DateTime.now().toUtc();
    await session.db.transaction((transaction) async {
      for (final document in documents) {
        await VerificationDocumentRecord.db.updateRow(
          session,
          document.copyWith(status: 'Pending review'),
          transaction: transaction,
        );
      }
      await HospitalProfileRecord.db.updateRow(
        session,
        profile.copyWith(
          verificationStatus: 'pending',
          submittedDate: now,
          verificationNotes:
              'Verification submission received and is under review.',
        ),
        transaction: transaction,
      );
    });
    return (await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    ))!;
  }

  Future<List<VerificationDocumentRecord>> getVerificationDocuments(
    Session session,
    String hospitalKey,
  ) async {
    await _requireMembership(session, hospitalKey);
    return VerificationDocumentRecord.db.find(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
      orderBy: (row) => row.uploadDate,
      orderDescending: true,
    );
  }

  Future<HospitalSettingsRecord?> getSettings(
    Session session,
    String hospitalKey,
  ) async {
    await _requireMembership(session, hospitalKey);
    return HospitalSettingsRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
  }

  /// Lists all hospitals pending platform verification review (P1-11).
  Future<List<HospitalProfileRecord>> listPendingHospitalVerifications(
    Session session,
  ) async {
    _userIdentifier(session);
    return HospitalProfileRecord.db.find(
      session,
      where: (row) => row.verificationStatus.equals('pending'),
      orderBy: (row) => row.submittedDate,
      orderDescending: true,
      limit: 100,
    );
  }

  /// Platform reviewer decision: approves or rejects hospital platform credentials (P1-11).
  Future<bool> reviewHospitalVerification(
    Session session,
    String hospitalKey,
    bool approve,
    String reviewerNotes,
  ) async {
    _userIdentifier(session);
    final profile = await HospitalProfileRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
    if (profile == null) throw Exception('Hospital profile not found.');
    final now = DateTime.now().toUtc();
    final docs = await VerificationDocumentRecord.db.find(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
    );
    await session.db.transaction((transaction) async {
      await HospitalProfileRecord.db.updateRow(
        session,
        profile.copyWith(
          verificationStatus: approve ? 'verified' : 'rejected',
          verifiedDate: approve ? now : null,
          verificationNotes: reviewerNotes.isNotEmpty
              ? reviewerNotes
              : (approve
                  ? 'Approved by platform compliance team.'
                  : 'Rejected by platform compliance team.'),
        ),
        transaction: transaction,
      );
      for (final doc in docs) {
        await VerificationDocumentRecord.db.updateRow(
          session,
          doc.copyWith(status: approve ? 'Approved' : 'Rejected'),
          transaction: transaction,
        );
      }
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        'verification',
        hospitalKey,
        approve ? 'hospital_platform_verified' : 'hospital_platform_rejected',
      );
    });
    return true;
  }

  /// Dispatches an onboarding invitation to a new doctor or hospital staff member (P1-10).
  /// Creates a provisional access record and dispatches an activation token via email.
  Future<String> inviteHospitalStaff(
    Session session,
    String hospitalKey,
    String email,
    String fullName,
    String role,
    String department,
  ) async {
    await _requireAdministrator(session, hospitalKey);
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('A valid staff email address is required.');
    }
    final inviteCode = 'INV-${DateTime.now().microsecondsSinceEpoch.toString().substring(8)}';
    final userKey = 'USR-${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

    final accessRecord = HospitalUserAccessRecord(
      hospitalKey: hospitalKey,
      userKey: userKey,
      userName: fullName.trim().isEmpty ? 'Invited Staff' : fullName.trim(),
      email: cleanEmail,
      role: role,
      department: department.trim().isEmpty ? 'General' : department.trim(),
      isActive: false, // Inactive until claim
      lastActive: DateTime.now().toUtc(),
    );

    await session.db.transaction((transaction) async {
      await HospitalUserAccessRecord.db.insertRow(
        session,
        accessRecord,
        transaction: transaction,
      );
      await _appendOperationalAudit(
        session,
        transaction,
        hospitalKey,
        'staff',
        userKey,
        'staff_invitation_issued',
      );
    });

    // Dispatch activation email via DeliveryManager
    await DeliveryManager.instance.sendRegistrationCode(
      session,
      email: cleanEmail,
      code: inviteCode,
    );

    return inviteCode;
  }

  Future<HospitalSettingsRecord> saveSettings(
    Session session,
    HospitalSettingsRecord settings,
  ) async {
    await _requireAdministrator(session, settings.hospitalKey);
    if (settings.appointmentSlotDurationMinutes < 5 ||
        settings.appointmentSlotDurationMinutes > 240 ||
        settings.sessionTimeoutMinutes < 5 ||
        settings.sessionTimeoutMinutes > 1440 ||
        settings.ambulanceCount < 0 ||
        settings.timezone.trim().isEmpty ||
        settings.defaultCurrency.trim().isEmpty) {
      throw Exception('Hospital settings contain invalid values.');
    }
    final existing = await HospitalSettingsRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(settings.hospitalKey),
    );
    return existing == null
        ? HospitalSettingsRecord.db.insertRow(session, settings)
        : HospitalSettingsRecord.db.updateRow(
            session,
            settings.copyWith(id: existing.id),
          );
  }

  Future<List<HospitalUserAccessRecord>> getUserAccessList(
    Session session,
    String hospitalKey,
  ) async {
    await _requireAdministrator(session, hospitalKey);
    return HospitalUserAccessRecord.db.find(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey),
      orderBy: (row) => row.userName,
    );
  }

  Future<HospitalUserAccessRecord> saveUserAccess(
    Session session,
    HospitalUserAccessRecord user,
  ) async {
    await _requireAdministrator(session, user.hospitalKey);
    const assignableRoles = {
      'hospitalAdmin',
      'hospitalManager',
      'doctor',
      'nurse',
      'inpatientNurse',
      'triageNurse',
      'receptionist',
      'receptionStaff',
      'billingStaff',
      'bloodBankStaff',
      'labTechnician',
      'pharmacist',
      'erCoordinator',
    };
    if (!assignableRoles.contains(user.role) || user.userKey.trim().isEmpty) {
      throw Exception('Hospital member details or role are invalid.');
    }
    final existing = await HospitalUserAccessRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(user.hospitalKey) &
          row.userKey.equals(user.userKey),
    );
    if (existing?.role == 'hospitalOwner') {
      throw Exception('The hospital owner access cannot be reassigned.');
    }
    final membership = await HospitalMembershipRecord.db.findFirstRow(
      session,
      where: (row) => row.userIdentifier.equals(user.userKey),
    );
    if (membership != null && membership.hospitalKey != user.hospitalKey) {
      throw Exception('This account already belongs to another hospital.');
    }
    return session.db.transaction((transaction) async {
      final savedAccess = existing == null
          ? await HospitalUserAccessRecord.db.insertRow(
              session,
              user,
              transaction: transaction,
            )
          : await HospitalUserAccessRecord.db.updateRow(
              session,
              user.copyWith(id: existing.id),
              transaction: transaction,
            );
      if (membership == null) {
        await HospitalMembershipRecord.db.insertRow(
          session,
          HospitalMembershipRecord(
            hospitalKey: user.hospitalKey,
            userIdentifier: user.userKey,
            role: user.role,
            isActive: user.isActive,
          ),
          transaction: transaction,
        );
      } else {
        await HospitalMembershipRecord.db.updateRow(
          session,
          membership.copyWith(role: user.role, isActive: user.isActive),
          transaction: transaction,
        );
      }
      return savedAccess;
    });
  }

  Future<void> updateUserRole(
    Session session,
    String hospitalKey,
    String userKey,
    String role,
  ) async {
    await _requireAdministrator(session, hospitalKey);
    const allowedRoles = {
      'hospitalAdmin',
      'hospitalManager',
      'doctor',
      'nurse',
      'inpatientNurse',
      'triageNurse',
      'receptionist',
      'receptionStaff',
      'billingStaff',
      'bloodBankStaff',
      'labTechnician',
      'pharmacist',
      'erCoordinator',
    };
    if (!allowedRoles.contains(role))
      throw Exception('Role cannot be assigned.');
    final user = await HospitalUserAccessRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) & row.userKey.equals(userKey),
    );
    if (user == null) throw Exception('Hospital user not found.');
    if (user.role == 'hospitalOwner') {
      throw Exception('The hospital owner role cannot be changed.');
    }
    await session.db.transaction((transaction) async {
      await HospitalUserAccessRecord.db.updateRow(
        session,
        user.copyWith(role: role),
        transaction: transaction,
      );
      final membership = await HospitalMembershipRecord.db.findFirstRow(
        session,
        where: (row) =>
            row.hospitalKey.equals(hospitalKey) &
            row.userIdentifier.equals(userKey),
        transaction: transaction,
      );
      if (membership != null) {
        await HospitalMembershipRecord.db.updateRow(
          session,
          membership.copyWith(role: role),
          transaction: transaction,
        );
      }
    });
  }

  Future<void> setUserAccess(
    Session session,
    String hospitalKey,
    String userKey,
    bool isActive,
  ) async {
    final actor = await _requireAdministrator(session, hospitalKey);
    if (userKey == actor.userIdentifier && !isActive) {
      throw Exception('You cannot deactivate your own account.');
    }
    final user = await HospitalUserAccessRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) & row.userKey.equals(userKey),
    );
    if (user == null) throw Exception('Hospital user not found.');
    if (user.role == 'hospitalOwner' && !isActive) {
      throw Exception('The hospital owner account cannot be deactivated.');
    }
    await session.db.transaction((transaction) async {
      await HospitalUserAccessRecord.db.updateRow(
        session,
        user.copyWith(isActive: isActive),
        transaction: transaction,
      );
      final membership = await HospitalMembershipRecord.db.findFirstRow(
        session,
        where: (row) =>
            row.hospitalKey.equals(hospitalKey) &
            row.userIdentifier.equals(userKey),
        transaction: transaction,
      );
      if (membership != null) {
        await HospitalMembershipRecord.db.updateRow(
          session,
          membership.copyWith(isActive: isActive),
          transaction: transaction,
        );
      }
    });
  }

  String _userIdentifier(Session session) {
    final identifier = session.authenticated?.userIdentifier;
    if (identifier == null || identifier.isEmpty) {
      throw Exception('Sign in is required.');
    }
    return identifier;
  }

  Future<HospitalMembershipRecord> _requireMembership(
    Session session,
    String hospitalKey,
  ) async {
    final identifier = _userIdentifier(session);
    final membership = await HospitalMembershipRecord.db.findFirstRow(
      session,
      where: (row) =>
          row.hospitalKey.equals(hospitalKey) &
          row.userIdentifier.equals(identifier) &
          row.isActive.equals(true),
    );
    if (membership == null)
      throw Exception('No active access to this hospital.');
    return membership;
  }

  Future<HospitalMembershipRecord> _requireAdministrator(
    Session session,
    String hospitalKey,
  ) async {
    final membership = await _requireMembership(session, hospitalKey);
    if (membership.role != 'hospitalOwner' &&
        membership.role != 'hospitalAdmin') {
      throw Exception('Hospital administrator access is required.');
    }
    return membership;
  }
}
