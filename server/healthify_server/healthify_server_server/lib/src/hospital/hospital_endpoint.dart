import 'package:serverpod/serverpod.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../generated/protocol.dart';

/// Hospital APIs are always authenticated and every tenant read/write is
/// checked against the signed-in account's active hospital membership.
class HospitalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _operationalCollections = {
    'appointments', 'beds', 'icu', 'admissions', 'patients', 'doctors',
    'staff', 'shifts', 'bloodInventory', 'bloodRequests', 'donations',
    'facilities', 'equipment', 'emergencies', 'diagnosticReports',
    'prescriptions', 'notifications', 'insights', 'auditEvents',
    'resources', 'departments', 'settings', 'securityEvents', 'operationalAlerts',
    'notificationDispatches', 'notificationPreferences', 'notificationRoutingRules',
    'documentActivities', 'resourceRequests', 'resourceRecommendations',
    'breakGlassRequests', 'securityRolePermissions',
  };

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
    return HospitalOperationalRecord.db.find(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.collection.equals(collection),
      orderBy: (row) => row.updatedAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
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
    return HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.collection.equals(collection) &
          row.recordKey.equals(recordKey),
    );
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
    _authorizeOperationalWrite(membership.role, collection);
    if (utf8.encode(payload).length > 256 * 1024) {
      throw Exception('Record payload exceeds 256 KB.');
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic> && decoded is! List) {
      throw Exception('Operational record payload must be a JSON object or list.');
    }
    _validateOperationalPayload(collection, recordKey, decoded);
    final existing = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.collection.equals(collection) &
          row.recordKey.equals(recordKey),
    );
    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      final saved = await HospitalOperationalRecord.db.upsertRow(
        session,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: collection,
          recordKey: recordKey,
          payload: payload,
          createdAt: now,
          updatedAt: now,
        ),
        conflictColumns: (row) => [row.hospitalKey, row.collection, row.recordKey],
        updateColumns: (row) => [row.payload, row.updatedAt],
        transaction: transaction,
      );
      await _appendOperationalAudit(
        session, transaction, hospitalKey, collection, recordKey,
        existing == null ? 'create' : 'update',
      );
      return saved;
    });
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
    if (recordKeys.isEmpty || recordKeys.length != payloads.length ||
        recordKeys.length != collections.length || recordKeys.length > 100) {
      throw Exception('A batch must contain between 1 and 100 matching collections, keys and payloads.');
    }
    final parsed = <Map<String, dynamic>>[];
    for (var i = 0; i < recordKeys.length; i++) {
      final key = recordKeys[i];
      final collection = collections[i];
      final payload = payloads[i];
      _validateCollection(collection);
      _authorizeOperationalWrite(membership.role, collection);
      _validateRecordKey(key);
      if (utf8.encode(payload).length > 256 * 1024) {
        throw Exception('Record payload exceeds 256 KB.');
      }
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Operational record payload must be a JSON object.');
      }
      _validateOperationalPayload(collection, key, decoded);
      parsed.add(decoded);
    }
    if (List.generate(recordKeys.length, (i) => '${collections[i]}:${recordKeys[i]}').toSet().length != recordKeys.length) {
      throw Exception('A batch cannot contain duplicate records.');
    }
    final existingByKey = <String, HospitalOperationalRecord?>{};
    for (var i = 0; i < recordKeys.length; i++) {
      final key = recordKeys[i];
      final collection = collections[i];
      existingByKey['$collection:$key'] = await HospitalOperationalRecord.db.findFirstRow(
        session,
        where: (row) => row.hospitalKey.equals(hospitalKey) &
            row.collection.equals(collection) & row.recordKey.equals(key),
      );
    }
    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      final saved = <HospitalOperationalRecord>[];
      for (var i = 0; i < recordKeys.length; i++) {
        final key = recordKeys[i];
        final collection = collections[i];
        final existing = existingByKey['$collection:$key'];
        final row = await HospitalOperationalRecord.db.upsertRow(
          session,
          HospitalOperationalRecord(
            hospitalKey: hospitalKey,
            collection: collection,
            recordKey: key,
            payload: jsonEncode(parsed[i]),
            createdAt: now,
            updatedAt: now,
          ),
          conflictColumns: (row) => [row.hospitalKey, row.collection, row.recordKey],
          updateColumns: (row) => [row.payload, row.updatedAt],
          transaction: transaction,
        );
        await _appendOperationalAudit(
          session, transaction, hospitalKey, collection, key,
          existing == null ? 'create' : 'update',
        );
        saved.add(row);
      }
      return saved;
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
    _authorizeOperationalWrite(membership.role, collection);
    final row = await HospitalOperationalRecord.db.findFirstRow(
      session,
      where: (item) => item.hospitalKey.equals(hospitalKey) &
          item.collection.equals(collection) &
          item.recordKey.equals(recordKey),
    );
    if (row == null) return false;
    return session.db.transaction((transaction) async {
      await HospitalOperationalRecord.db.deleteRow(
        session, row, transaction: transaction,
      );
      await _appendOperationalAudit(
        session, transaction, hospitalKey, collection, recordKey, 'delete',
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
    const allowedActions = {'create', 'read', 'update', 'delete', 'login', 'logout', 'permissionDenied'};
    if (!allowedActions.contains(action)) throw Exception('Unsupported audit action.');
    _validateRecordKey(targetEntityType);
    _validateRecordKey(targetEntityId);
    if (utf8.encode(details).length > 16 * 1024) throw Exception('Audit details exceed 16 KB.');
    await HospitalAuditEvent.db.insertRow(session, HospitalAuditEvent(
      hospitalKey: hospitalKey,
      actorUserIdentifier: _userIdentifier(session),
      action: action,
      collection: targetEntityType,
      recordKey: targetEntityId,
      occurredAt: DateTime.now().toUtc(),
      details: details,
    ));
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
          'scheduled', 'checkedIn', 'inConsultation', 'inProgress',
          'completed', 'cancelled', 'noShow', 'missed',
        },
      'beds' || 'icu' => {
          'available', 'occupied', 'maintenance', 'reserved', 'cleaning',
          'sanitizing', 'blocked',
        },
      'bloodInventory' => {
          'available', 'reserved', 'dispatched', 'expired', 'quarantined',
          'quarantine', 'expiringSoon', 'discarded', 'issued',
        },
      'bloodRequests' => {
          'pending', 'approved', 'fulfilled', 'rejected', 'cancelled',
          'partiallyAllocated', 'allocated', 'completed',
        },
      'staff' => {
          'active', 'inShift', 'onLeave', 'suspended', 'terminated', 'offDuty',
        },
      'emergencies' => {
          'arrived', 'triaged', 'waiting', 'assigned', 'inTreatment',
          'stabilizing', 'transferred', 'discharged', 'deceased',
          'triage', 'admitted', 'cancelled',
        },
      _ => null,
    };
    if (status != null && allowedStatuses != null &&
        !allowedStatuses.contains(status)) {
      throw Exception('Unsupported status for hospital $collection record.');
    }
    for (final field in const [
      'quantity', 'quantityUnits', 'units', 'requiredUnits', 'allocatedUnits',
      'count', 'dailyRate', 'totalBedCapacity',
      'icuCapacity', 'activeDoctorCount', 'totalStaffCount',
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
    if (info.name.trim().isEmpty || info.code.trim().isEmpty ||
        info.email.trim().isEmpty || info.address.trim().isEmpty ||
        info.totalBedCapacity < 0 || info.icuCapacity < 0 ||
        info.icuCapacity > info.totalBedCapacity ||
        info.activeDoctorCount < 0 || info.totalStaffCount < 0) {
      throw Exception('Hospital information contains invalid values.');
    }
  }

  void _validateHospitalProfile(HospitalProfileRecord profile) {
    if (profile.name.trim().isEmpty || profile.legalName.trim().isEmpty ||
        profile.email.trim().isEmpty || profile.country.trim().isEmpty ||
        profile.latitude < -90 || profile.latitude > 90 ||
        profile.longitude < -180 || profile.longitude > 180 ||
        profile.totalBeds < 0 || profile.icuBeds < 0 ||
        profile.icuBeds > profile.totalBeds ||
        profile.operatingTheatres < 0 || profile.emergencyCapacity < 0) {
      throw Exception('Hospital profile contains invalid values.');
    }
  }

  bool _matchesFileSignature(ByteData bytes, String extension) {
    final data = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
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
    return (extension == 'jpg' || extension == 'jpeg') && data.length >= 3 &&
        data[0] == 0xff && data[1] == 0xd8 && data[2] == 0xff;
  }

  void _authorizeOperationalWrite(String role, String collection) {
    const administrators = {'hospitalOwner', 'hospitalAdmin', 'hospitalManager'};
    final allowed = switch (collection) {
      'settings' || 'securityEvents' || 'securityRolePermissions' => {'hospitalOwner', 'hospitalAdmin'},
      'breakGlassRequests' => {
          ...administrators, 'doctor', 'nurse', 'inpatientNurse', 'triageNurse',
        },
      'staff' || 'shifts' || 'departments' || 'resources' || 'equipment' ||
      'facilities' || 'insights' || 'notifications' || 'operationalAlerts' ||
      'notificationDispatches' || 'notificationPreferences' || 'notificationRoutingRules' ||
      'resourceRequests' || 'resourceRecommendations' || 'documentActivities' => administrators,
      'appointments' => {
          ...administrators, 'doctor', 'nurse', 'inpatientNurse',
          'triageNurse', 'receptionist', 'receptionStaff',
        },
      'patients' || 'admissions' || 'beds' || 'icu' => {
          ...administrators, 'doctor', 'nurse', 'inpatientNurse', 'triageNurse',
        },
      'diagnosticReports' => {
          ...administrators, 'doctor', 'nurse', 'labTechnician',
        },
      'prescriptions' => {...administrators, 'doctor', 'pharmacist'},
      'bloodInventory' || 'bloodRequests' || 'donations' => {
          ...administrators, 'bloodBankStaff',
        },
      'emergencies' => {
          ...administrators, 'doctor', 'nurse', 'triageNurse', 'erCoordinator',
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
          'doctor', 'nurse', 'inpatientNurse', 'triageNurse',
          'receptionist', 'receptionStaff',
        },
      'patients' || 'admissions' || 'beds' || 'icu' => {
          'doctor', 'nurse', 'inpatientNurse', 'triageNurse',
        },
      'diagnosticReports' => {'doctor', 'nurse', 'labTechnician'},
      'prescriptions' => {'doctor', 'pharmacist'},
      'bloodInventory' || 'bloodRequests' || 'donations' => {'bloodBankStaff'},
      'emergencies' => {
          'doctor', 'nurse', 'triageNurse', 'erCoordinator',
        },
      'departments' || 'facilities' || 'resources' || 'equipment' ||
      'notifications' => {
          'doctor', 'nurse', 'inpatientNurse', 'triageNurse', 'receptionist',
          'receptionStaff', 'billingStaff', 'bloodBankStaff', 'labTechnician',
          'pharmacist', 'erCoordinator',
        },
      'staff' || 'shifts' => {'hospitalOwner', 'hospitalAdmin', 'hospitalManager'},
      'securityEvents' || 'breakGlassRequests' || 'securityRolePermissions' => {'hospitalOwner', 'hospitalAdmin'},
      'operationalAlerts' || 'notificationDispatches' || 'notificationPreferences' ||
      'notificationRoutingRules' => {
          'doctor', 'nurse', 'inpatientNurse', 'triageNurse', 'receptionist',
          'receptionStaff', 'billingStaff', 'bloodBankStaff', 'labTechnician',
          'pharmacist', 'erCoordinator',
        },
      'resourceRequests' || 'resourceRecommendations' => {'hospitalOwner', 'hospitalAdmin', 'hospitalManager'},
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
      where: (row) => row.userIdentifier.equals(userIdentifier) &
          row.isActive.equals(true),
    );
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
          verificationNotes: 'Upload supporting documents and submit for verification.',
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

  Future<HospitalInfoRecord?> getInfo(Session session, String hospitalKey) async {
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
        : HospitalInfoRecord.db.updateRow(session, info.copyWith(id: existing.id));
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
    if (existing == null) return HospitalProfileRecord.db.insertRow(session, profile);
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

  Future<String> getVerificationStatus(Session session, String hospitalKey) async {
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
    final path = 'hospital-verification/$hospitalKey/'
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
      where: (row) => row.id.equals(documentId) &
          row.hospitalKey.equals(hospitalKey),
    );
    if (document == null) throw Exception('Verification document not found.');
    final bytes = await session.storage.retrieveFile(
      storageId: 'private',
      path: document.fileUrl,
    );
    if (bytes == null) throw Exception('Verification document file is missing.');
    return bytes;
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
          verificationNotes: 'Verification submission received and is under review.',
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
      'hospitalAdmin', 'hospitalManager', 'doctor', 'nurse',
      'inpatientNurse', 'triageNurse', 'receptionist', 'receptionStaff',
      'billingStaff', 'bloodBankStaff', 'labTechnician', 'pharmacist',
      'erCoordinator',
    };
    if (!assignableRoles.contains(user.role) || user.userKey.trim().isEmpty) {
      throw Exception('Hospital member details or role are invalid.');
    }
    final existing = await HospitalUserAccessRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(user.hospitalKey) &
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
              session, user, transaction: transaction,
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
    if (!allowedRoles.contains(role)) throw Exception('Role cannot be assigned.');
    final user = await HospitalUserAccessRecord.db.findFirstRow(
      session,
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.userKey.equals(userKey),
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
        where: (row) => row.hospitalKey.equals(hospitalKey) &
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
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.userKey.equals(userKey),
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
        where: (row) => row.hospitalKey.equals(hospitalKey) &
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
      where: (row) => row.hospitalKey.equals(hospitalKey) &
          row.userIdentifier.equals(identifier) &
          row.isActive.equals(true),
    );
    if (membership == null) throw Exception('No active access to this hospital.');
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
