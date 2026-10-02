/// Conceptual Domain Event model for real-time WebSocket / SSE / In-Memory subscription stream
class DomainEvent {
  final String id;
  final String type; // e.g. 'EmergencyUpdated', 'BedUpdated', 'BloodUpdated', 'AppointmentCreated', 'ReportReleased'
  final String entityType;
  final String entityId;
  final String hospitalId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final String payloadReference;

  const DomainEvent({
    required this.id,
    required this.type,
    this.entityType = 'General',
    this.entityId = '',
    this.hospitalId = 'HOSP-101',
    String? aggregateId,
    this.payload = const {},
    required this.timestamp,
    this.payloadReference = '',
  });

  String get eventType => type;
  String get aggregateId => entityId.isNotEmpty ? entityId : id;
}
