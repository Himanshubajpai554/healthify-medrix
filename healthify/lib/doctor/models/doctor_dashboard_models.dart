import 'package:flutter/material.dart';

enum DoctorAvailability { available, busy, offline }

enum AppointmentStatus {
  upcoming,
  checkedIn,
  waiting,
  inConsultation,
  completed,
  cancelled,
  noShow,
}

enum PatientCareStatus {
  active,
  newPatient,
  followUpDue,
  admitted,
  emergency,
  discharged,
  inactive,
}

enum ReportPriority { normal, high, urgent }

enum EmergencySeverity { critical, high, moderate }

enum ClinicalNoteType {
  consultationNote,
  followUpNote,
  observation,
  internalNote,
}

class PatientModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String avatarUrl;
  final String phone;
  final String bloodGroup;
  final String mrn;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final String lastVisitDate;
  final String lastVisitDoctor;
  final String primaryConcern;
  final PatientCareStatus careStatus;
  final String? nextAppointmentText;
  final String? followUpStatus; // Due, Scheduled, Completed
  final String department;
  final List<String> clinicalAlerts;

  const PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.avatarUrl,
    required this.phone,
    required this.bloodGroup,
    required this.mrn,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    required this.lastVisitDate,
    required this.lastVisitDoctor,
    required this.primaryConcern,
    this.careStatus = PatientCareStatus.active,
    this.nextAppointmentText,
    this.followUpStatus = 'Scheduled',
    this.department = 'Cardiology',
    this.clinicalAlerts = const [],
  });

  PatientModel copyWith({
    PatientCareStatus? careStatus,
    String? followUpStatus,
    String? nextAppointmentText,
    List<String>? clinicalAlerts,
  }) {
    return PatientModel(
      id: id,
      name: name,
      age: age,
      gender: gender,
      avatarUrl: avatarUrl,
      phone: phone,
      bloodGroup: bloodGroup,
      mrn: mrn,
      allergies: allergies,
      chronicConditions: chronicConditions,
      currentMedications: currentMedications,
      lastVisitDate: lastVisitDate,
      lastVisitDoctor: lastVisitDoctor,
      primaryConcern: primaryConcern,
      careStatus: careStatus ?? this.careStatus,
      nextAppointmentText: nextAppointmentText ?? this.nextAppointmentText,
      followUpStatus: followUpStatus ?? this.followUpStatus,
      department: department,
      clinicalAlerts: clinicalAlerts ?? this.clinicalAlerts,
    );
  }
}

class DoctorAppointmentModel {
  final String id;
  final PatientModel patient;
  final String appointmentTime;
  final String appointmentType;
  final String department;
  final AppointmentStatus status;
  final String tokenNumber;
  final bool isNextUpcoming;
  final String reasonForVisit;
  final String? clinicalAlert;
  final String? checkedInTime;
  final String? waitingDuration;
  final String consultationMode;
  final String? cancellationReason;
  final String? previousVisitDate;
  final DateTime date;

  const DoctorAppointmentModel({
    required this.id,
    required this.patient,
    required this.appointmentTime,
    required this.appointmentType,
    required this.department,
    required this.status,
    required this.tokenNumber,
    this.isNextUpcoming = false,
    required this.reasonForVisit,
    this.clinicalAlert,
    this.checkedInTime,
    this.waitingDuration,
    this.consultationMode = 'In-Person OPD',
    this.cancellationReason,
    this.previousVisitDate,
    required this.date,
  });

  DoctorAppointmentModel copyWith({
    AppointmentStatus? status,
    String? checkedInTime,
    String? waitingDuration,
    String? cancellationReason,
    bool? isNextUpcoming,
  }) {
    return DoctorAppointmentModel(
      id: id,
      patient: patient,
      appointmentTime: appointmentTime,
      appointmentType: appointmentType,
      department: department,
      status: status ?? this.status,
      tokenNumber: tokenNumber,
      isNextUpcoming: isNextUpcoming ?? this.isNextUpcoming,
      reasonForVisit: reasonForVisit,
      clinicalAlert: clinicalAlert,
      checkedInTime: checkedInTime ?? this.checkedInTime,
      waitingDuration: waitingDuration ?? this.waitingDuration,
      consultationMode: consultationMode,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      previousVisitDate: previousVisitDate,
      date: date,
    );
  }
}

