import '../repositories/notification_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/notification_model.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockNotificationRepository implements NotificationRepository {
  static MockNotificationRepository Function()? serverpodFactory;
  factory MockNotificationRepository() => serverpodFactory?.call() ?? MockNotificationRepository.fallback();
  MockNotificationRepository.fallback();

  final MockDataStore _store = MockDataStore();

  @override
  Future<NotificationRecord> createNotification(NotificationRecord notification) async {
    _store.notificationRecords.insert(0, notification);
    return notification;
  }

  @override
  Future<List<NotificationRecord>> getNotifications({NotificationQuery? query}) async {

    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.notificationRecords.toList();

    if (query != null) {
      if (query.effectiveSearch != null && query.effectiveSearch!.trim().isNotEmpty) {
        final q = query.effectiveSearch!.trim().toLowerCase();
        list = list.where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.message.toLowerCase().contains(q) ||
            n.id.toLowerCase().contains(q) ||
            (n.sourceEntityType != null && n.sourceEntityType!.toLowerCase().contains(q)) ||
            (n.sourceEntityId != null && n.sourceEntityId!.toLowerCase().contains(q)) ||
            n.recipientId.toLowerCase().contains(q)).toList();
      }

      if (query.type != null) {
        list = list.where((n) => n.type == query.type).toList();
      }

      if (query.priority != null) {
        list = list.where((n) => n.priority == query.priority).toList();
      }

      if (query.status != null) {
        list = list.where((n) => n.status == query.status).toList();
      }

      if (query.recipientId != null && query.recipientId!.isNotEmpty) {
        list = list.where((n) => n.recipientId == query.recipientId).toList();
      }

      if (query.recipientRole != null) {
        list = list.where((n) => n.recipientRole == query.recipientRole).toList();
      }

      if (query.sourceEntityType != null && query.sourceEntityType!.isNotEmpty) {
        list = list.where((n) => n.sourceEntityType?.toLowerCase() == query.sourceEntityType!.toLowerCase()).toList();
      }

      if (query.unreadOnly != null && query.unreadOnly!) {
        list = list.where((n) => n.isUnread).toList();
      }

      if (query.criticalOnly != null && query.criticalOnly!) {
        list = list.where((n) => n.priority == NotificationPriority.critical).toList();
      }

      if (query.isRead != null) {
        list = list.where((n) => n.isRead == query.isRead!).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<NotificationRecord?> getNotificationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matches = _store.notificationRecords.where((n) => n.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.notificationRecords.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _store.notificationRecords[index];
      _store.notificationRecords[index] = old.copyWith(
        status: NotificationStatus.read,
        readAt: DateTime.now(),
      );

      _store.notificationActivities.insert(
        0,
        NotificationActivity(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          notificationId: id,
          action: NotificationActivityAction.read,
          actorId: old.recipientId,
          timestamp: DateTime.now(),
          details: 'Marked as read',
        ),
      );
    }
  }

  @override
  Future<void> markAsUnread(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.notificationRecords.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _store.notificationRecords[index];
      _store.notificationRecords[index] = old.copyWith(
        status: NotificationStatus.unread,
      );
    }
  }

  @override
  Future<void> acknowledgeNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.notificationRecords.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _store.notificationRecords[index];
      _store.notificationRecords[index] = old.copyWith(
        status: NotificationStatus.acknowledged,
        acknowledgedAt: DateTime.now(),
        readAt: old.readAt ?? DateTime.now(),
      );

      _store.notificationActivities.insert(
        0,
        NotificationActivity(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          notificationId: id,
          action: NotificationActivityAction.acknowledged,
          actorId: old.recipientId,
          timestamp: DateTime.now(),
          details: 'Acknowledged high-priority notification',
        ),
      );
    }
  }

  @override
  Future<void> dismissNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.notificationRecords.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _store.notificationRecords[index];
      // Do NOT allow critical notifications to be silently dismissed if unacknowledged
      if (old.priority == NotificationPriority.critical && !old.isAcknowledged) {
        throw Exception('Critical notifications require explicit acknowledgement before dismissal.');
      }

      _store.notificationRecords[index] = old.copyWith(
        status: NotificationStatus.dismissed,
      );

      _store.notificationActivities.insert(
        0,
        NotificationActivity(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          notificationId: id,
          action: NotificationActivityAction.dismissed,
          actorId: old.recipientId,
          timestamp: DateTime.now(),
          details: 'Dismissed by user',
        ),
      );
    }
  }

  @override
  Future<int> getUnreadCount({String? recipientId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _store.notificationRecords.where((n) => n.isUnread);
    if (recipientId != null && recipientId.isNotEmpty) {
      list = list.where((n) => n.recipientId == recipientId);
    }
    return list.length;
  }

  @override
  Future<List<NotificationRecord>> getCriticalNotifications({String? recipientId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _store.notificationRecords.where((n) => n.priority == NotificationPriority.critical && !n.isRead);
    if (recipientId != null && recipientId.isNotEmpty) {
      list = list.where((n) => n.recipientId == recipientId);
    }
    return List.unmodifiable(list.toList());
  }

  @override
  Future<List<OperationalAlert>> getAlerts({NotificationQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.operationalAlerts.toList();

    if (query != null) {
      if (query.effectiveSearch != null && query.effectiveSearch!.trim().isNotEmpty) {
        final q = query.effectiveSearch!.trim().toLowerCase();
        list = list.where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.description.toLowerCase().contains(q) ||
            a.id.toLowerCase().contains(q)).toList();
      }
      if (query.type != null) {
        list = list.where((a) => a.type == query.type).toList();
      }
      if (query.priority != null) {
        list = list.where((a) => a.severity == query.priority).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<OperationalAlert?> getAlertById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matches = _store.operationalAlerts.where((a) => a.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> acknowledgeAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.operationalAlerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _store.operationalAlerts[index];
      _store.operationalAlerts[index] = old.copyWith(
        status: OperationalAlertStatus.acknowledged,
        acknowledgedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> resolveAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.operationalAlerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _store.operationalAlerts[index];
      _store.operationalAlerts[index] = old.copyWith(
        status: OperationalAlertStatus.resolved,
        resolvedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<NotificationDispatch>> getDispatches({NotificationQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_store.notificationDispatches);
  }

  @override
  Future<void> retryDispatch(String dispatchId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _store.notificationDispatches.indexWhere((d) => d.id == dispatchId);
    if (index != -1) {
      final old = _store.notificationDispatches[index];
      _store.notificationDispatches[index] = old.copyWith(
        status: DispatchStatus.delivered,
        attemptedAt: DateTime.now(),
        deliveredAt: DateTime.now(),
        failedAt: null,
        failureReason: null,
      );
    }
  }

  @override
  Future<List<NotificationPreference>> getNotificationPreferences(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_store.notificationPreferences.where((p) => p.userId == userId).toList());
  }

  @override
  Future<void> updateNotificationPreference(NotificationPreference preference) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.notificationPreferences.indexWhere(
        (p) => p.userId == preference.userId && p.notificationType == preference.notificationType);
    if (index != -1) {
      _store.notificationPreferences[index] = preference;
    } else {
      _store.notificationPreferences.add(preference);
    }
  }

  @override
  Future<List<NotificationRoutingRule>> getRoutingRules() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_store.notificationRoutingRules);
  }

  @override
  Future<void> updateRoutingRule(NotificationRoutingRule rule) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.notificationRoutingRules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _store.notificationRoutingRules[index] = rule;
    } else {
      _store.notificationRoutingRules.add(rule);
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _store.notificationRecords.clear();
    _store.notifications.clear();
  }
}
