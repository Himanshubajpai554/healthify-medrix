class AITelemetrySnapshot {
  final String id;
  final String hospitalId;
  final String metricName;
  final double metricValue;
  final DateTime timestamp;
  final String aiModelVersion;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AITelemetrySnapshot({
    required this.id,
    required this.hospitalId,
    required this.metricName,
    required this.metricValue,
    required this.timestamp,
    required this.aiModelVersion,
    this.payload = const {},
    required this.createdAt,
    required this.updatedAt,
  });
}
