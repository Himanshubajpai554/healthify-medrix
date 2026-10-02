import '../repositories/security_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/security_model.dart';
import '../../permissions/permission_service.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockSecurityRepository implements SecurityRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<RoleDetailModel>> getRoles() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      RoleDetailModel(
        role: UserRole.superAdmin,
        roleName: 'Hospital Super Administrator',
        description: 'Full system authorization across all clinical, financial, and governance operations.',
        userCount: 2,
        permissions: Permission.values,
      ),
      RoleDetailModel(
        role: UserRole.hospitalAdmin,
        roleName: 'Hospital Administrator',
        description: 'Operational, administrative, and resource management authorization.',
        userCount: 5,
        permissions: PermissionService.getPermissionsForRole(UserRole.hospitalAdmin).toList(),
      ),
      RoleDetailModel(
        role: UserRole.doctor,
        roleName: 'Attending Physician / Doctor',
        description: 'Clinical evaluation, diagnosis, prescription, and patient management.',
        userCount: 48,
        permissions: PermissionService.getPermissionsForRole(UserRole.doctor).toList(),
      ),
      RoleDetailModel(
        role: UserRole.nurse,
        roleName: 'Inpatient / ICU Nurse',
        description: 'Ward care, patient vital tracking, bed management, and emergency triage assistance.',
        userCount: 140,
        permissions: PermissionService.getPermissionsForRole(UserRole.nurse).toList(),
      ),
      RoleDetailModel(
        role: UserRole.receptionist,
        roleName: 'Reception & Registration Staff',
        description: 'Patient intake, appointment scheduling, and front-desk check-ins.',
        userCount: 24,
        permissions: PermissionService.getPermissionsForRole(UserRole.receptionist).toList(),
      ),
      RoleDetailModel(
        role: UserRole.labTechnician,
        roleName: 'Laboratory Technician',
        description: 'Diagnostic test execution, lab result upload, and report submission.',
        userCount: 18,
        permissions: PermissionService.getPermissionsForRole(UserRole.labTechnician).toList(),
      ),
      RoleDetailModel(
        role: UserRole.pharmacist,
        roleName: 'Pharmacist',
        description: 'Prescription fulfillment, medication inventory review, and dispensing.',
        userCount: 12,
        permissions: PermissionService.getPermissionsForRole(UserRole.pharmacist).toList(),
      ),
    ];
  }

  @override
  Future<RoleDetailModel?> getRoleDetail(UserRole role) async {
    final roles = await getRoles();
    final matches = roles.where((r) => r.role == role);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<List<RolePermission>> getRolePermissions(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final assigned = PermissionService.getPermissionsForRole(role);
    return Permission.values.map((p) {
      return RolePermission(
        role: role,
        permission: p,
        allowed: assigned.contains(p),
        category: _getCategoryForPermission(p),
      );
    }).toList();
  }

  @override
  Future<void> updateRolePermission(UserRole role, Permission permission, bool allowed) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<List<UserAccessItem>> getUsers({SecurityQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.userAccessItems.toList();

    if (query != null) {
      if (query.search != null && query.search!.trim().isNotEmpty) {
        final q = query.search!.trim().toLowerCase();
        list = list.where((u) =>
            u.userName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.userId.toLowerCase().contains(q) ||
            u.department.toLowerCase().contains(q)).toList();
      }
      if (query.role != null) {
        list = list.where((u) => u.role == query.role).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<List<SecurityEvent>> getSecurityEvents({SecurityQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.securityEvents.toList();

    if (query != null) {
      if (query.severity != null) {
        list = list.where((e) => e.severity == query.severity).toList();
      }
      if (query.status != null && query.status!.isNotEmpty) {
        list = list.where((e) => e.status.toLowerCase() == query.status!.toLowerCase()).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<List<UserSessionInfo>> getActiveSessions({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _store.userSessions.toList();
    if (userId != null && userId.isNotEmpty) {
      list = list.where((s) => s.userId == userId).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  Future<void> terminateSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _store.userSessions.removeWhere((s) => s.sessionId == sessionId);
  }

  @override
  Future<List<BreakGlassAccess>> getBreakGlassRequests() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_store.breakGlassRequests);
  }

  @override
  Future<BreakGlassAccess> requestBreakGlass(String userId, String patientId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final item = BreakGlassAccess(
      id: 'BG-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      patientId: patientId,
      reason: reason,
      grantedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      status: BreakGlassStatus.granted,
      auditLogId: 'AUD-BG-${DateTime.now().millisecondsSinceEpoch}',
    );

    _store.breakGlassRequests.insert(0, item);

    // Automatically record security event for Break Glass
    _store.securityEvents.insert(
      0,
      SecurityEvent(
        id: 'SEC-EVT-${DateTime.now().millisecondsSinceEpoch}',
        type: SecurityEventType.breakGlassTriggered,
        severity: SecurityEventSeverity.high,
        actorId: userId,
        description: 'Break-Glass Emergency Access granted for Patient $patientId. Reason: $reason',
        timestamp: DateTime.now(),
        status: 'Active',
        relatedAuditId: item.auditLogId,
      ),
    );

    return item;
  }

  @override
  Future<void> revokeBreakGlass(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.breakGlassRequests.indexWhere((b) => b.id == requestId);
    if (index != -1) {
      final old = _store.breakGlassRequests[index];
      _store.breakGlassRequests[index] = BreakGlassAccess(
        id: old.id,
        userId: old.userId,
        patientId: old.patientId,
        reason: old.reason,
        grantedAt: old.grantedAt,
        expiresAt: DateTime.now(),
        status: BreakGlassStatus.revoked,
        auditLogId: old.auditLogId,
      );
    }
  }

  @override
  Future<List<AuditRetentionPolicy>> getRetentionPolicies() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_store.retentionPolicies);
  }

  String _getCategoryForPermission(Permission p) {
    final name = p.name.toLowerCase();
    if (name.contains('hospital') || name.contains('department')) return 'Hospital';
    if (name.contains('patient') || name.contains('admission')) return 'Patients';
    if (name.contains('appointment')) return 'Appointments';
    if (name.contains('doctor')) return 'Doctors';
    if (name.contains('staff') || name.contains('roster')) return 'Staff';
    if (name.contains('bed')) return 'Beds';
    if (name.contains('icu')) return 'ICU';
    if (name.contains('blood')) return 'Blood Bank';
    if (name.contains('emergency')) return 'Emergency';
    if (name.contains('report')) return 'Reports';
    if (name.contains('prescription')) return 'Prescriptions';
    if (name.contains('resource')) return 'Resources';
    if (name.contains('ai') || name.contains('forecast')) return 'AI';
    if (name.contains('notification') || name.contains('alert') || name.contains('dispatch')) return 'Notifications';
    return 'Security & Audit';
  }
}
