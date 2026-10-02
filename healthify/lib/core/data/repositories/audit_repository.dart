import '../../models/audit_model.dart';
import '../../queries/domain_queries.dart';
import '../../queries/pagination.dart';

abstract class AuditRepository {
  Future<PaginatedResult<AuditLog>> getAuditLogs(AuditLogQuery query);
  Future<AuditLog?> getAuditLogById(String id);
  Future<void> logAction(AuditLog log);
  Future<Map<String, dynamic>> getAuditSummary();
}
