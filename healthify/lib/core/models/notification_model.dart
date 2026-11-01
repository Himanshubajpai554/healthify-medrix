import '../enums/domain_enums.dart';

/// Legacy NotificationSeverity for backward compatibility
enum NotificationSeverity { info, warning, critical }

/// Legacy SystemNotificationItem for backward compatibility
class SystemNotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationSeverity severity;
  bool isRead;

  SystemNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.isRead = false,
  });
}

/// Healthify Central Notification Record Model
class NotificationRecord {
  final String id;
  final String hospitalId;
  final String recipientId;
  final UserRole recipientRole;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationPriority priority;
  final NotificationStatus status;
  final String? sourceEntityType;
  final String? sourceEntityId;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? acknowledgedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const NotificationRecord({
    required this.id,
    this.hospitalId = 'HOSP-001',
    required this.recipientId,
    required this.recipientRole,
    required this.type,
    required this.title,
    required this.message,
    this.priority = NotificationPriority.medium,
    this.status = NotificationStatus.unread,
    this.sourceEntityType,
    this.sourceEntityId,
    required this.createdAt,
    this.readAt,
    this.acknowledgedAt,
    this.expiresAt,
    this.metadata = const {},
  });

  bool get isRead => status == NotificationStatus.read || status == NotificationStatus.acknowledged || readAt != null;
  bool get isUnread => status == NotificationStatus.unread;
  bool get isAcknowledged => status == NotificationStatus.acknowledged || acknowledgedAt != null;
  String get category => type.name;

  bool get isExpired => status == NotificationStatus.expired || (expiresAt != null && DateTime.now().isAfter(expiresAt!));
  DateTime get timestamp => createdAt;

  NotificationSeverity get severity {
    switch (priority) {
      case NotificationPriority.critical:
        return NotificationSeverity.critical;
      case NotificationPriority.high:
        return NotificationSeverity.warning;
      default:
        return NotificationSeverity.info;
    }
  }

