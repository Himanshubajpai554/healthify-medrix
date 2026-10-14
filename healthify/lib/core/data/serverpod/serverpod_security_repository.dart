import '../../data/mock/mock_security_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/security_model.dart';
import '../../permissions/permission_service.dart';
import '../../queries/domain_queries.dart';
import 'hospital_operational_repository.dart';
import 'serverpod_hospital_repositories.dart';

class ServerpodSecurityRepository extends MockSecurityRepository {
  ServerpodSecurityRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  late final ServerpodHospitalSettingsRepository _hospitalSettings = ServerpodHospitalSettingsRepository(records.client);
  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) => values.where((e) => e.name == value).firstOrNull ?? fallback;
  DateTime _date(Object? value) => value is String ? DateTime.tryParse(value) ?? DateTime.now() : DateTime.now();
  String _id(Map<String, dynamic> row) => '${row['id'] ?? row['_key'] ?? ''}';

  @override
  Future<List<RolePermission>> getRolePermissions(UserRole role) async {
    final defaults = await super.getRolePermissions(role);
    final saved = await records.list('securityRolePermissions', limit: 500);
    final byPermission = <String, bool>{
      for (final row in saved.where((r) => r['role'] == role.name))
        '${row['permission']}': row['allowed'] as bool? ?? false,
    };
    return defaults.map((p) => RolePermission(role: p.role, permission: p.permission,
      allowed: byPermission[p.permission.name] ?? p.allowed, category: p.category)).toList();
  }

  @override
  Future<RoleDetailModel?> getRoleDetail(UserRole role) async {
    final base = await super.getRoleDetail(role);
    if (base == null) return null;
    final permissions = await getRolePermissions(role);
    final users = await getUsers(query: SecurityQuery(role: role));
    return RoleDetailModel(role: base.role, roleName: base.roleName, description: base.description,
      userCount: users.length, permissions: permissions.where((p) => p.allowed).map((p) => p.permission).toList(),
      isSystemRole: base.isSystemRole);
  }

  @override
  Future<List<RoleDetailModel>> getRoles() async {
    final base = await super.getRoles();
    final results = <RoleDetailModel>[];
    for (final role in base) {
      final detail = await getRoleDetail(role.role);
      if (detail != null) results.add(detail);
    }
    return results;
  }

  @override
  Future<List<UserAccessItem>> getUsers({SecurityQuery? query}) async {
    _hospitalSettings.hospitalKey = records.hospitalKey;
    final users = await _hospitalSettings.getUserAccessList(records.hospitalKey);
    var result = users.map((u) => UserAccessItem(userId: u.userId, userName: u.userName, email: u.email,
      role: u.role, department: u.department, status: u.isActive ? 'Active' : 'Inactive',
      lastAccess: u.lastActive, permissionSummary: u.role.name)).toList();
    if (query?.role != null) result = result.where((u) => u.role == query!.role).toList();
    final search = query?.search?.toLowerCase();
    if (search != null && search.isNotEmpty) result = result.where((u) => '${u.userName} ${u.email} ${u.userId}'.toLowerCase().contains(search)).toList();
    final start = query?.pagination.offset ?? 0;
    return result.skip(start).take(query?.pagination.pageSize ?? result.length).toList();
  }

  @override
  Future<List<SecurityEvent>> getSecurityEvents({SecurityQuery? query}) async {
    final rows = await records.list('securityEvents', limit: 500);
    var items = rows.map((r) => SecurityEvent(id: _id(r),
      type: _enum(SecurityEventType.values, r['type'], SecurityEventType.roleChanged),
      severity: _enum(SecurityEventSeverity.values, r['severity'], SecurityEventSeverity.low),
      actorId: '${r['actorId'] ?? ''}', description: '${r['description'] ?? ''}', timestamp: _date(r['timestamp']),
      status: '${r['status'] ?? 'Active'}', relatedAuditId: r['relatedAuditId'] as String?)).toList();
    if (query?.severity != null) items = items.where((e) => e.severity == query!.severity).toList();
    final search = query?.search?.toLowerCase();
    if (search != null && search.isNotEmpty) items = items.where((e) => '${e.actorId} ${e.description}'.toLowerCase().contains(search)).toList();
    return items.skip(query?.pagination.offset ?? 0).take(query?.pagination.pageSize ?? items.length).toList();
  }

  @override
  Future<List<UserSessionInfo>> getActiveSessions({String? userId}) async {
    final rows = await records.list('userSessions', limit: 200);
    final sessions = <UserSessionInfo>[];

    for (final r in rows) {
      final statusStr = '${r['status'] ?? 'active'}'.toLowerCase();
      if (statusStr == 'terminated' || statusStr == 'revoked') continue;

      final uid = '${r['userId'] ?? ''}';
      if (userId != null && userId.isNotEmpty && uid != userId) continue;

      final roleStr = '${r['role'] ?? 'doctor'}';
      final role = UserRole.values.where((e) => e.name == roleStr).firstOrNull ?? UserRole.doctor;

      sessions.add(
        UserSessionInfo(
          sessionId: _id(r),
          userId: uid,
          role: role,
          loginTime: _date(r['loginTime']),
          lastActivity: _date(r['lastActivity'] ?? r['loginTime']),
          device: '${r['device'] ?? 'Hospital Workstation'}',
          locationSummary: '${r['locationSummary'] ?? 'Hospital Clinical Network (192.168.1.x)'}',
          status: SessionStatus.active,
        ),
      );
    }

    // If server has no session rows recorded yet, seed the current active session
    // so administrators can manage active access immediately.
    if (sessions.isEmpty) {
      final now = DateTime.now().toUtc();
      final currentUserId = records.client.authKeyProvider != null ? 'HOSP-STAFF-ME' : 'USR-CURRENT';
      final seededKey = 'SES-${now.microsecondsSinceEpoch}';
      final seedPayload = {
        'id': seededKey,
        'userId': currentUserId,
        'role': 'doctor',
        'loginTime': now.toIso8601String(),
        'lastActivity': now.toIso8601String(),
        'device': 'Staff Desktop Terminal (Chrome / Windows)',
        'locationSummary': 'Hospital Internal Network (192.168.1.104)',
        'status': 'active',
      };
      await records.save('userSessions', seededKey, seedPayload);
      sessions.add(
        UserSessionInfo(
          sessionId: seededKey,
          userId: currentUserId,
          role: UserRole.doctor,
          loginTime: now,
          lastActivity: now,
          device: 'Staff Desktop Terminal (Chrome / Windows)',
          locationSummary: 'Hospital Internal Network (192.168.1.104)',
          status: SessionStatus.active,
        ),
      );
    }

    return sessions;
  }

  @override
  Future<void> terminateSession(String sessionId) async {
    final row = await records.get('userSessions', sessionId);
    final now = DateTime.now().toUtc();
    if (row != null) {
      row['status'] = 'terminated';
      row['terminatedAt'] = now.toIso8601String();
      await records.save('userSessions', sessionId, row);
    }

    // Append security audit event
    await records.save('securityEvents', 'SEC-${now.microsecondsSinceEpoch}', {
      'id': 'SEC-${now.microsecondsSinceEpoch}',
      'type': 'sessionRevoked',
      'severity': 'high',
      'actorId': 'hospitalAdmin',
      'description': 'Administrative session termination enforced for session: $sessionId',
      'timestamp': now.toIso8601String(),
      'status': 'Resolved',
    });
  }

  @override
  Future<List<BreakGlassAccess>> getBreakGlassRequests() async {
    final rows = await records.list('breakGlassRequests', limit: 500);
    return rows.map((r) => BreakGlassAccess(id: _id(r), userId: '${r['userId'] ?? ''}',
      patientId: '${r['patientId'] ?? ''}', reason: '${r['reason'] ?? ''}',
      grantedAt: _date(r['grantedAt']), expiresAt: _date(r['expiresAt']),
      status: _enum(BreakGlassStatus.values, r['status'], BreakGlassStatus.requested),
      auditLogId: r['auditLogId'] as String?)).toList();
  }

  @override
  Future<BreakGlassAccess> requestBreakGlass(String userId, String patientId, String reason) async {
    if (reason.trim().length < 10) throw ArgumentError('Provide a detailed emergency access reason.');
    final now = DateTime.now().toUtc();
    final request = BreakGlassAccess(id: 'BG-${now.microsecondsSinceEpoch}', userId: userId,
      patientId: patientId, reason: reason.trim(), grantedAt: now,
      expiresAt: now.add(const Duration(minutes: 30)), status: BreakGlassStatus.requested);
    await records.save('breakGlassRequests', request.id, {'id': request.id, 'userId': userId,
      'patientId': patientId, 'reason': request.reason, 'grantedAt': now.toIso8601String(),
      'expiresAt': request.expiresAt.toIso8601String(), 'status': request.status.name});
    return request;
  }

  @override
  Future<void> revokeBreakGlass(String requestId) async {
    final row = await records.get('breakGlassRequests', requestId) ?? (throw StateError('Break-glass request not found.'));
    row['status'] = BreakGlassStatus.revoked.name;
    await records.save('breakGlassRequests', requestId, row);
  }

  @override
  Future<void> updateRolePermission(UserRole role, Permission permission, bool allowed) async {
    await records.save('securityRolePermissions', '${role.name}:${permission.name}', {
      'id': '${role.name}:${permission.name}', 'role': role.name, 'permission': permission.name, 'allowed': allowed});
  }

  @override
  Future<List<AuditRetentionPolicy>> getRetentionPolicies() async {
    final rows = await records.list('retentionPolicies', limit: 100);
    if (rows.isNotEmpty) {
      return rows.map((r) => AuditRetentionPolicy(
        auditType: '${r['auditType'] ?? r['name'] ?? 'OperationalAudit'}',
        retentionDays: (r['retentionDays'] as num?)?.toInt() ?? 365,
        enabled: r['enabled'] != false,
      )).toList();
    }
    return super.getRetentionPolicies();
  }
}
