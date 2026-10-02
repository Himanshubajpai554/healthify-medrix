import '../../models/audit_model.dart';
import '../../queries/domain_queries.dart';
import '../../queries/pagination.dart';
import '../repositories/audit_repository.dart';
import 'mock_data_store.dart';

class MockAuditRepository implements AuditRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<PaginatedResult<AuditLog>> getAuditLogs(AuditLogQuery query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.auditLogs.toList();

    if (query.effectiveSearch != null && query.effectiveSearch!.trim().isNotEmpty) {
      final q = query.effectiveSearch!.trim().toLowerCase();
      list = list.where((l) =>
          l.id.toLowerCase().contains(q) ||
          l.actorId.toLowerCase().contains(q) ||
          l.targetEntityType.toLowerCase().contains(q) ||
          l.targetEntityId.toLowerCase().contains(q) ||
          l.action.toLowerCase().contains(q)).toList();
    }

    if (query.effectiveActorId != null && query.effectiveActorId!.isNotEmpty) {
      list = list.where((l) => l.actorId == query.effectiveActorId).toList();
    }

    if (query.actorRole != null) {
      list = list.where((l) => l.actorRole == query.actorRole).toList();
    }

    if (query.actionType != null) {
      list = list.where((l) => l.actionType == query.actionType).toList();
    }

    if (query.targetEntityType != null && query.targetEntityType!.isNotEmpty) {
      list = list.where((l) => l.targetEntityType.toLowerCase() == query.targetEntityType!.toLowerCase()).toList();
    }

    if (query.permissionDeniedOnly != null && query.permissionDeniedOnly!) {
      list = list.where((l) => l.status == 'DENIED' || l.actionType.name == 'permissionDenied').toList();
    }

    return PaginatedResult(
      items: List.unmodifiable(list),
      totalCount: list.length,
      page: query.pagination.page,
      pageSize: query.pagination.pageSize,
    );
  }

  @override
  Future<AuditLog?> getAuditLogById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matches = _store.auditLogs.where((l) => l.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> logAction(AuditLog log) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _store.auditLogs.insert(0, log);
  }

  @override
  Future<Map<String, dynamic>> getAuditSummary() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final today = DateTime.now();
    final todayCount = _store.auditLogs.where((l) => l.timestamp.day == today.day).length;
    final denialCount = _store.auditLogs.where((l) => l.status == 'DENIED').length;
    final breakGlassCount = _store.auditLogs.where((l) => l.actionType.name.contains('breakGlass')).length;

    return {
      'totalAuditLogs': _store.auditLogs.length,
      'todayLogs': todayCount,
      'permissionDenials': denialCount,
      'breakGlassEvents': breakGlassCount,
    };
  }
}
