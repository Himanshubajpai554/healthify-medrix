import '../enums/domain_enums.dart';
import '../permissions/permission_service.dart';

/// Role-Permission Mapping Model
class RolePermission {
  final UserRole role;
  final Permission permission;
  final bool allowed;
  final String category;

  const RolePermission({
    required this.role,
    required this.permission,
    required this.allowed,
    required this.category,
  });
}

/// Role Detail Model
class RoleDetailModel {
  final UserRole role;
  final String roleName;
  final String description;
  final int userCount;
  final List<Permission> permissions;
  final bool isSystemRole;

  const RoleDetailModel({
    required this.role,
    required this.roleName,
    required this.description,
    required this.userCount,
    required this.permissions,
    this.isSystemRole = true,
  });
}

/// User Access Directory Model
class UserAccessItem {
  final String userId;
  final String userName;
  final String email;
  final UserRole role;
  final String department;
  final String status;
  final DateTime lastAccess;
  final String permissionSummary;

  const UserAccessItem({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.department,
    this.status = 'Active',
    required this.lastAccess,
    required this.permissionSummary,
  });
}

/// Security Event Contract Model
class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final SecurityEventSeverity severity;
  final String actorId;
  final String description;
  final DateTime timestamp;
  final String status;
  final String? relatedAuditId;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.actorId,
    required this.description,
    required this.timestamp,
    this.status = 'Active',
    this.relatedAuditId,
  });
}

/// Emergency Clinical Break-Glass Access Model
class BreakGlassAccess {
  final String id;
  final String userId;
  final String patientId;
  final String reason;
  final DateTime grantedAt;
  final DateTime expiresAt;
  final BreakGlassStatus status;
  final String? auditLogId;

  const BreakGlassAccess({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.reason,
    required this.grantedAt,
    required this.expiresAt,
    this.status = BreakGlassStatus.requested,
    this.auditLogId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Sensitive Data Access Tracking Event Model
class SensitiveAccessEvent {
  final String id;
  final String actorId;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final String? reason;
  final bool authorized;

  const SensitiveAccessEvent({
    required this.id,
    required this.actorId,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    this.reason,
    this.authorized = true,
  });
}

/// User Device Active Session Info Model
class UserSessionInfo {
  final String sessionId;
  final String userId;
  final UserRole role;
  final DateTime loginTime;
  final DateTime lastActivity;
  final String device;
  final String locationSummary;
  final SessionStatus status;

  const UserSessionInfo({
    required this.sessionId,
    required this.userId,
    required this.role,
    required this.loginTime,
    required this.lastActivity,
    required this.device,
    this.locationSummary = 'Hospital Internal Network (192.168.1.x)',
    this.status = SessionStatus.active,
  });
}

/// Audit Log Retention Configuration Policy Model
class AuditRetentionPolicy {
  final String auditType;
  final int retentionDays;
  final bool enabled;

  const AuditRetentionPolicy({
    required this.auditType,
    this.retentionDays = 365,
    this.enabled = true,
  });
}
