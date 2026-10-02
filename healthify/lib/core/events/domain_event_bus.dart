import 'dart:async';
import '../enums/domain_enums.dart';
import '../models/domain_event.dart';
import '../models/notification_model.dart';
import '../provider/repository_provider.dart';

/// Central In-Memory Domain Event Bus for Medrix Frontend Simulation.
/// Publishes domain events locally and automatically routes notifications to
/// patient and hospital audiences without any backend or WebSocket dependency.
class DomainEventBus {
  static final DomainEventBus instance = DomainEventBus._internal();
  factory DomainEventBus() => instance;
  DomainEventBus._internal();

  final _controller = StreamController<DomainEvent>.broadcast();

  Stream<DomainEvent> get stream => _controller.stream;

  Stream<DomainEvent> onType(String eventType) {
    return _controller.stream.where((e) => e.eventType == eventType);
  }

  /// Publishes a domain event locally and triggers audience notifications
  void publish(DomainEvent event) {
    _controller.add(event);
    _handleNotificationRouting(event);
  }

  /// Handles automatic in-memory notification creation for patient and hospital audiences
  void _handleNotificationRouting(DomainEvent event) {
    final notificationRepo = RepositoryContainer.instance.notificationRepository;
    final now = DateTime.now();

    switch (event.eventType) {
      case 'AppointmentCreated':
        final patientId = event.payload['patientId'] ?? 'PAT-8842';
        final doctorName = event.payload['doctorName'] ?? 'Doctor';

        // Patient Notification
        notificationRepo.createNotification(
          NotificationRecord(
            id: 'NOTIF-${now.millisecondsSinceEpoch}',
            hospitalId: event.hospitalId,
            recipientId: patientId,
            recipientRole: UserRole.patient,
            type: NotificationType.patientAppointmentReminder,
            title: 'Appointment Confirmed',
            message: 'Your appointment with $doctorName has been scheduled successfully.',
            priority: NotificationPriority.medium,
            status: NotificationStatus.unread,
            createdAt: now,
          ),
        );

        // Hospital Staff Notification
        notificationRepo.createNotification(
          NotificationRecord(
            id: 'NOTIF-${now.millisecondsSinceEpoch + 1}',
            hospitalId: event.hospitalId,
            recipientId: 'STAFF_BROADCAST',
            recipientRole: UserRole.receptionist,
            type: NotificationType.appointmentReminder,
            title: 'New Appointment Booked',
            message: 'New patient appointment registered for $doctorName.',
            priority: NotificationPriority.medium,
            status: NotificationStatus.unread,
            createdAt: now,
          ),
        );
        break;

      case 'AppointmentCheckedIn':
        final patientId = event.payload['patientId'] ?? 'PAT-8842';

        // Patient Notification
        notificationRepo.createNotification(
          NotificationRecord(
            id: 'NOTIF-${now.millisecondsSinceEpoch}',
            hospitalId: event.hospitalId,
            recipientId: patientId,
            recipientRole: UserRole.patient,
            type: NotificationType.patientCheckedIn,
            title: 'Checked In',
            message: 'You are checked in. Please proceed to the waiting lounge.',
            priority: NotificationPriority.high,
            status: NotificationStatus.unread,
            createdAt: now,
          ),
        );
        break;

      case 'AppointmentCompleted':
        final patientId = event.payload['patientId'] ?? 'PAT-8842';

        notificationRepo.createNotification(
          NotificationRecord(
            id: 'NOTIF-${now.millisecondsSinceEpoch}',
            hospitalId: event.hospitalId,
            recipientId: patientId,
            recipientRole: UserRole.patient,
            type: NotificationType.appointmentReminder,
            title: 'Consultation Completed',
            message: 'Your consultation is complete. Thank you for visiting Medrix.',
            priority: NotificationPriority.low,
            status: NotificationStatus.unread,
            createdAt: now,
          ),
        );
        break;

      case 'ReportReleased':
        final patientId = event.payload['patientId'] ?? 'PAT-8842';
        final reportTitle = event.payload['title'] ?? 'Diagnostic Report';

        notificationRepo.createNotification(
          NotificationRecord(
            id: 'NOTIF-${now.millisecondsSinceEpoch}',
            hospitalId: event.hospitalId,
            recipientId: patientId,
            recipientRole: UserRole.patient,
            type: NotificationType.patientReportReleased,
            title: 'New Medical Report Available',
            message: 'Your verified report "$reportTitle" is now available in your records.',
            priority: NotificationPriority.high,
            status: NotificationStatus.unread,
            createdAt: now,
          ),
        );
        break;

      default:
        break;
    }
  }

  void dispose() {
    _controller.close();
  }
}
