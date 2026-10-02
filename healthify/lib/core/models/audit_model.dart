import '../enums/domain_enums.dart';

/// Central Audit Log Entity Model
class AuditLog {
  final String id;
  final DateTime timestamp;
  final String actorId;
  final UserRole actorRole;
  final String? ipAddress;
  final String? userAgent;
  final AuditActionType actionType;
  final String targetEntityType;
  final String targetEntityId;
  final Map<String, dynamic>? previousState;
  final Map<String, dynamic>? newState;
  final String status; // SUCCESS, DENIED, FAILED
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuditLog({
    required this.id,
    required this.timestamp,
    required this.actorId,
    required this.actorRole,
    this.ipAddress,
    this.userAgent,
    required this.actionType,
    required this.targetEntityType,
    required this.targetEntityId,
    this.previousState,
    this.newState,
    this.status = 'SUCCESS',
    this.details = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  String get action => actionType.name.toUpperCase();
  String get userId => actorId;
  UserRole get userRole => actorRole;
  String get entityType => targetEntityType;
  String get entityId => targetEntityId;
}
