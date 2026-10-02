import 'package:flutter/material.dart';

enum FollowUpStatus {
  scheduled,
  dueToday,
  overdue,
  completed,
  cancelled,
  rescheduled,
}

extension FollowUpStatusExtension on FollowUpStatus {
  String get label {
    switch (this) {
      case FollowUpStatus.scheduled:
        return 'Scheduled';
      case FollowUpStatus.dueToday:
        return 'Due Today';
      case FollowUpStatus.overdue:
        return 'Overdue';
      case FollowUpStatus.completed:
        return 'Completed';
      case FollowUpStatus.cancelled:
        return 'Cancelled';
      case FollowUpStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  Color get color {
    switch (this) {
      case FollowUpStatus.scheduled:
        return const Color(0xFF3B82F6); // Blue
      case FollowUpStatus.dueToday:
        return const Color(0xFFD97706); // Amber
      case FollowUpStatus.overdue:
        return const Color(0xFFEF4444); // Red
      case FollowUpStatus.completed:
        return const Color(0xFF10B981); // Emerald
      case FollowUpStatus.cancelled:
        return const Color(0xFF6B7280); // Slate / Grey
      case FollowUpStatus.rescheduled:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}

enum FollowUpNoteType {
  internal,
  patientVisible,
}

extension FollowUpNoteTypeExtension on FollowUpNoteType {
  String get label {
    switch (this) {
      case FollowUpNoteType.internal:
        return 'Internal Private Note';
      case FollowUpNoteType.patientVisible:
        return 'Patient Visible Note';
    }
  }
}

class FollowUpTimelineItem {
  final String id;
  final DateTime timestamp;
  final String actor;
  final String action;
  final String? optionalNote;

  const FollowUpTimelineItem({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.action,
    this.optionalNote,
  });
}

class FollowUpNoteModel {
  final String id;
  final FollowUpNoteType noteType;
  final String content;
  final String author;
  final DateTime createdAt;

  const FollowUpNoteModel({
    required this.id,
    required this.noteType,
    required this.content,
    required this.author,
    required this.createdAt,
  });
}

class FollowUpRescheduleHistoryModel {
  final String id;
  final DateTime previousDate;
  final String previousTimeSlot;
  final DateTime newDate;
  final String newTimeSlot;
  final String changedBy;
  final DateTime changedAt;
  final String reason;

  const FollowUpRescheduleHistoryModel({
    required this.id,
    required this.previousDate,
    required this.previousTimeSlot,
    required this.newDate,
    required this.newTimeSlot,
    required this.changedBy,
    required this.changedAt,
    required this.reason,
  });
}

class PreviousConsultationSummaryModel {
  final String id; // e.g. "CON-10029"
  final DateTime date;
  final String doctorName;
  final String department;
  final String reason;
  final String clinicalNotesSummary;
  final List<String> reportIds;
  final List<String> prescriptionIds;

  const PreviousConsultationSummaryModel({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.department,
    required this.reason,
    required this.clinicalNotesSummary,
    required this.reportIds,
    required this.prescriptionIds,
  });
}

class UpcomingAppointmentInfoModel {
  final String id; // e.g. "APT-2026-098"
  final DateTime appointmentDate;
  final String timeSlot;
  final String department;
  final String doctorName;
  final String type;
  final String status;

  const UpcomingAppointmentInfoModel({
    required this.id,
    required this.appointmentDate,
    required this.timeSlot,
    required this.department,
    required this.doctorName,
    required this.type,
    required this.status,
  });
}

class DoctorFollowUpFullModel {
  final String id; // e.g. "FU-2026-00982"
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String bloodGroup;
  final List<String> allergies;
  final String phone;
  final DateTime followUpDate;
  final String followUpTime;
  final String department;
  final String doctorName;
  final String reason;
  final String? additionalNotes;
  final DateTime createdDate;
  final String createdBy;
  final FollowUpStatus status;
  final PreviousConsultationSummaryModel? previousConsultation;
  final UpcomingAppointmentInfoModel? upcomingAppointment;
  final List<FollowUpTimelineItem> timeline;
  final List<FollowUpRescheduleHistoryModel> rescheduleHistory;
  final List<FollowUpNoteModel> notes;
  final DateTime? completedDate;
  final String? completedBy;
  final String? completionNote;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? aiSummary;

  DoctorFollowUpFullModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.bloodGroup,
    required this.allergies,
    required this.phone,
    required this.followUpDate,
    required this.followUpTime,
    required this.department,
    required this.doctorName,
    required this.reason,
    this.additionalNotes,
    required this.createdDate,
    required this.createdBy,
    required this.status,
    this.previousConsultation,
    this.upcomingAppointment,
    required this.timeline,
    required this.rescheduleHistory,
    required this.notes,
    this.completedDate,
    this.completedBy,
    this.completionNote,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.aiSummary,
  });

  DoctorFollowUpFullModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? bloodGroup,
    List<String>? allergies,
    String? phone,
    DateTime? followUpDate,
    String? followUpTime,
    String? department,
    String? doctorName,
    String? reason,
    String? additionalNotes,
    DateTime? createdDate,
    String? createdBy,
    FollowUpStatus? status,
    PreviousConsultationSummaryModel? previousConsultation,
    UpcomingAppointmentInfoModel? upcomingAppointment,
    List<FollowUpTimelineItem>? timeline,
    List<FollowUpRescheduleHistoryModel>? rescheduleHistory,
    List<FollowUpNoteModel>? notes,
    DateTime? completedDate,
    String? completedBy,
    String? completionNote,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? aiSummary,
  }) {
    return DoctorFollowUpFullModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      phone: phone ?? this.phone,
      followUpDate: followUpDate ?? this.followUpDate,
      followUpTime: followUpTime ?? this.followUpTime,
      department: department ?? this.department,
      doctorName: doctorName ?? this.doctorName,
      reason: reason ?? this.reason,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      createdDate: createdDate ?? this.createdDate,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      previousConsultation: previousConsultation ?? this.previousConsultation,
      upcomingAppointment: upcomingAppointment ?? this.upcomingAppointment,
      timeline: timeline ?? this.timeline,
      rescheduleHistory: rescheduleHistory ?? this.rescheduleHistory,
      notes: notes ?? this.notes,
      completedDate: completedDate ?? this.completedDate,
      completedBy: completedBy ?? this.completedBy,
      completionNote: completionNote ?? this.completionNote,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }

  int get daysOverdue {
    if (status != FollowUpStatus.overdue && status != FollowUpStatus.dueToday) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final fDate = DateTime(followUpDate.year, followUpDate.month, followUpDate.day);
    final diff = today.difference(fDate).inDays;
    return diff > 0 ? diff : 0;
  }
}

enum FollowUpSortOption {
  soonest,
  latest,
  patientName,
}
