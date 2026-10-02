import '../../enums/domain_enums.dart';
import '../../models/security_model.dart';
import '../../permissions/permission_service.dart';
import '../../queries/domain_queries.dart';

abstract class SecurityRepository {
  Future<List<RoleDetailModel>> getRoles();
  Future<RoleDetailModel?> getRoleDetail(UserRole role);
  Future<List<RolePermission>> getRolePermissions(UserRole role);
  Future<void> updateRolePermission(UserRole role, Permission permission, bool allowed);

  Future<List<UserAccessItem>> getUsers({SecurityQuery? query});
  Future<List<SecurityEvent>> getSecurityEvents({SecurityQuery? query});
  Future<List<UserSessionInfo>> getActiveSessions({String? userId});
  Future<void> terminateSession(String sessionId);

  Future<List<BreakGlassAccess>> getBreakGlassRequests();
  Future<BreakGlassAccess> requestBreakGlass(String userId, String patientId, String reason);
  Future<void> revokeBreakGlass(String requestId);

  Future<List<AuditRetentionPolicy>> getRetentionPolicies();
}
