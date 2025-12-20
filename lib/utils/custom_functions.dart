import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole_detection_app/db/pothole_data_model.dart';
import 'package:pothole_detection_app/model/potholes.dart';
import 'package:pothole_detection_app/utils/indicators.dart';
import 'package:pothole_detection_app/utils/location.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visionx/camera_preview/camera_preview.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/detected_object.dart';
import "package:yaml/yaml.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
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

Future<File> base64ToImageFile(
  String base64String, {
  String fileName = 'captured_image.jpg',
}) async {
  // Decode base64
  Uint8List bytes = base64Decode(base64String);

  // Get app directory
  final Directory dir = await getTemporaryDirectory();
  final String filePath = '${dir.path}/$fileName';

  // Write file
  final File file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);

  return file;
}

/// Crop [cameraFrameFile] to match the size of [screenshotFile]
Future<File> cropCameraFrameToMatchScreenshot({
  required File cameraFrameFile,
  required File screenshotFile,
  required String outputPath,
}) async {
  // Read bytes
  Uint8List cameraBytes = await cameraFrameFile.readAsBytes();
  Uint8List screenshotBytes = await screenshotFile.readAsBytes();

  // Decode images
  img.Image? cameraImg = img.decodeImage(cameraBytes);
  img.Image? screenshotImg = img.decodeImage(screenshotBytes);

  if (cameraImg == null || screenshotImg == null) {
    throw Exception('Failed to decode images');
  }

  // Get target size from screenshot
  int targetWidth = screenshotImg.width;
  int targetHeight = screenshotImg.height;

  // Crop camera frame (center crop if needed)
  int offsetX = (cameraImg.width - targetWidth) ~/ 2;
  int offsetY = (cameraImg.height - targetHeight) ~/ 2;

  // Ensure offsets are >= 0
  offsetX = offsetX < 0 ? 0 : offsetX;
  offsetY = offsetY < 0 ? 0 : offsetY;

  img.Image croppedCamera = img.copyCrop(
    cameraImg,
    x: offsetX,
    y: offsetY,
    width: targetWidth > cameraImg.width ? cameraImg.width : targetWidth,
    height: targetHeight > cameraImg.height ? cameraImg.height : targetHeight,
  );

  // Encode to JPEG and save
  Uint8List croppedBytes = Uint8List.fromList(
    img.encodeJpg(croppedCamera, quality: 90),
  );
  File outputFile = File(outputPath);
  await outputFile.writeAsBytes(croppedBytes, flush: true);

  return outputFile;
}

/// This function stacks croppedCameraFrame on screenshotFile
Future<File> stackScreenshotOnCroppedFrameAndRotateImage({
  required File croppedCameraFrame,
  required File screenshotFile,
  required String outputPath,
}) async {
  // Load images using the 'image' package
  final img.Image croppedImg =
      img.decodeImage(await croppedCameraFrame.readAsBytes())!;

  final img.Image screenshotImg =
      img.decodeImage(await screenshotFile.readAsBytes())!;

  // Create a copy of cropped frame as base
  final img.Image mergedImg = img.copyResize(
    croppedImg,
    width: croppedImg.width,
    height: croppedImg.height,
  );

  // Calculate position to overlay screenshot (top-left by default)
  // Adjust these values based on your needs (e.g., center, specific offset)
  final int dstX = 10;
  final int dstY = 10;

  // Composite screenshot onto cropped frame
  img.compositeImage(
    mergedImg,
    screenshotImg,
    dstX: dstX,
    dstY: dstY,
    blend: img.BlendMode.alpha, // Enable alpha blending for transparency
  );

  // Rotate the merged image by -π/2 (90 degrees counterclockwise)
  final img.Image rotatedImg = img.copyRotate(mergedImg, angle: -90);

  // Encode and save merged image
  final mergedBytes = img.encodeJpg(rotatedImg, quality: 95);
  final mergedFile = File(outputPath);
  await mergedFile.writeAsBytes(mergedBytes);

  return mergedFile;
}

