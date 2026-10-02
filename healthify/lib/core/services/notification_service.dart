import '../data/repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../queries/domain_queries.dart';

class NotificationService {
  final NotificationRepository _notificationRepository;

  NotificationService({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  Future<List<NotificationRecord>> getNotifications({NotificationQuery? query}) async {
    return await _notificationRepository.getNotifications(query: query);
  }

  Future<NotificationRecord?> getNotification(String id) async {
    return await _notificationRepository.getNotificationById(id);
  }

  Future<void> markAsRead(String id) async {
    await _notificationRepository.markAsRead(id);
  }

  Future<void> markAsUnread(String id) async {
    await _notificationRepository.markAsUnread(id);
  }

  Future<void> acknowledgeNotification(String id) async {
    await _notificationRepository.acknowledgeNotification(id);
  }

  Future<void> dismissNotification(String id) async {
    await _notificationRepository.dismissNotification(id);
  }

  Future<int> getUnreadCount({String? recipientId}) async {
    return await _notificationRepository.getUnreadCount(recipientId: recipientId);
  }

  Future<List<NotificationRecord>> getCriticalNotifications({String? recipientId}) async {
    return await _notificationRepository.getCriticalNotifications(recipientId: recipientId);
  }

  Future<List<OperationalAlert>> getAlerts({NotificationQuery? query}) async {
    return await _notificationRepository.getAlerts(query: query);
  }

  Future<OperationalAlert?> getAlert(String id) async {
    return await _notificationRepository.getAlertById(id);
  }

  Future<void> acknowledgeAlert(String id) async {
    await _notificationRepository.acknowledgeAlert(id);
  }

  Future<void> resolveAlert(String id) async {
    await _notificationRepository.resolveAlert(id);
  }

  Future<List<NotificationDispatch>> getDispatches({NotificationQuery? query}) async {
    return await _notificationRepository.getDispatches(query: query);
  }

  Future<void> retryDispatch(String dispatchId) async {
    await _notificationRepository.retryDispatch(dispatchId);
  }

  Future<List<NotificationPreference>> getPreferences(String userId) async {
    return await _notificationRepository.getNotificationPreferences(userId);
  }

  Future<void> updatePreference(NotificationPreference preference) async {
    await _notificationRepository.updateNotificationPreference(preference);
  }

  Future<List<NotificationRoutingRule>> getRoutingRules() async {
    return await _notificationRepository.getRoutingRules();
  }

  Future<void> updateRoutingRule(NotificationRoutingRule rule) async {
    await _notificationRepository.updateRoutingRule(rule);
  }
}
