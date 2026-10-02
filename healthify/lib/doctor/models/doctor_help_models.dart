import 'package:flutter/material.dart';

enum HelpArticleCategory {
  appointments,
  patients,
  consultations,
  reports,
  prescriptions,
  emergency,
  followups,
  notifications,
  availability,
  security,
}

extension HelpArticleCategoryExtension on HelpArticleCategory {
  String get label {
    switch (this) {
      case HelpArticleCategory.appointments:
        return 'Appointments';
      case HelpArticleCategory.patients:
        return 'Patients';
      case HelpArticleCategory.consultations:
        return 'Consultations';
      case HelpArticleCategory.reports:
        return 'Reports';
      case HelpArticleCategory.prescriptions:
        return 'Prescriptions';
      case HelpArticleCategory.emergency:
        return 'Emergency Cases';
      case HelpArticleCategory.followups:
        return 'Follow-ups';
      case HelpArticleCategory.notifications:
        return 'Notifications';
      case HelpArticleCategory.availability:
        return 'Availability';
      case HelpArticleCategory.security:
        return 'Account & Security';
    }
  }

  IconData get icon {
    switch (this) {
      case HelpArticleCategory.appointments:
        return Icons.calendar_today_rounded;
      case HelpArticleCategory.patients:
        return Icons.people_alt_rounded;
      case HelpArticleCategory.consultations:
        return Icons.medical_services_rounded;
      case HelpArticleCategory.reports:
        return Icons.assignment_rounded;
      case HelpArticleCategory.prescriptions:
        return Icons.medication_rounded;
      case HelpArticleCategory.emergency:
        return Icons.emergency_rounded;
      case HelpArticleCategory.followups:
        return Icons.health_and_safety_rounded;
      case HelpArticleCategory.notifications:
        return Icons.notifications_rounded;
      case HelpArticleCategory.availability:
        return Icons.calendar_month_rounded;
      case HelpArticleCategory.security:
        return Icons.security_rounded;
    }
  }

  Color get color {
    switch (this) {
      case HelpArticleCategory.appointments:
        return Colors.blue;
      case HelpArticleCategory.patients:
        return Colors.purple;
      case HelpArticleCategory.consultations:
        return const Color(0xFF0D9488);
      case HelpArticleCategory.reports:
        return Colors.amber.shade800;
      case HelpArticleCategory.prescriptions:
        return Colors.teal;
      case HelpArticleCategory.emergency:
        return Colors.redAccent;
      case HelpArticleCategory.followups:
        return Colors.green;
      case HelpArticleCategory.notifications:
        return Colors.indigo;
      case HelpArticleCategory.availability:
        return Colors.deepOrange;
      case HelpArticleCategory.security:
        return Colors.blueGrey;
    }
  }
}

class HelpArticleModel {
  final String id;
  final String title;
  final HelpArticleCategory category;
  final String shortDescription;
  final List<String> contentSteps;
  final DateTime lastUpdated;
  final int helpfulCount;
  final bool isPopular;

  const HelpArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.contentSteps,
    required this.lastUpdated,
    this.helpfulCount = 42,
    this.isPopular = false,
  });
}

enum SupportTicketPriority {
  normal,
  important,
  urgent,
}

extension SupportTicketPriorityExtension on SupportTicketPriority {
  String get label {
    switch (this) {
      case SupportTicketPriority.normal:
        return 'Normal Priority';
      case SupportTicketPriority.important:
        return 'Important';
      case SupportTicketPriority.urgent:
        return 'Urgent (Support Priority)';
    }
  }

  Color get color {
    switch (this) {
      case SupportTicketPriority.normal:
        return Colors.blueGrey;
      case SupportTicketPriority.important:
        return Colors.orange.shade800;
      case SupportTicketPriority.urgent:
        return Colors.redAccent;
    }
  }
}

enum SupportTicketStatus {
  open,
  inProgress,
  waitingForInfo,
  resolved,
  closed,
}

extension SupportTicketStatusExtension on SupportTicketStatus {
  String get label {
    switch (this) {
      case SupportTicketStatus.open:
        return 'Open';
      case SupportTicketStatus.inProgress:
        return 'In Progress';
      case SupportTicketStatus.waitingForInfo:
        return 'Waiting for Info';
      case SupportTicketStatus.resolved:
        return 'Resolved';
      case SupportTicketStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case SupportTicketStatus.open:
        return Colors.blue;
      case SupportTicketStatus.inProgress:
        return Colors.amber.shade800;
      case SupportTicketStatus.waitingForInfo:
        return Colors.purple;
      case SupportTicketStatus.resolved:
        return const Color(0xFF10B981);
      case SupportTicketStatus.closed:
        return Colors.blueGrey;
    }
  }
}

class TicketMessageModel {
  final String id;
  final String senderName;
  final bool isDoctor;
  final DateTime timestamp;
  final String messageText;

  const TicketMessageModel({
    required this.id,
    required this.senderName,
    required this.isDoctor,
    required this.timestamp,
    required this.messageText,
  });
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final SupportTicketPriority priority;
  final SupportTicketStatus status;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final List<TicketMessageModel> messages;
  final List<String> attachments;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdDate,
    required this.lastUpdated,
    required this.messages,
    this.attachments = const [],
  });

  SupportTicketModel copyWith({
    String? id,
    String? subject,
    String? category,
    SupportTicketPriority? priority,
    SupportTicketStatus? status,
    DateTime? createdDate,
    DateTime? lastUpdated,
    List<TicketMessageModel>? messages,
    List<String>? attachments,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
      attachments: attachments ?? this.attachments,
    );
  }
}

class HospitalAdminContactModel {
  final String hospitalName;
  final String adminName;
  final String role;
  final String department;
  final String phone;
  final String email;
  final String officeHours;

  const HospitalAdminContactModel({
    required this.hospitalName,
    required this.adminName,
    required this.role,
    required this.department,
    required this.phone,
    required this.email,
    required this.officeHours,
  });
}

class SystemServiceStatus {
  final String serviceName;
  final String status; // Operational, Degraded, Unavailable
  final String statusDetails;

  const SystemServiceStatus({
    required this.serviceName,
    required this.status,
    required this.statusDetails,
  });
}

class TroubleshootingGuideModel {
  final String id;
  final String title;
  final List<String> possibleCauses;
  final List<String> recommendedSteps;

  const TroubleshootingGuideModel({
    required this.id,
    required this.title,
    required this.possibleCauses,
    required this.recommendedSteps,
  });
}
