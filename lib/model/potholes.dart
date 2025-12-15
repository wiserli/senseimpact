class PotholeEvent {
  final int? id;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final int severity; // 1–5
  final String imagePath; // optional snapshot
  final DateTime timestamp;

  PotholeEvent({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.severity,
    required this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'speed_kmh': speedKmh,
      'severity': severity,
      'image_path': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PotholeEvent.fromMap(Map<String, dynamic> map) {
    return PotholeEvent(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      speedKmh: map['speed_kmh'],
      severity: map['severity'],
      imagePath: map['image_path'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
