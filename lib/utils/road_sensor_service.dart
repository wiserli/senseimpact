import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pothole_detection_app/model/sensor_data.dart';
import 'package:pothole_detection_app/utils/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../db/road_sensor_db.dart';

class RoadSensorService {
  static const int samplingFrequencyHz = 100;
  static const Duration samplingInterval = Duration(
    microseconds: 1000000 ~/ samplingFrequencyHz,
  );

  static const int batchSize = 200;

  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;
  Timer? _samplerTimer;

  AccelerometerEvent? _latestAccel;
  GyroscopeEvent? _latestGyro;

  final List<SensorData> _batchBuffer = [];
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Initialize permissions
  Future<void> init() async {
    await Geolocator.requestPermission();
  }

  /// Start collecting data
  Future<void> start(Stream<LocationUpdate> locationStream) async {
    // Get current location
    LocationUpdate? currentLocation;
    try {
      currentLocation = await locationStream.first;
    } catch (e) {
      debugPrint('Could not get location: $e');
      return;
    }

    if (_isRecording) return;

    _accelSub = accelerometerEvents.listen((e) {
      _latestAccel = e;
    });

    _gyroSub = gyroscopeEvents.listen((e) {
      _latestGyro = e;
    });

    _samplerTimer = Timer.periodic(samplingInterval, (_) async {
      if (_latestAccel == null || _latestGyro == null) return;

      final ts = DateTime.now().microsecondsSinceEpoch;

      _batchBuffer.add(
        SensorData(
          timestampUs: ts,
          accelX: _latestAccel!.x,
          accelY: _latestAccel!.y,
          accelZ: _latestAccel!.z,
          gyroX: _latestGyro!.x,
          gyroY: _latestGyro!.y,
          gyroZ: _latestGyro!.z,
          latitude: currentLocation?.position.latitude,
          longitude: currentLocation?.position.longitude,
          speedKmh: currentLocation?.speedKmh,
        ),
      );

      // _batchBuffer.add(
      //
      //     {
      //   'timestamp_us': ts,
      //   'accel_x': _latestAccel!.x,
      //   'accel_y': _latestAccel!.y,
      //   'accel_z': _latestAccel!.z,
      //   'gyro_x': _latestGyro!.x,
      //   'gyro_y': _latestGyro!.y,
      //   'gyro_z': _latestGyro!.z,
      //   'latitude': currentLocation?.position.latitude,
      //   'longitude': currentLocation?.position.longitude,
      //   'speed': currentLocation?.speedKmh, // m/s
      // });

      if (_batchBuffer.length >= batchSize) {
        final data = List<SensorData>.from(_batchBuffer);
        _batchBuffer.clear();
        await RoadSensorDB.insertBatch(data);
      }
    });

    _isRecording = true;
  }

  /// Stop and flush remaining data
  Future<void> stop() async {
    if (!_isRecording) return;

    await _accelSub?.cancel();
    await _gyroSub?.cancel();
    _samplerTimer?.cancel();

    if (_batchBuffer.isNotEmpty) {
      await RoadSensorDB.insertBatch(_batchBuffer);
      _batchBuffer.clear();
    }

    _isRecording = false;
  }

  /// Cleanup
  Future<void> dispose() async {
    await stop();
  }
}
