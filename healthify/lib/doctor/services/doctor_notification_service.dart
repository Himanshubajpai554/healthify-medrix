import 'dart:async';

import '../models/notification_models.dart';

class DoctorNotificationService {
  static final DoctorNotificationService _instance =
      DoctorNotificationService._internal();

  factory DoctorNotificationService() {
    return _instance;
  }

  DoctorNotificationService._internal() {
    _initSampleData();
  }

  final _notificationsController =
      StreamController<List<DoctorNotificationFullModel>>.broadcast();

  Stream<List<DoctorNotificationFullModel>> get notificationsStream =>
      _notificationsController.stream;

  final List<DoctorNotificationFullModel> _notifications = [];
  final List<NotificationPreferencesModel> _preferences = [];

  void _initSampleData() {
    final now = DateTime.now();

    _notifications.addAll([
      DoctorNotificationFullModel(
        id: 'NOTIF-101',
        title: 'Emergency Case Assigned',
        shortDescription: 'Severe chest pain / Suspected Acute STEMI assigned to ER Bay 1.',
        fullDescription:
            'A critical patient has been assigned to ER Bay 1 with chief complaint of acute retrosternal chest pain radiating to left arm. ECG shows ST elevation in leads V1-V4.',
        category: NotificationCategory.emergency,
        priority: NotificationPriority.urgent,
        isRead: false,
        timestamp: now.subtract(const Duration(minutes: 8)),
        relatedEntityId: 'EMG-9021',
        relatedPatientId: 'P-1002',
        relatedPatientName: 'Rahul Sharma',
        targetRoute: '/doctor-emergency-cases',
        actionLabel: 'Open Case',
        auditCreated: now.subtract(const Duration(minutes: 9)),
        auditDelivered: now.subtract(const Duration(minutes: 8)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-102',
        title: 'Critical Laboratory Report Ready',
        shortDescription: 'Elevated Cardiac Troponin I report ready for review.',
        fullDescription:
            'STAT lab panel completed for Patient ID P-1002. High cardiac troponin I level observed (4.8 ng/mL, reference range < 0.04 ng/mL). Direct physician action recommended.',
        category: NotificationCategory.reports,
        priority: NotificationPriority.urgent,
        isRead: false,
        timestamp: now.subtract(const Duration(minutes: 25)),
        relatedEntityId: 'REP-401',
        relatedPatientId: 'P-1002',
        relatedPatientName: 'Rahul Sharma',
        targetRoute: '/doctor-reports',
        actionLabel: 'Open Report',
        auditCreated: now.subtract(const Duration(minutes: 26)),
        auditDelivered: now.subtract(const Duration(minutes: 25)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-103',
        title: 'Upcoming Appointment Reminder',
        shortDescription: 'Teleconsultation scheduled in 15 minutes.',
        fullDescription:
            'Follow-up cardiology consultation with Patient Ananya Verma scheduled for 10:30 AM via HD Telehealth Video link.',
        category: NotificationCategory.appointments,
        priority: NotificationPriority.important,
        isRead: false,
        timestamp: now.subtract(const Duration(minutes: 45)),
        relatedEntityId: 'APT-809',
        relatedPatientId: 'P-1004',
        relatedPatientName: 'Ananya Verma',
        targetRoute: '/doctor-appointments',
        actionLabel: 'Open Appointment',
        auditCreated: now.subtract(const Duration(minutes: 50)),
        auditDelivered: now.subtract(const Duration(minutes: 45)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-104',
        title: 'Patient Follow-up Due Today',
        shortDescription: 'Post-CABG 2-week recovery review check due.',
        fullDescription:
            'Patient Vikram Patel (Post-CABG Day 14) is scheduled for a routine wound healing assessment and anticoagulation dosage adjustment today.',
        category: NotificationCategory.patients,
        priority: NotificationPriority.important,
        isRead: false,
        timestamp: now.subtract(const Duration(hours: 2)),
        relatedEntityId: 'FLP-302',
        relatedPatientId: 'P-1001',
        relatedPatientName: 'Vikram Patel',
        targetRoute: '/doctor-patient-followups',
        actionLabel: 'Open Follow-up',
        auditCreated: now.subtract(const Duration(hours: 2, minutes: 5)),
        auditDelivered: now.subtract(const Duration(hours: 2)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-105',
        title: 'Prescription Renewal Requested',
        shortDescription: 'Refill request for Rosuvastatin 20mg.',
        fullDescription:
            'Patient Sunita Deshmukh requested a 30-day refill for Rosuvastatin 20mg once daily. Existing prescription expired on Sep 28.',
        category: NotificationCategory.prescriptions,
        priority: NotificationPriority.normal,
        isRead: false,
        timestamp: now.subtract(const Duration(hours: 4)),
        relatedEntityId: 'RX-701',
        relatedPatientId: 'P-1003',
        relatedPatientName: 'Sunita Deshmukh',
        targetRoute: '/doctor-prescriptions',
        actionLabel: 'Open Prescription',
        auditCreated: now.subtract(const Duration(hours: 4, minutes: 2)),
        auditDelivered: now.subtract(const Duration(hours: 4)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-106',
        title: 'Routine Echocardiogram Uploaded',
        shortDescription: 'Transthoracic 2D Echo results uploaded by Cardiology Imaging.',
        fullDescription:
            'Transthoracic echocardiogram DICOM study and clinical summary report uploaded for Patient Amit Joshi. LVEF estimated at 55%.',
        category: NotificationCategory.reports,
        priority: NotificationPriority.normal,
        isRead: false,
        timestamp: now.subtract(const Duration(hours: 6)),
        relatedEntityId: 'REP-389',
        relatedPatientId: 'P-1005',
        relatedPatientName: 'Amit Joshi',
        targetRoute: '/doctor-reports',
        actionLabel: 'Open Report',
        auditCreated: now.subtract(const Duration(hours: 6, minutes: 3)),
        auditDelivered: now.subtract(const Duration(hours: 6)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-107',
        title: 'Hospital Clinical Guidelines Updated',
        shortDescription: 'Updated Sepsis Screening & Management Protocols 2026.',
        fullDescription:
            'The Hospital Medical Board has published updated clinical protocol directives for early sepsis identification in outpatient and ER departments.',
        category: NotificationCategory.hospital,
        priority: NotificationPriority.normal,
        isRead: true,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        relatedEntityId: 'DOC-501',
        targetRoute: null,
        actionLabel: 'Read Notice',
        auditCreated: now.subtract(const Duration(days: 1, hours: 3)),
        auditDelivered: now.subtract(const Duration(days: 1, hours: 2)),
        auditRead: now.subtract(const Duration(hours: 18)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-108',
        title: 'System Security Sync Completed',
        shortDescription: 'EHR Access Log & Security Verification completed.',
        fullDescription:
            'Weekly automated security audit and EHR encryption key rotation completed with zero flags. All active clinical workspace logs verified.',
        category: NotificationCategory.system,
        priority: NotificationPriority.normal,
        isRead: true,
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        relatedEntityId: 'SYS-991',
        targetRoute: null,
        actionLabel: 'View Details',
        auditCreated: now.subtract(const Duration(days: 2, hours: 6)),
        auditDelivered: now.subtract(const Duration(days: 2, hours: 5)),
        auditRead: now.subtract(const Duration(days: 1, hours: 10)),
      ),
      DoctorNotificationFullModel(
        id: 'NOTIF-109',
        title: 'Patient Profile Updated',
        shortDescription: 'Allergy history updated for Priya Menon.',
        fullDescription:
            'Patient self-service portal / nurse intake updated allergy list: Penicillin added (Severe hives/anaphylaxis history).',
        category: NotificationCategory.patients,
        priority: NotificationPriority.important,
        isRead: true,
        timestamp: now.subtract(const Duration(days: 3)),
        relatedEntityId: 'P-1006',
        relatedPatientId: 'P-1006',
        relatedPatientName: 'Priya Menon',
        targetRoute: '/doctor-patients',
        actionLabel: 'Open Patient',
        auditCreated: now.subtract(const Duration(days: 3, minutes: 10)),
        auditDelivered: now.subtract(const Duration(days: 3)),
        auditRead: now.subtract(const Duration(days: 2)),
      ),
    ]);

    // Default notification channel preferences
    for (final cat in NotificationCategory.values) {
      if (cat == NotificationCategory.all || cat == NotificationCategory.unread) {
        continue;
      }
      _preferences.add(
        NotificationPreferencesModel(
          category: cat,
          inAppEnabled: true,
          pushEnabled: cat == NotificationCategory.emergency || cat == NotificationCategory.reports,
          emailEnabled: cat == NotificationCategory.hospital,
        ),
      );
    }
  }

  List<DoctorNotificationFullModel> getNotifications({
    NotificationCategory category = NotificationCategory.all,
    String searchQuery = '',
  }) {
    return _notifications.where((item) {
      // Category filter
      if (category == NotificationCategory.unread) {
        if (item.isRead) return false;
      } else if (category != NotificationCategory.all) {
        if (item.category != category) return false;
      }

      // Search query filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.shortDescription.toLowerCase().contains(q) ||
            item.fullDescription.toLowerCase().contains(q);
        final matchPatient = item.relatedPatientName?.toLowerCase().contains(q) ?? false;
        final matchEntity = item.relatedEntityId?.toLowerCase().contains(q) ?? false;

        return matchTitle || matchDesc || matchPatient || matchEntity;
      }

      return true;
    }).toList();
  }

  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  int getCategoryCount(NotificationCategory category) {
    if (category == NotificationCategory.all) return _notifications.length;
    if (category == NotificationCategory.unread) return getUnreadCount();
    return _notifications.where((n) => n.category == category).length;
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        auditRead: DateTime.now(),
      );
      _notificationsController.add(List.from(_notifications));
    }
  }

  void markAllNotificationsRead() {
    final now = DateTime.now();
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(
          isRead: true,
          auditRead: now,
        );
      }
    }
    _notificationsController.add(List.from(_notifications));
  }

  void dismissNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notificationsController.add(List.from(_notifications));
  }

  List<NotificationPreferencesModel> getPreferences() {
    return List.unmodifiable(_preferences);
  }

  void updatePreference(NotificationPreferencesModel updatedPref) {
    final index = _preferences.indexWhere((p) => p.category == updatedPref.category);
    if (index != -1) {
      _preferences[index] = updatedPref;
    }
  }

  void dispose() {
    _notificationsController.close();
  }
}
