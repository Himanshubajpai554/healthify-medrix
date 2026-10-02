import '../../models/notification_model.dart';
import '../../queries/domain_queries.dart';

abstract class NotificationRepository {
  Future<List<NotificationRecord>> getNotifications({NotificationQuery? query});
  Future<NotificationRecord?> getNotificationById(String id);
  Future<NotificationRecord> createNotification(NotificationRecord notification);


  Future<void> markAsRead(String id);
  Future<void> markAsUnread(String id);
  Future<void> acknowledgeNotification(String id);
  Future<void> dismissNotification(String id);

  Future<int> getUnreadCount({String? recipientId});
  Future<List<NotificationRecord>> getCriticalNotifications({String? recipientId});

  Future<List<OperationalAlert>> getAlerts({NotificationQuery? query});
  Future<OperationalAlert?> getAlertById(String id);
  Future<void> acknowledgeAlert(String id);
  Future<void> resolveAlert(String id);

  Future<List<NotificationDispatch>> getDispatches({NotificationQuery? query});
  Future<void> retryDispatch(String dispatchId);

  Future<List<NotificationPreference>> getNotificationPreferences(String userId);
  Future<void> updateNotificationPreference(NotificationPreference preference);

  Future<List<NotificationRoutingRule>> getRoutingRules();
  Future<void> updateRoutingRule(NotificationRoutingRule rule);

  Future<void> clearAllNotifications();
}