  NotificationRecord copyWith({
    String? id,
    String? hospitalId,
    String? recipientId,
    UserRole? recipientRole,
    NotificationType? type,
    String? title,
    String? message,
    NotificationPriority? priority,
    NotificationStatus? status,
    String? sourceEntityType,
    String? sourceEntityId,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? acknowledgedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationRecord(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      recipientId: recipientId ?? this.recipientId,
      recipientRole: recipientRole ?? this.recipientRole,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      sourceEntityType: sourceEntityType ?? this.sourceEntityType,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Notification Dispatch Channel Delivery Tracking Model
class NotificationDispatch {
  final String id;
  final String notificationId;
  final DispatchChannel channel;
  final String recipientId;
  final DispatchStatus status;
  final DateTime? attemptedAt;
  final DateTime? deliveredAt;
  final DateTime? failedAt;
  final String? failureReason;

  const NotificationDispatch({
    required this.id,
    required this.notificationId,
    required this.channel,
    required this.recipientId,
    required this.status,
    this.attemptedAt,
    this.deliveredAt,
    this.failedAt,
    this.failureReason,
  });

  NotificationDispatch copyWith({
    String? id,
    String? notificationId,
    DispatchChannel? channel,
    String? recipientId,
    DispatchStatus? status,
    DateTime? attemptedAt,
    DateTime? deliveredAt,
    DateTime? failedAt,
    String? failureReason,
  }) {
    return NotificationDispatch(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      channel: channel ?? this.channel,
      recipientId: recipientId ?? this.recipientId,
      status: status ?? this.status,
      attemptedAt: attemptedAt ?? this.attemptedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      failedAt: failedAt ?? this.failedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

/// Notification Routing Rule Contract Model
class NotificationRoutingRule {
  final String id;
  final String hospitalId;
  final NotificationType notificationType;
  final UserRole recipientRole;
  final NotificationPriority priority;
  final List<DispatchChannel> channels;
  final bool enabled;

  const NotificationRoutingRule({
    required this.id,
    this.hospitalId = 'HOSP-001',
    required this.notificationType,
    required this.recipientRole,
    required this.priority,
    required this.channels,
    this.enabled = true,
  });

  NotificationRoutingRule copyWith({
    String? id,
    String? hospitalId,
    NotificationType? notificationType,
    UserRole? recipientRole,
    NotificationPriority? priority,
    List<DispatchChannel>? channels,
    bool? enabled,
  }) {
    return NotificationRoutingRule(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      notificationType: notificationType ?? this.notificationType,
      recipientRole: recipientRole ?? this.recipientRole,
      priority: priority ?? this.priority,
      channels: channels ?? this.channels,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// User Notification Channel Preference Model
class NotificationPreference {
  final String userId;
  final NotificationType notificationType;
  final bool inAppEnabled;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  const NotificationPreference({
    required this.userId,
    required this.notificationType,
    this.inAppEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
  });

  NotificationPreference copyWith({
    String? userId,
    NotificationType? notificationType,
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return NotificationPreference(
      userId: userId ?? this.userId,
      notificationType: notificationType ?? this.notificationType,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }
}

/// Operational Alert Model (Higher severity operational condition)
class OperationalAlert {
  final String id;
  final String hospitalId;
  final NotificationType type;
  final String title;
  final String description;
  final NotificationPriority severity;
  final String? sourceEntityType;
  final String? sourceEntityId;
  final OperationalAlertStatus status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final DateTime? expiresAt;

  const OperationalAlert({
    required this.id,
    this.hospitalId = 'HOSP-001',
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    this.sourceEntityType,
    this.sourceEntityId,
    this.status = OperationalAlertStatus.active,
    required this.createdAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.expiresAt,
  });

  bool get isActive => status == OperationalAlertStatus.active;
  bool get isAcknowledged => status == OperationalAlertStatus.acknowledged || acknowledgedAt != null;
  bool get isResolved => status == OperationalAlertStatus.resolved || resolvedAt != null;
  bool get isExpired => status == OperationalAlertStatus.expired || (expiresAt != null && DateTime.now().isAfter(expiresAt!));

  OperationalAlert copyWith({
    String? id,
    String? hospitalId,
    NotificationType? type,
    String? title,
    String? description,
    NotificationPriority? severity,
    String? sourceEntityType,
    String? sourceEntityId,
    OperationalAlertStatus? status,
    DateTime? createdAt,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    DateTime? expiresAt,
  }) {
    return OperationalAlert(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      sourceEntityType: sourceEntityType ?? this.sourceEntityType,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Alert Escalation Rule Contract Model
class AlertEscalationRule {
  final String id;
  final NotificationType alertType;
  final UserRole initialRecipientRole;
  final UserRole escalationRecipientRole;
  final int delayMinutes;
  final bool enabled;

  const AlertEscalationRule({
    required this.id,
    required this.alertType,
    required this.initialRecipientRole,
    required this.escalationRecipientRole,
    this.delayMinutes = 15,
    this.enabled = true,
  });

  AlertEscalationRule copyWith({
    String? id,
    NotificationType? alertType,
    UserRole? initialRecipientRole,
    UserRole? escalationRecipientRole,
    int? delayMinutes,
    bool? enabled,
  }) {
    return AlertEscalationRule(
      id: id ?? this.id,
      alertType: alertType ?? this.alertType,
      initialRecipientRole: initialRecipientRole ?? this.initialRecipientRole,
      escalationRecipientRole: escalationRecipientRole ?? this.escalationRecipientRole,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Notification Audit Activity Record
class NotificationActivity {
  final String id;
  final String notificationId;
  final NotificationActivityAction action;
  final String actorId;
  final DateTime timestamp;
  final String? details;

  const NotificationActivity({
    required this.id,
    required this.notificationId,
    required this.action,
    required this.actorId,
    required this.timestamp,
    this.details,
  });
}
