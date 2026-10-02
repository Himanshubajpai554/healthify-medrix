class GeoLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime capturedAt;
  final String source; // 'GPS', 'IP', 'UserConfigured', 'Demo'
  final String addressLabel;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy = 10.0,
    required this.capturedAt,
    this.source = 'Demo',
    this.addressLabel = 'Medical District, New York, NY',
  });

  /// Default demonstration location (Downtown Manhattan Medical District)
  static GeoLocation defaultDemo() {
    return GeoLocation(
      latitude: 40.730610,
      longitude: -73.935242,
      accuracy: 5.0,
      capturedAt: DateTime.now(),
      source: 'Demo',
      addressLabel: 'Medical District, New York, NY',
    );
  }

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? capturedAt,
    String? source,
    String? addressLabel,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      capturedAt: capturedAt ?? this.capturedAt,
      source: source ?? this.source,
      addressLabel: addressLabel ?? this.addressLabel,
    );
  }
}
