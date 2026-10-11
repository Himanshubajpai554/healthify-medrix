import 'dart:convert';

import '../../data/mock/mock_audit_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/audit_model.dart';
import '../../queries/domain_queries.dart';
import '../../queries/pagination.dart';
import 'hospital_operational_repository.dart';

class ServerpodAuditRepository extends MockAuditRepository {
  ServerpodAuditRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) => values.where((e) => e.name.toLowerCase() == '$value'.toLowerCase()).firstOrNull ?? fallback;
  DateTime _date(Object? value) => value is String ? DateTime.tryParse(value) ?? DateTime.now() : DateTime.now();
  AuditLog _from(Map<String, dynamic> r) {
    final action = '${r['action'] ?? 'read'}'.toLowerCase();
    final details = <String, dynamic>{'collection': r['collection'], 'recordKey': r['recordKey'], 'details': r['details']};
    return AuditLog(id: '${r['id'] ?? ''}', timestamp: _date(r['occurredAt']),
      actorId: '${r['actorUserIdentifier'] ?? ''}', actorRole: UserRole.hospitalManager,
      actionType: _enum(AuditActionType.values, action, AuditActionType.read),
      targetEntityType: '${r['collection'] ?? ''}', targetEntityId: '${r['recordKey'] ?? ''}',
      status: 'SUCCESS', details: details, createdAt: _date(r['occurredAt']), updatedAt: _date(r['occurredAt']));
  }

  @override
  Future<PaginatedResult<AuditLog>> getAuditLogs(AuditLogQuery query) async {
    var rows = await records.auditEvents(limit: 500);
    if (query.effectiveActorId != null) rows = rows.where((r) => r['actorUserIdentifier'] == query.effectiveActorId).toList();
    if (query.actionType != null) rows = rows.where((r) => r['action'] == query.actionType!.name).toList();
    if (query.targetEntityType != null) rows = rows.where((r) => r['collection'] == query.targetEntityType).toList();
    if (query.targetEntityId != null) rows = rows.where((r) => r['recordKey'] == query.targetEntityId).toList();
    if (query.startDate != null) rows = rows.where((r) => _date(r['occurredAt']).isAfter(query.startDate!) || _date(r['occurredAt']).isAtSameMomentAs(query.startDate!)).toList();
    if (query.endDate != null) rows = rows.where((r) => _date(r['occurredAt']).isBefore(query.endDate!) || _date(r['occurredAt']).isAtSameMomentAs(query.endDate!)).toList();
    final search = query.effectiveSearch?.toLowerCase();
    if (search != null && search.isNotEmpty) rows = rows.where((r) => r.values.any((v) => v?.toString().toLowerCase().contains(search) ?? false)).toList();
    final total = rows.length;
    final start = query.pagination.offset.clamp(0, total);
    final end = (start + query.pagination.pageSize).clamp(start, total);
    return PaginatedResult(items: rows.sublist(start, end).map(_from).toList(), totalCount: total,
      page: query.pagination.page, pageSize: query.pagination.pageSize);
  }

  @override
  Future<AuditLog?> getAuditLogById(String id) async {
    final rows = await records.auditEvents(limit: 500);
    for (final row in rows) { if (row['id'] == id) return _from(row); }
    return null;
  }

  @override
  Future<Map<String, dynamic>> getAuditSummary() async {
    final rows = await records.auditEvents(limit: 500);
    return {'totalEvents': rows.length,
      'createCount': rows.where((r) => r['action'] == 'create').length,
      'updateCount': rows.where((r) => r['action'] == 'update').length,
      'deleteCount': rows.where((r) => r['action'] == 'delete').length,
      'deniedCount': 0};
  }

  @override
  Future<void> logAction(AuditLog log) async {
    await records.client.hospital.logAuditAction(
      records.hospitalKey,
      log.actionType.name,
      log.targetEntityType,
      log.targetEntityId,
      jsonEncode({
        'status': log.status,
        'ipAddress': log.ipAddress,
        'userAgent': log.userAgent,
        'previousState': log.previousState,
        'newState': log.newState,
        'details': log.details,
      }),
    );
  }
}

