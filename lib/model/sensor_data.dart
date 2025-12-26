class SensorData {
  final int? id;

  /// Timestamp in microseconds (sensor time)
  final int timestampUs;

  /// Accelerometer (m/s²)
  final double accelX;
  final double accelY;
  final double accelZ;

  /// Gyroscope (rad/s)
  final double gyroX;
  final double gyroY;
  final double gyroZ;

  /// GPS (optional – may be null if not available)
  final double? latitude;
  final double? longitude;

  /// Speed in km/h (optional)
  final double? speedKmh;

  SensorData({
    this.id,
    required this.timestampUs,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    this.latitude,
    this.longitude,
    this.speedKmh,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp_us': timestampUs,
      'accel_x': accelX,
      'accel_y': accelY,
      'accel_z': accelZ,
      'gyro_x': gyroX,
      'gyro_y': gyroY,
      'gyro_z': gyroZ,
      'latitude': latitude,
      'longitude': longitude,
      'speed_kmh': speedKmh,
    };
  }

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      id: map['id'],
      timestampUs: map['timestamp_us'],
      accelX: (map['accel_x'] as num).toDouble(),
      accelY: (map['accel_y'] as num).toDouble(),
      accelZ: (map['accel_z'] as num).toDouble(),
      gyroX: (map['gyro_x'] as num).toDouble(),
      gyroY: (map['gyro_y'] as num).toDouble(),
      gyroZ: (map['gyro_z'] as num).toDouble(),
      latitude:
          map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude:
          map['longitude'] != null
              ? (map['longitude'] as num).toDouble()
              : null,
      speedKmh:
          map['speed_kmh'] != null
              ? (map['speed_kmh'] as num).toDouble()
              : null,
    );
  }
}
