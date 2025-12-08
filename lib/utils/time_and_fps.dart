/// WORKING COPY — FIXED FOR iOS NULL FPS ISSUE
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart'; // for listEquals
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pothole_detection_app/res/constants.dart';
import 'package:pothole_detection_app/view/home_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/detected_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/line_counter_data_model.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector_painter.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/segmented_object.dart';

import '../main.dart';
import '../theme/cubit/theme_cubit.dart';

// Combined result model for all 4 streams
class CombinedStreamResults {
  final List<DetectedObject?>? detectionResult;
  final List<SegmentedObject?>? segmentationResult;
  final double inferenceTime;
  final double fpsRate;
  final LineCounterDataModel? countingResult;

  CombinedStreamResults({
    this.detectionResult,
    this.segmentationResult,
    required this.inferenceTime,
    required this.fpsRate,
    this.countingResult,
  });
}

class TimeAndFps extends StatelessWidget {
  TimeAndFps({
    this.orientation,
    this.inferenceTimeStream,
    this.fpsRateStream,
    this.detectionResultStream,
    this.segmentationResultStream,
    this.countingResultStream,
    super.key,
  });

  String? orientation;
  Stream<double>? inferenceTimeStream;
  Stream<double>? fpsRateStream;
  Stream<List<DetectedObject?>?>? detectionResultStream;
  Stream<List<SegmentedObject?>?>? segmentationResultStream;
  Stream<LineCounterDataModel?>? countingResultStream;
  var topLabels;

