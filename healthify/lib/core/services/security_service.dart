import '../data/repositories/security_repository.dart';
import '../enums/domain_enums.dart';
import '../models/security_model.dart';
import '../permissions/permission_service.dart';
import '../queries/domain_queries.dart';

class SecurityService {
  final SecurityRepository _securityRepository;

  SecurityService({required SecurityRepository securityRepository})
      : _securityRepository = securityRepository;

  Future<List<RoleDetailModel>> getRoles() async {
    return await _securityRepository.getRoles();
  }

  Future<RoleDetailModel?> getRoleDetail(UserRole role) async {
    return await _securityRepository.getRoleDetail(role);
  }

  Future<List<RolePermission>> getRolePermissions(UserRole role) async {
    return await _securityRepository.getRolePermissions(role);
  }

  Future<void> updateRolePermission(UserRole role, Permission permission, bool allowed) async {
    await _securityRepository.updateRolePermission(role, permission, allowed);
  }

  Future<List<UserAccessItem>> getUsers({SecurityQuery? query}) async {
    return await _securityRepository.getUsers(query: query);
  }

  Future<List<SecurityEvent>> getSecurityEvents({SecurityQuery? query}) async {
    return await _securityRepository.getSecurityEvents(query: query);
  }

  Future<List<UserSessionInfo>> getActiveSessions({String? userId}) async {
    return await _securityRepository.getActiveSessions(userId: userId);
  }

  Future<void> terminateSession(String sessionId) async {
    await _securityRepository.terminateSession(sessionId);
  }

  Future<List<BreakGlassAccess>> getBreakGlassRequests() async {
    return await _securityRepository.getBreakGlassRequests();
  }

  Future<BreakGlassAccess> requestBreakGlass(String userId, String patientId, String reason) async {
    return await _securityRepository.requestBreakGlass(userId, patientId, reason);
  }

  Future<void> revokeBreakGlass(String requestId) async {
    await _securityRepository.revokeBreakGlass(requestId);
  }

  Future<List<AuditRetentionPolicy>> getRetentionPolicies() async {
    return await _securityRepository.getRetentionPolicies();
  }
}
