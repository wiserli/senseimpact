import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole_detection_app/db/pothole_data_model.dart';
import 'package:pothole_detection_app/model/potholes.dart';
import 'package:pothole_detection_app/utils/indicators.dart';
import 'package:pothole_detection_app/utils/location.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/detected_object.dart';
import "package:yaml/yaml.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../res/constants.dart';

Future<String> copy({required String assetPath, String? folderName}) async {
  final String path;
  String folderPath;
  if (folderName == null || folderName == "" || folderName.isEmpty) {
    folderPath = "default";
  } else {
    folderPath = folderName;
  }
  if (Platform.isAndroid) {
    path =
        '${(await getApplicationCacheDirectory()).path}/$folderPath/$assetPath';
  } else {
    path =
        '${(await getApplicationDocumentsDirectory()).path}/$folderPath/$assetPath';
  }
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
  }
  print('file.path is ${file.path}');
  return file.path;
}

// This functions reads the yaml file from local storage and give the values
Future<int> readMetadataYamlImageSize(String filePath) async {
  int imageSize = initialInputSize;
  await readFile(filePath).then((contents) {
    var yamlDoc = loadYamlDocument(contents);
    String desc = yamlDoc.contents.value['description'];
    imageSize = yamlDoc.contents.value['imgsz'][0];
  });
  return imageSize;
}

Future<String> readFile(String filePath) async {
  try {
    File file = File(filePath);
    // Read the file
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    // Error reading the file
    print("Error reading file: $e");
    return 'NULL';
  }
}

Future<void> onPotholeDetected(
  LocationUpdate location,
  int severity,
  String imagePath,
) async {
  DateTime? lastSaved;
  final now = DateTime.now();
  if (lastSaved != null && now.difference(lastSaved).inSeconds < 5) {
    return; // debounce
  }
  final event = PotholeEvent(
    latitude: location.position.latitude,
    longitude: location.position.longitude,
    speedKmh: location.speedKmh,
    severity: severity,
    imagePath: imagePath,
    timestamp: now,
  );
  await PotholeDatabase.instance.insertPothole(event);
  lastSaved = now;

  CustomSnackBar().SnackBarMessage("Pothole detected and saved!");
}

void checkForPersonDetection(
  List<DetectedObject?>? detections,
  Stream<LocationUpdate> locationStream,
  Set<int> detectedPersonIds,
) async {
  if (detections == null || detections.isEmpty) {
    // Clear tracked IDs when no detections
    detectedPersonIds.clear();
    return;
  }

  // Get current location
  LocationUpdate? currentLocation;
  try {
    currentLocation = await locationStream.first;
  } catch (e) {
    debugPrint('Could not get location: $e');
    return;
  }

  // Check each detection
  for (final detection in detections) {
    if (detection == null) continue;

    // Check if it's a person (adjust label name based on your model)
    if (detection.label.toLowerCase() == 'person') {
      // Use tracking ID if available, otherwise use a hash of the bounding box
      final detectionId =
          detection.trackingId ??
          '${detection.boundingBox.left}_${detection.boundingBox.top}'.hashCode;

      // Only save if we haven't saved this person recently
      if (!detectedPersonIds.contains(detectionId)) {
        detectedPersonIds.add(detectionId);

        // Capture screenshot
        final imagePath =
            'test_pothole_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Calculate severity based on confidence (example)
        final severity = (detection.confidence * 10).round();

        // Save to database
        await onPotholeDetected(currentLocation, severity, imagePath);

        // Remove from tracked after 10 seconds to allow re-detection
        Future.delayed(const Duration(seconds: 10), () {
          detectedPersonIds.remove(detectionId);
        });
      }
    }
  }
}
