import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:pothole_detection_app/utils/location.dart';
import 'package:pothole_detection_app/utils/time_and_fps.dart';
import 'package:pothole_detection_app/view/report_preview_view.dart';
import 'package:pothole_detection_app/view/widgets/custom_widget.dart';
import 'package:pothole_detection_app/view/widgets/speedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector.dart';
import '../components/custom_widgets.dart';

class BuildMethods {
  List<Map<String, dynamic>> cameraList = [];

  Widget buildTimeAndFps({
    required String orientation,
    required ObjectDetector objectDetector,
    Stream<double>? inferenceTimeStream,
    Stream<double>? fpsRateStream,
  }) {
    return Positioned(
      top:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 15.h
              : null,
      bottom:
          (orientation == 'landscapeRight' || orientation == 'landscapeLeft')
              ? kBottomNavigationBarHeight + 40.h
              : null,
      left: (orientation == 'landscapeLeft') ? 5.w : null,
      right:
          (orientation == 'landscapeRight')
              ? 5.w
              : (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 15.w
              : null,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: TimeAndFps(
          // orientation: orientation,
          inferenceTimeStream: inferenceTimeStream,
          fpsRateStream: fpsRateStream,
          detectionResultStream: objectDetector.detectionResultStream,
          segmentationResultStream: objectDetector.segmentationResultStream,
          countingResultStream: objectDetector.lineCounterResultStream,
        ),
      ),
    );
  }

  Widget buildSettingsButton({
    required String orientation,
    required VoidCallback onSettingsButtonPressed,
  }) {
    return Positioned(
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 130.h
              : 80.h,
      left: (orientation == 'landscapeRight') ? 70.w : null,
      right:
          (orientation == 'landscapeLeft')
              ? 70.w
              : (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 20.w
              : null,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: CircularIconButton(
          onPressed: onSettingsButtonPressed,
          activeIcon: 'act_tuning_icn.png',
          inActiveIcon: 'tuning_icn.png',
        ),
      ),
    );
  }

  Widget buildTrackAndCountButton({
    required String orientation,
    required VoidCallback onTrackAndCountButtonPressed,
  }) {
    return Positioned(
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 280.h
              : (orientation == 'landscapeRight')
              ? 80.h
              : 80.h,
      right:
          (orientation == 'landscapeRight')
              ? 115.w
              : (orientation == 'landscapeLeft')
              ? 220.w
              : 20.w,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: CircularIconButton(
          onPressed: onTrackAndCountButtonPressed,
          activeIcon: 'object_tracking.png',
          inActiveIcon: 'object_tracking.png',
        ),
      ),
    );
  }

  Widget buildMetricsCard({
    required BuildContext context,
    required String orientation,
    required Stream<LocationUpdate> locationStream,
    required Stream<double>? inferenceTimeStream,
    required Stream<double>? fpsRateStream,
    required Stream<double> roughnessStream,
    required AccelerometerEvent? accelerometerEvent,
    required GyroscopeEvent? gyroscopeEvent,
  }) {
    return Positioned(
      left:
          (orientation == 'landscapeRight')
              ? 80.w
              : (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 20.w
              : null,
      right: (orientation == 'landscapeLeft') ? 80.w : null,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: 118.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportPreviewView(),
                                ),
                              );
                            },
                            icon: Image.asset(
                              'assets/icons/stop_icon.png',
                              height: 28.h,
                              width: 28.w,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Color(0xFF16A34A),
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<LocationUpdate>(
                      stream: locationStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Column(
                          children: [
                            SizedBox(height: 6.h),
                            DataBrick(
                              text: "Lat: ${snapshot.data!.position.latitude}",
                              icon: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            DataBrick(
                              text: "Lon: ${snapshot.data!.position.longitude}",
                              icon: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            DataBrick(
                              text:
                                  "${(snapshot.data!.distance / 1000).toStringAsFixed(2)} Km",
                              icon: Icon(
                                Icons.route,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            DataBrick(
                              text:
                                  "${snapshot.data!.speedKmh.toStringAsFixed(1)} Km/h",
                              icon: Speedometer(speed: snapshot.data!.speedKmh),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 6.h),
                    StreamBuilder<double>(
                      stream: roughnessStream,
                      builder: (context, snapshot) {
                        double rmsValue = snapshot.data ?? 0.0;
                        return DataBrick(
                          text: rmsValue.toStringAsFixed(3),
                          icon: Image.asset(
                            "assets/icons/road.png",
                            height: 24,
                            width: 24,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 6.h),
                    StreamBuilder<double?>(
                      stream: inferenceTimeStream,
                      builder: (context, snapshot) {
                        final inferenceValue = snapshot.data ?? 0.0;
                        return DataBrick(
                          text: '${inferenceValue.toStringAsFixed(0)} ms',
                          icon: Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 6.h),
                    StreamBuilder<double?>(
                      stream: fpsRateStream,
                      builder: (context, snapshot) {
                        final fpsValue = snapshot.data ?? 0.0;
                        return DataBrick(
                          text: "${fpsValue.toStringAsFixed(1)} fps",
                          icon: Icon(
                            Icons.speed,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                ///Accelorometer Column
                Column(
                  children: [
                    SizedBox(
                      width: 90.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Acce",
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 20,
                            ),
                            softWrap: true,
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Color(0xFF16A34A),
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    DataBrick(
                      minWidth: 80,
                      text: (accelerometerEvent?.x ?? 0).toStringAsFixed(1),
                      icon: Text(
                        "X",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    DataBrick(
                      minWidth: 80,
                      text: (accelerometerEvent?.y ?? 0).toStringAsFixed(1),
                      icon: Text(
                        "Y",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    DataBrick(
                      minWidth: 80,
                      text: (accelerometerEvent?.z ?? 0).toStringAsFixed(1),
                      icon: Text(
                        "Z",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),

                ///Gyrometer Column
                Column(
                  children: [
                    SizedBox(
                      width: 90.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gyro",
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 20,
                            ),
                            softWrap: true,
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Color(0xFF16A34A),
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    DataBrick(
                      minWidth: 80,
                      text: (gyroscopeEvent?.x ?? 0).toStringAsFixed(1),
                      icon: Text(
                        "X",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    DataBrick(
                      minWidth: 80,
                      text: (gyroscopeEvent?.y ?? 0).toStringAsFixed(1),
                      icon: Text(
                        "Y",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    DataBrick(
                      minWidth: 80,
                      text: (gyroscopeEvent?.z ?? 0).toStringAsFixed(1),
                      icon: Text(
                        "Z",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