// TOP-LEVEL ISOLATE FUNCTION FOR PERSON DETECTION PROCESSING converting to screenshot
// Future<Map<String, dynamic>> _personDetectionIsolateProcessor(
//   Map<String, dynamic> params,
// )
// async {
//   final List<DetectedObject?> detections = params['detections'];
//   final LocationUpdate? currentLocation = params['location'];
//   final int detectionId = params['detectionId'];
//   final int timestamp = params['timestamp'];
//   final String tempDirPath = params['tempDirPath'];
//   final String docDirPath = params['docDirPath'];
//   final String screenshotPath = params['screenshotPath'];
//   final String cameraBase64 = params['cameraBase64'];
//
//   try {
//     // All heavy processing in isolate
//     final tempDir = Directory(tempDirPath);
//     final cameraFrameFileName = 'pothole_cameraFrame_$timestamp.jpg';
//
//     // Convert base64 to file in isolate
//     final Uint8List bytes = base64Decode(cameraBase64);
//     final cameraFrameFile = File('$tempDirPath/$cameraFrameFileName');
//     await cameraFrameFile.writeAsBytes(bytes, flush: true);
//
//     final screenshotFile = File(screenshotPath);
//     final croppedCameraFrame = await cropCameraFrameToMatchScreenshot(
//       cameraFrameFile: cameraFrameFile,
//       screenshotFile: screenshotFile,
//       outputPath: '$tempDirPath/cropped_$cameraFrameFileName',
//     );
//
//     final mergedTempFile = await stackScreenshotOnCroppedFrameAndRotateImage(
//       croppedCameraFrame: croppedCameraFrame,
//       screenshotFile: screenshotFile,
//       outputPath: '$tempDirPath/merged_$timestamp.jpg',
//     );
//
//     // Move to documents directory
//     final docDir = Directory(docDirPath);
//     final mergedFileName = 'pothole_${timestamp}.jpg';
//     final finalMergedFile = await mergedTempFile.copy(
//       '${docDir.path}/$mergedFileName',
//     );
//
//     // Cleanup temp files
//     await Future.wait([
//       if (cameraFrameFile.existsSync()) cameraFrameFile.delete(),
//       if (croppedCameraFrame.existsSync()) croppedCameraFrame.delete(),
//       if (mergedTempFile.existsSync()) mergedTempFile.delete(),
//     ]);
//
//     // RETURN result for main thread
//     return {
//       'success': true,
//       'path': finalMergedFile.path,
//       'severity': (detections.first!.confidence * 10).round(),
//     };
//   } catch (e) {
//     return {'success': false, 'error': e.toString()};
//   }
// }