  /// ✅ Helper to make sure the stream always starts with a safe initial value
  Stream<double> safeStream(Stream<double>? stream, double initial) {
    return (stream ?? Stream.value(initial)).startWith(initial).distinct();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>>? lastTransformedListDetection;
    List<Map<String, dynamic>>? lastTransformedListSegmentation;

    /// ✅ Make streams safe with non-null starting values
    inferenceTimeStream = safeStream(inferenceTimeStream, 0.0);
    fpsRateStream = safeStream(fpsRateStream, 0.0);

    if ((detectionResultStream != null || segmentationResultStream != null) &&
        inferenceTimeStream != null &&
        fpsRateStream != null) {
      // Always create a counting stream - starts with null and switches when countingResultStream becomes available
      Stream<LineCounterDataModel?> countingStream =
          countingResultStream?.startWith(null) ??
          Stream.value(null).asBroadcastStream();
      LineCounterDataModel? lastCountingResult;
      if (prefs.chosenModelMode == "Detection" &&
          detectionResultStream != null) {
        // Combine all 4 streams for Detection mode - this will always run
        Rx.combineLatest4(
          detectionResultStream!,
          inferenceTimeStream!,
          fpsRateStream!,
          countingStream,
          (
            List<DetectedObject?>? detections,
            double inferenceTime,
            double fpsRate,
            LineCounterDataModel? counting,
          ) {
            debugPrint(
              "Combining streams for Detection mode Counting: $counting",
            );
            return CombinedStreamResults(
              detectionResult: detections,
              inferenceTime: inferenceTime,
              fpsRate: fpsRate,
              countingResult: counting,
            );
          },
        ).listen((streamResults) {
          final labelCount = <String, int>{};

          // Handle potential null detectionResult
          if (streamResults.detectionResult != null) {
            for (final item in streamResults.detectionResult!) {
              if (item != null) {
                labelCount[item.label] = (labelCount[item.label] ?? 0) + 1;
              }
            }
          }

          // Get the top labels sorted by their occurrence
          topLabels =
              labelCount.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

          // Convert the list of MapEntry to a Map
          Map<String, int> map = Map.fromEntries(topLabels);

          // Transform the map to the desired format
          List<Map<String, dynamic>> transformedList =
              map.entries.map((entry) {
                return {"label": entry.key, "count": entry.value};
              }).toList();

          // Only proceed if transformedList has changed
          if (!listEquals(transformedList, lastTransformedListDetection)) {
            lastTransformedListDetection = List.from(transformedList);

            // Create a combined result object that includes counting data
            var combinedResult = DetectionStreamResults(
              detectionResult: streamResults.detectionResult,
              inferenceTime: streamResults.inferenceTime,
              fpsRate: streamResults.fpsRate,
            );

            detectionStreamResultsController.add(combinedResult);

            if (streamResults.countingResult != null &&
                streamResults.countingResult != lastCountingResult) {
              lastCountingResult = streamResults.countingResult;
              lineCounterStreamResultsController.add(
                streamResults.countingResult!,
              );
            }

            if (activeWebSocket != null && isServerOn) {
              String currentTime = DateTime.now().toString();

              // Include counting data in WebSocket message
              Map<String, dynamic> data = {
                "timestamp": currentTime,
                "detections": transformedList,
                "inferenceTime": streamResults.inferenceTime,
                "fpsRate": streamResults.fpsRate,
                "modelName":
                    prefs.chosenModelName != ""
                        ? prefs.chosenModelName
                        : initialModelName,
                "modelMode": "Detection",
              };

              // Add counting data if available
              if (streamResults.countingResult != null) {
                data["countingData"] = {
                  "lineCounterStatsLabel":
                      streamResults.countingResult!.lineCounterStatsLabel,
                  "labelsIn": streamResults.countingResult!.labelsIn,
                  "labelsOut": streamResults.countingResult!.labelsOut,
                };
              }

              activeWebSocket!.add(jsonEncode(data));
            }
          }

          print(
            "Detection: ${streamResults.detectionResult?.length ?? 0} objects, "
            "Inference: ${streamResults.inferenceTime}ms, "
            "FPS: ${streamResults.fpsRate}, "
            "Counting: ${streamResults.countingResult != null ? 'Active' : 'Inactive'}",
          );
        });
      } else if (prefs.chosenModelMode == "Segmentation" &&
          segmentationResultStream != null) {
        // Combine all 4 streams for Segmentation mode - this will always run
        Rx.combineLatest4(
          segmentationResultStream!,
          inferenceTimeStream!,
          fpsRateStream!,
          countingStream,
          (
            List<SegmentedObject?>? segmentations,
            double inferenceTime,
            double fpsRate,
            LineCounterDataModel? counting,
          ) {
            return CombinedStreamResults(
              segmentationResult: segmentations,
              inferenceTime: inferenceTime,
              fpsRate: fpsRate,
              countingResult: counting,
            );
          },
        ).listen((streamResults) {
          final labelCount = <String, int>{};

          // Handle potential null segmentationResult
          if (streamResults.segmentationResult != null) {
            for (final item in streamResults.segmentationResult!) {
              if (item != null) {
                labelCount[item.label] = (labelCount[item.label] ?? 0) + 1;
              }
            }
          }

          // Get the top labels sorted by their occurrence
          topLabels =
              labelCount.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

          // Convert the list of MapEntry to a Map
          Map<String, int> map = Map.fromEntries(topLabels);

          // Transform the map to the desired format
          List<Map<String, dynamic>> transformedList =
              map.entries.map((entry) {
                return {"label": entry.key, "count": entry.value};
              }).toList();

          // Only proceed if transformedList has changed
          if (!listEquals(transformedList, lastTransformedListSegmentation)) {
            lastTransformedListSegmentation = List.from(transformedList);

            // Create a combined result object that includes counting data
            var combinedResult = SegmentationStreamResults(
              detectionResult: streamResults.segmentationResult,
              inferenceTime: streamResults.inferenceTime,
              fpsRate: streamResults.fpsRate,
            );

            segmentationStreamResultsController.add(combinedResult);

            if (streamResults.countingResult != null &&
                streamResults.countingResult != lastCountingResult) {
              lastCountingResult = streamResults.countingResult;
              lineCounterStreamResultsController.add(
                streamResults.countingResult!,
              );
            }

            if (activeWebSocket != null && isServerOn) {
              String currentTime = DateTime.now().toString();

              // Include counting data in WebSocket message
              Map<String, dynamic> data = {
                "timestamp": currentTime,
                "detections": transformedList,
                "inferenceTime": streamResults.inferenceTime,
                "fpsRate": streamResults.fpsRate,
                "modelName":
                    prefs.chosenModelName != ""
                        ? prefs.chosenModelName
                        : initialModelName,
                "modelMode": "Segmentation",
              };

              // Add counting data if available
              if (streamResults.countingResult != null) {
                data["countingData"] = {
                  "lineCounterStatsLabel":
                      streamResults.countingResult!.lineCounterStatsLabel,
                  "labelsIn": streamResults.countingResult!.labelsIn,
                  "labelsOut": streamResults.countingResult!.labelsOut,
                };
              }

              activeWebSocket!.add(jsonEncode(data));
            }
          }

          print(
            "Segmentation: ${streamResults.segmentationResult?.length ?? 0} objects, "
            "Inference: ${streamResults.inferenceTime}ms, "
            "FPS: ${streamResults.fpsRate}, "
            "Counting: ${streamResults.countingResult != null ? 'Active' : 'Inactive'}",
          );
        });
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ✅ Safe inference time display
          StreamBuilder<double?>(
            stream: inferenceTimeStream,
            builder: (context, snapshot) {
              final inferenceValue = snapshot.data ?? 0.0;
              return Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  SizedBox(width: 4.w),
                  SizedBox(
                    width: 60.w,
                    child: Text(
                      '${inferenceValue.toStringAsFixed(0)} ms',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),

          /// ✅ Safe FPS display (no null on iOS restart)
          StreamBuilder<double?>(
            stream: fpsRateStream,
            builder: (context, snapshot) {
              final fpsValue = snapshot.data ?? 0.0;
              return Row(
                children: [
                  const Icon(Icons.speed, color: Colors.white),
                  SizedBox(width: 4.w),
                  SizedBox(
                    width: 60.w,
                    child: Text(
                      '${fpsValue.toStringAsFixed(1)} fps',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
