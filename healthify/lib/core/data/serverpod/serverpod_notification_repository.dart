import '../../data/mock/mock_notification_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/notification_model.dart';
import '../../queries/domain_queries.dart';
import 'hospital_operational_repository.dart';

class ServerpodNotificationRepository extends MockNotificationRepository {
  ServerpodNotificationRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;

  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) =>
      values.where((item) => item.name == value).firstOrNull ?? fallback;
  DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value) : null;
  String _id(Map<String, dynamic> row) => '${row['id'] ?? row['_key'] ?? ''}';

  NotificationRecord _notification(Map<String, dynamic> row) => NotificationRecord(
    id: _id(row), hospitalId: records.hospitalKey,
    recipientId: '${row['recipientId'] ?? ''}',
    recipientRole: _enum(UserRole.values, row['recipientRole'], UserRole.hospitalManager),
    type: _enum(NotificationType.values, row['type'], NotificationType.system),
    title: '${row['title'] ?? ''}', message: '${row['message'] ?? ''}',
    priority: _enum(NotificationPriority.values, row['priority'], NotificationPriority.medium),
    status: _enum(NotificationStatus.values, row['status'], NotificationStatus.unread),
    sourceEntityType: row['sourceEntityType'] as String?,
    sourceEntityId: row['sourceEntityId'] as String?,
    createdAt: _date(row['createdAt']) ?? DateTime.now(),
    readAt: _date(row['readAt']), acknowledgedAt: _date(row['acknowledgedAt']),
    expiresAt: _date(row['expiresAt']),
    metadata: Map<String, dynamic>.from(row['metadata'] as Map? ?? const {}),
  );

  Map<String, dynamic> _notificationJson(NotificationRecord n) => {
    'id': n.id, 'recipientId': n.recipientId, 'recipientRole': n.recipientRole.name,
    'type': n.type.name, 'title': n.title, 'message': n.message,
    'priority': n.priority.name, 'status': n.status.name,
    'sourceEntityType': n.sourceEntityType, 'sourceEntityId': n.sourceEntityId,
    'createdAt': n.createdAt.toIso8601String(), 'readAt': n.readAt?.toIso8601String(),
    'acknowledgedAt': n.acknowledgedAt?.toIso8601String(),
    'expiresAt': n.expiresAt?.toIso8601String(), 'metadata': n.metadata,
  };

  Future<Map<String, dynamic>> _required(String collection, String id) async =>
      await records.get(collection, id) ?? (throw StateError('$collection record not found.'));

  @override
  Future<NotificationRecord> createNotification(NotificationRecord notification) async {
    await records.save('notifications', notification.id, _notificationJson(notification));
    return notification;
  }

  @override
  Future<List<NotificationRecord>> getNotifications({NotificationQuery? query}) async {
    var rows = await records.list('notifications', limit: 500);
    final q = query?.effectiveSearch?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      rows = rows.where((r) => [r['id'], r['title'], r['message'], r['recipientId'], r['sourceEntityType'], r['sourceEntityId']]
          .any((v) => v?.toString().toLowerCase().contains(q) ?? false)).toList();
    }
    if (query?.type != null) rows = rows.where((r) => r['type'] == query!.type!.name).toList();
    if (query?.priority != null) rows = rows.where((r) => r['priority'] == query!.priority!.name).toList();
    if (query?.status != null) rows = rows.where((r) => r['status'] == query!.status!.name).toList();
    if (query?.recipientId?.isNotEmpty == true) rows = rows.where((r) => r['recipientId'] == query!.recipientId).toList();
    if (query?.recipientRole != null) rows = rows.where((r) => r['recipientRole'] == query!.recipientRole!.name).toList();
    if (query?.sourceEntityType?.isNotEmpty == true) rows = rows.where((r) => r['sourceEntityType'] == query!.sourceEntityType).toList();
    if (query?.unreadOnly == true) rows = rows.where((r) => r['status'] == NotificationStatus.unread.name).toList();
    if (query?.criticalOnly == true) rows = rows.where((r) => r['priority'] == NotificationPriority.critical.name).toList();
    if (query?.isRead != null) rows = rows.where((r) => (r['status'] != NotificationStatus.unread.name) == query!.isRead).toList();
    return rows.map(_notification).toList(growable: false);
  }

  @override
  Future<NotificationRecord?> getNotificationById(String id) async {
    final row = await records.get('notifications', id);
    return row == null ? null : _notification(row);
  }

  Future<void> _setNotification(String id, NotificationStatus status, {bool acknowledge = false}) async {
    final row = await _required('notifications', id);
    row['status'] = status.name;
    if (status == NotificationStatus.read || status == NotificationStatus.acknowledged) {
      row['readAt'] ??= DateTime.now().toUtc().toIso8601String();
    }
    if (acknowledge) row['acknowledgedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('notifications', id, row);
  }

  @override
  Future<void> markAsRead(String id) => _setNotification(id, NotificationStatus.read);
  @override
  Future<void> markAsUnread(String id) => _setNotification(id, NotificationStatus.unread);
  @override
  Future<void> acknowledgeNotification(String id) => _setNotification(id, NotificationStatus.acknowledged, acknowledge: true);
  @override
  Future<void> dismissNotification(String id) async {
    final row = await _required('notifications', id);
    final n = _notification(row);
    if (n.priority == NotificationPriority.critical && !n.isAcknowledged) {
      throw StateError('Critical notifications must be acknowledged before dismissal.');
    }
    await _setNotification(id, NotificationStatus.dismissed);
  }

  @override
  Future<int> getUnreadCount({String? recipientId}) async => (await getNotifications(
    query: NotificationQuery(recipientId: recipientId, unreadOnly: true))).length;

  @override
  Future<List<NotificationRecord>> getCriticalNotifications({String? recipientId}) async =>
      (await getNotifications(query: NotificationQuery(recipientId: recipientId, criticalOnly: true, isRead: false)));

  @override
  Future<List<OperationalAlert>> getAlerts({NotificationQuery? query}) async {
    final rows = await records.list('operationalAlerts', limit: 500);
    return rows.map((r) => OperationalAlert(
      id: _id(r), hospitalId: records.hospitalKey,
      type: _enum(NotificationType.values, r['type'], NotificationType.system),
      title: '${r['title'] ?? ''}', description: '${r['description'] ?? ''}',
      severity: _enum(NotificationPriority.values, r['severity'], NotificationPriority.medium),
      sourceEntityType: r['sourceEntityType'] as String?, sourceEntityId: r['sourceEntityId'] as String?,
      status: _enum(OperationalAlertStatus.values, r['status'], OperationalAlertStatus.active),
      createdAt: _date(r['createdAt']) ?? DateTime.now(), acknowledgedAt: _date(r['acknowledgedAt']),
      resolvedAt: _date(r['resolvedAt']), expiresAt: _date(r['expiresAt']),
    )).toList();
  }

  Future<void> _setAlert(String id, OperationalAlertStatus status) async {
    final row = await _required('operationalAlerts', id);
    row['status'] = status.name;
    final now = DateTime.now().toUtc().toIso8601String();
    if (status == OperationalAlertStatus.acknowledged) row['acknowledgedAt'] = now;
    if (status == OperationalAlertStatus.resolved) row['resolvedAt'] = now;
    await records.save('operationalAlerts', id, row);
  }

  @override
  Future<void> acknowledgeAlert(String id) => _setAlert(id, OperationalAlertStatus.acknowledged);
  @override
  Future<void> resolveAlert(String id) => _setAlert(id, OperationalAlertStatus.resolved);

  @override
  Future<List<NotificationDispatch>> getDispatches({NotificationQuery? query}) async {
    final rows = await records.list('notificationDispatches', limit: 500);
    return rows.map((r) => NotificationDispatch(
      id: _id(r), notificationId: '${r['notificationId'] ?? ''}',
      channel: _enum(DispatchChannel.values, r['channel'], DispatchChannel.inApp),
      recipientId: '${r['recipientId'] ?? ''}',
      status: _enum(DispatchStatus.values, r['status'], DispatchStatus.pending),
      attemptedAt: _date(r['attemptedAt']), deliveredAt: _date(r['deliveredAt']),
      failedAt: _date(r['failedAt']), failureReason: r['failureReason'] as String?,
    )).toList();
  }

  @override
  Future<void> retryDispatch(String dispatchId) async {
    final row = await _required('notificationDispatches', dispatchId);
    row['status'] = DispatchStatus.pending.name;
    row['attemptedAt'] = DateTime.now().toUtc().toIso8601String();
    row['failureReason'] = null;
    await records.save('notificationDispatches', dispatchId, row);
  }

  @override
  Future<List<NotificationPreference>> getNotificationPreferences(String userId) async {
    final rows = await records.list('notificationPreferences', limit: 500);
    return rows.where((r) => r['userId'] == userId).map((r) => NotificationPreference(
      userId: userId, notificationType: _enum(NotificationType.values, r['notificationType'], NotificationType.system),
      inAppEnabled: r['inAppEnabled'] as bool? ?? true, pushEnabled: r['pushEnabled'] as bool? ?? true,
      emailEnabled: r['emailEnabled'] as bool? ?? false, smsEnabled: r['smsEnabled'] as bool? ?? false,
    )).toList();
  }

  @override
  Future<void> updateNotificationPreference(NotificationPreference preference) async => records.save(
    'notificationPreferences', '${preference.userId}:${preference.notificationType.name}', {
      'id': '${preference.userId}:${preference.notificationType.name}', 'userId': preference.userId,
      'notificationType': preference.notificationType.name, 'inAppEnabled': preference.inAppEnabled,
      'pushEnabled': preference.pushEnabled, 'emailEnabled': preference.emailEnabled, 'smsEnabled': preference.smsEnabled,
    });

  @override
  Future<List<NotificationRoutingRule>> getRoutingRules() async {
    final rows = await records.list('notificationRoutingRules', limit: 500);
    return rows.map((r) => NotificationRoutingRule(
      id: _id(r), hospitalId: records.hospitalKey,
      notificationType: _enum(NotificationType.values, r['notificationType'], NotificationType.system),
      recipientRole: _enum(UserRole.values, r['recipientRole'], UserRole.hospitalManager),
      priority: _enum(NotificationPriority.values, r['priority'], NotificationPriority.medium),
      channels: (r['channels'] as List? ?? const []).map((v) => _enum(DispatchChannel.values, v, DispatchChannel.inApp)).toList(),
      enabled: r['enabled'] as bool? ?? true,
    )).toList();
  }

  @override
  Future<void> updateRoutingRule(NotificationRoutingRule rule) async => records.save(
    'notificationRoutingRules', rule.id, {'id': rule.id, 'notificationType': rule.notificationType.name,
      'recipientRole': rule.recipientRole.name, 'priority': rule.priority.name,
      'channels': rule.channels.map((c) => c.name).toList(), 'enabled': rule.enabled});

  @override
  Future<void> clearAllNotifications() async {
    final rows = await records.list('notifications', limit: 500);
    for (final row in rows) { await records.delete('notifications', _id(row)); }
  }
}