// Top-LEVEL ISOLATE FUNCTION FOR PERSON DETECTION and storing raw pothole image
Future<Map<String, dynamic>> _personDetectionIsolateProcessor(
  Map<String, dynamic> params,
) async {
  final List<DetectedObject?> detections = params['detections'];
  final int timestamp = params['timestamp'];
  final String tempDirPath = params['tempDirPath'];
  final String docDirPath = params['docDirPath'];
  final String cameraBase64 = params['cameraBase64'];

  try {
    // All heavy processing in isolate
    final cameraFrameFileName = 'pothole_cameraFrame_$timestamp.jpg';

    // Convert base64 to file in isolate
    final Uint8List bytes = base64Decode(cameraBase64);
    final cameraFrameFile = File('$tempDirPath/$cameraFrameFileName');
    await cameraFrameFile.writeAsBytes(bytes, flush: true);

    // Move to documents directory
    final finalImageFile = await cameraFrameFile.copy(
      '$docDirPath/$cameraFrameFileName',
    );

    // Cleanup temp files
    await Future.wait([
      if (cameraFrameFile.existsSync()) cameraFrameFile.delete(),
    ]);

    // RETURN result for main thread
    return {
      'success': true,
      'path': finalImageFile.path,
      'severity': (detections.first!.confidence * 10).round(),
    };
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

// // Main Function for checking the person label in detection
// void checkForPersonDetection(
//   List<DetectedObject?>? detections,
//   Stream<LocationUpdate> locationStream,
//   Set<int> detectedPersonIds,
//   ScreenshotController screenshotController,
//   VisionxYoloCameraController cameraController,
// )
// async {
//   if (detections == null || detections.isEmpty) {
//     // Clear tracked IDs when no detections
//     detectedPersonIds.clear();
//     return;
//   }
//
//   // Get current location
//   LocationUpdate? currentLocation;
//   try {
//     currentLocation = await locationStream.first;
//   } catch (e) {
//     debugPrint('Could not get location: $e');
//     return;
//   }
//
//   // Check each detection
//   for (final detection in detections) {
//     if (detection == null) continue;
//
//     // Check if it's a person (adjust label name based on your model)
//     if (detection.label.toLowerCase() == 'person') {
//       // Use tracking ID if available, otherwise use a hash of the bounding box
//       final detectionId =
//           detection.trackingId ??
//           '${detection.boundingBox.left}_${detection.boundingBox.top}'.hashCode;
//
//       // Only save if we haven't saved this person recently
//       if (!detectedPersonIds.contains(detectionId)) {
//         detectedPersonIds.add(detectionId);
//
//         final tempDir = await getTemporaryDirectory();
//         final timestamp = DateTime.now().millisecondsSinceEpoch;
//         final screenshotFileName = 'pothole_screenshot_$timestamp.jpg';
//
//         // QUICK MAIN THREAD WORK ONLY (~100ms)
//         final screenshotImagePath =
//             await screenshotController.captureAndSave(
//               tempDir.path,
//               fileName: screenshotFileName,
//             ) ??
//             '${tempDir.path}/$screenshotFileName';
//
//         final cameraFrameBase64 = await cameraController.takePicture();
//         if (cameraFrameBase64 == null) continue;
//
//         // OFFLOAD HEAVY WORK TO ISOLATE (~1-2s, non-blocking)
//         final params = {
//           'detections': [detection],
//           'location': currentLocation,
//           'detectionId': detectionId,
//           'timestamp': timestamp,
//           'tempDirPath': tempDir.path,
//           'docDirPath': (await getApplicationDocumentsDirectory()).path,
//           'screenshotPath': screenshotImagePath,
//           'cameraBase64': cameraFrameBase64,
//         };
//
//         // Get result from isolate
//         final result = await compute(_personDetectionIsolateProcessor, params);
//
//         // Call onPotholeDetected WITHOUT await (it's void)
//         if (result['success'] == true) {
//           onPotholeDetected(
//             currentLocation,
//             result['severity'] as int,
//             result['path'] as String,
//           );
//         } else {
//           debugPrint('Isolate error: ${result['error']}');
//         }
//
//         // Cleanup screenshot
//         final screenshotFile = File(screenshotImagePath);
//         if (screenshotFile.existsSync()) screenshotFile.deleteSync();
//
//         // Allow re-detection after 10 seconds
//         Future.delayed(const Duration(seconds: 10), () {
//           detectedPersonIds.remove(detectionId);
//         });
//       }
//     }
//   }
// }

// Main Function for checking the person label in detection

/// Main Function for checking the person label in detection and storing raw pothole image
void checkForPersonDetection(
  List<DetectedObject?>? detections,
  Stream<LocationUpdate> locationStream,
  Set<int> detectedPersonIds,
  ScreenshotController screenshotController,
  VisionxYoloCameraController cameraController,
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
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final cameraFrameBase64 = await cameraController.takePicture();
        if (cameraFrameBase64 == null) continue;

        // OFFLOAD HEAVY WORK TO ISOLATE (~1-2s, non-blocking)
        final params = {
          'detections': [detection],
          'timestamp': timestamp,
          'tempDirPath': (await getTemporaryDirectory()).path,
          'docDirPath': (await getApplicationDocumentsDirectory()).path,
          'cameraBase64': cameraFrameBase64,
        };

        // Get result from isolate
        final result = await compute(_personDetectionIsolateProcessor, params);

        // Call onPotholeDetected WITHOUT await (it's void)
        if (result['success'] == true) {
          onPotholeDetected(
            currentLocation,
            result['severity'] as int,
            result['path'] as String,
          );
        } else {
          debugPrint('Isolate error: ${result['error']}');
        }

        // Allow re-detection after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          detectedPersonIds.remove(detectionId);
        });
      }
    }
  }
}
