import '../data/repositories/audit_repository.dart';
import '../enums/domain_enums.dart';
import '../models/audit_model.dart';
import '../queries/domain_queries.dart';
import '../queries/pagination.dart';

class AuditService {
  final AuditRepository _auditRepository;

  AuditService({required AuditRepository auditRepository})
      : _auditRepository = auditRepository;

  Future<PaginatedResult<AuditLog>> query(AuditLogQuery query) async {
    return await _auditRepository.getAuditLogs(query);
  }

  Future<AuditLog?> getById(String id) async {
    return await _auditRepository.getAuditLogById(id);
  }

  Future<void> record(AuditLog log) async {
    await _auditRepository.logAction(log);
  }

  Future<void> recordAccess({
    required String actorId,
    required UserRole actorRole,
    required String targetEntityType,
    required String targetEntityId,
    String? ipAddress,
    Map<String, dynamic> details = const {},
  }) async {
    await record(
      AuditLog(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        actorId: actorId,
        actorRole: actorRole,
        ipAddress: ipAddress,
        actionType: AuditActionType.read,
        targetEntityType: targetEntityType,
        targetEntityId: targetEntityId,
        status: 'SUCCESS',
        details: details,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> recordMutation({
    required String actorId,
    required UserRole actorRole,
    required AuditActionType actionType,
    required String targetEntityType,
    required String targetEntityId,
    Map<String, dynamic>? previousState,
    Map<String, dynamic>? newState,
    String? ipAddress,
  }) async {
    await record(
      AuditLog(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        actorId: actorId,
        actorRole: actorRole,
        ipAddress: ipAddress,
        actionType: actionType,
        targetEntityType: targetEntityType,
        targetEntityId: targetEntityId,
        previousState: previousState,
        newState: newState,
        status: 'SUCCESS',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> recordPermissionDenied({
    required String actorId,
    required UserRole actorRole,
    required String attemptedAction,
    required String targetEntityType,
    required String targetEntityId,
  }) async {
    await record(
      AuditLog(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        actorId: actorId,
        actorRole: actorRole,
        actionType: AuditActionType.permissionDenied,
        targetEntityType: targetEntityType,
        targetEntityId: targetEntityId,
        status: 'DENIED',
        details: {'attemptedAction': attemptedAction},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<Map<String, dynamic>> getSummary() async {
    return await _auditRepository.getAuditSummary();
  }
}
