import 'package:flutter/material.dart';

enum NotificationCategory {
  all,
  unread,
  appointments,
  patients,
  reports,
  prescriptions,
  emergency,
  system,
  hospital,
}

extension NotificationCategoryExtension on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.all:
        return 'All';
      case NotificationCategory.unread:
        return 'Unread';
      case NotificationCategory.appointments:
        return 'Appointments';
      case NotificationCategory.patients:
        return 'Patients';
      case NotificationCategory.reports:
        return 'Reports';
      case NotificationCategory.prescriptions:
        return 'Prescriptions';
      case NotificationCategory.emergency:
        return 'Emergency';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.hospital:
        return 'Hospital Updates';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.all:
        return Icons.notifications_active_rounded;
      case NotificationCategory.unread:
        return Icons.mark_email_unread_rounded;
      case NotificationCategory.appointments:
        return Icons.calendar_today_rounded;
      case NotificationCategory.patients:
        return Icons.people_alt_rounded;
      case NotificationCategory.reports:
        return Icons.assignment_rounded;
      case NotificationCategory.prescriptions:
        return Icons.medication_rounded;
      case NotificationCategory.emergency:
        return Icons.emergency_rounded;
      case NotificationCategory.system:
        return Icons.settings_rounded;
      case NotificationCategory.hospital:
        return Icons.local_hospital_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.all:
      case NotificationCategory.unread:
        return const Color(0xFF0D9488); // Primary Teal
      case NotificationCategory.appointments:
        return Colors.blue;
      case NotificationCategory.patients:
        return Colors.purple;
      case NotificationCategory.reports:
        return Colors.amber.shade800;
      case NotificationCategory.prescriptions:
        return Colors.teal;
      case NotificationCategory.emergency:
        return Colors.redAccent;
      case NotificationCategory.system:
        return Colors.blueGrey;
      case NotificationCategory.hospital:
        return Colors.indigo;
    }
  }
}

enum NotificationPriority {
  normal,
  important,
  urgent,
}

extension NotificationPriorityExtension on NotificationPriority {
  String get label {
    switch (this) {
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.important:
        return 'Important';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case NotificationPriority.normal:
        return Colors.blueGrey;
      case NotificationPriority.important:
        return Colors.orange.shade700;
      case NotificationPriority.urgent:
        return Colors.redAccent;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case NotificationPriority.normal:
        return Colors.blueGrey.withValues(alpha: 0.12);
      case NotificationPriority.important:
        return Colors.orange.withValues(alpha: 0.15);
      case NotificationPriority.urgent:
        return Colors.red.withValues(alpha: 0.15);
    }
  }
}

class DoctorNotificationFullModel {
  final String id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final NotificationCategory category;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime timestamp;
  final String? relatedEntityId;
  final String? relatedPatientId;
  final String? relatedPatientName;
  final String? targetRoute;
  final String? actionLabel;
  final DateTime auditCreated;
  final DateTime auditDelivered;
  final DateTime? auditRead;
  final bool isGroupedHeader;
  final int groupedCount;

  const DoctorNotificationFullModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.category,
    required this.priority,
    required this.isRead,
    required this.timestamp,
    this.relatedEntityId,
    this.relatedPatientId,
    this.relatedPatientName,
    this.targetRoute,
    this.actionLabel,
    required this.auditCreated,
    required this.auditDelivered,
    this.auditRead,
    this.isGroupedHeader = false,
    this.groupedCount = 1,
  });

  DoctorNotificationFullModel copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? fullDescription,
    NotificationCategory? category,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? timestamp,
    String? relatedEntityId,
    String? relatedPatientId,
    String? relatedPatientName,
    String? targetRoute,
    String? actionLabel,
    DateTime? auditCreated,
    DateTime? auditDelivered,
    DateTime? auditRead,
    bool? isGroupedHeader,
    int? groupedCount,
  }) {
    return DoctorNotificationFullModel(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedPatientId: relatedPatientId ?? this.relatedPatientId,
      relatedPatientName: relatedPatientName ?? this.relatedPatientName,
      targetRoute: targetRoute ?? this.targetRoute,
      actionLabel: actionLabel ?? this.actionLabel,
      auditCreated: auditCreated ?? this.auditCreated,
      auditDelivered: auditDelivered ?? this.auditDelivered,
      auditRead: auditRead ?? this.auditRead,
      isGroupedHeader: isGroupedHeader ?? this.isGroupedHeader,
      groupedCount: groupedCount ?? this.groupedCount,
    );
  }
}

class NotificationPreferencesModel {
  final NotificationCategory category;
  final bool inAppEnabled;
  final bool pushEnabled;
  final bool emailEnabled;

  const NotificationPreferencesModel({
    required this.category,
    this.inAppEnabled = true,
    this.pushEnabled = false,
    this.emailEnabled = false,
  });

  NotificationPreferencesModel copyWith({
    NotificationCategory? category,
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
  }) {
    return NotificationPreferencesModel(
      category: category ?? this.category,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
    );
  }
}