class PatientQueueItemModel {
  final String position;
  final PatientModel patient;
  final String appointmentTime;
  final String waitingTime;
  final AppointmentStatus status;

  const PatientQueueItemModel({
    required this.position,
    required this.patient,
    required this.appointmentTime,
    required this.waitingTime,
    required this.status,
  });
}

class DoctorEmergencyCaseModel {
  final String id;
  final PatientModel patient;
  final EmergencySeverity severity;
  final String arrivalTime;
  final String assignedBed;
  final String department;
  final String assignedDoctor;
  final String currentStatus;

  const DoctorEmergencyCaseModel({
    required this.id,
    required this.patient,
    required this.severity,
    required this.arrivalTime,
    required this.assignedBed,
    required this.department,
    required this.assignedDoctor,
    required this.currentStatus,
  });
}

class PendingReportModel {
  final String id;
  final PatientModel patient;
  final String reportType;
  final String date;
  final ReportPriority priority;
  final bool isReviewed;
  final String? clinicalNotes;
  final Map<String, String> labValues;

  const PendingReportModel({
    required this.id,
    required this.patient,
    required this.reportType,
    required this.date,
    required this.priority,
    this.isReviewed = false,
    this.clinicalNotes,
    required this.labValues,
  });

  PendingReportModel copyWith({bool? isReviewed, String? clinicalNotes}) {
    return PendingReportModel(
      id: id,
      patient: patient,
      reportType: reportType,
      date: date,
      priority: priority,
      isReviewed: isReviewed ?? this.isReviewed,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      labValues: labValues,
    );
  }
}

class AIPatientSummaryModel {
  final PatientModel patient;
  final int previousVisitsCount;
  final int recentLabReportsCount;
  final List<String> currentMedications;
  final String lastConsultationText;
  final String recentReportAttention;
  final String keyFindings;

  const AIPatientSummaryModel({
    required this.patient,
    required this.previousVisitsCount,
    required this.recentLabReportsCount,
    required this.currentMedications,
    required this.lastConsultationText,
    required this.recentReportAttention,
    required this.keyFindings,
  });
}

class DoctorNotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final String category;

  const DoctorNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    required this.category,
  });

  DoctorNotificationModel copyWith({bool? isRead}) {
    return DoctorNotificationModel(
      id: id,
      title: title,
      message: message,
      time: time,
      icon: icon,
      iconColor: iconColor,
      isRead: isRead ?? this.isRead,
      category: category,
    );
  }
}

class DoctorAnalyticsModel {
  final int patientsSeenThisWeek;
  final double appointmentsCompletedPercent;
  final double followUpRatePercent;
  final String avgConsultationTime;
  final double cancelledPercent;
  final double patientRating;
  final List<int> dailyPatientsSeen;

  const DoctorAnalyticsModel({
    required this.patientsSeenThisWeek,
    required this.appointmentsCompletedPercent,
    required this.followUpRatePercent,
    required this.avgConsultationTime,
    required this.cancelledPercent,
    required this.patientRating,
    required this.dailyPatientsSeen,
  });
}

class DoctorAvailabilityConfig {
  final DoctorAvailability status;
  final String workingHoursStart;
  final String workingHoursEnd;
  final String breakStart;
  final String breakEnd;
  final int slotDurationMinutes;
  final String nextAvailableSlot;
  final List<String> workingDays;

  const DoctorAvailabilityConfig({
    required this.status,
    required this.workingHoursStart,
    required this.workingHoursEnd,
    required this.breakStart,
    required this.breakEnd,
    required this.slotDurationMinutes,
    required this.nextAvailableSlot,
    this.workingDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  });

  DoctorAvailabilityConfig copyWith({
    DoctorAvailability? status,
    String? workingHoursStart,
    String? workingHoursEnd,
    String? breakStart,
    String? breakEnd,
    int? slotDurationMinutes,
    String? nextAvailableSlot,
    List<String>? workingDays,
  }) {
    return DoctorAvailabilityConfig(
      status: status ?? this.status,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      nextAvailableSlot: nextAvailableSlot ?? this.nextAvailableSlot,
      workingDays: workingDays ?? this.workingDays,
    );
  }
}
