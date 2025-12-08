import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_controller.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_preview.dart';
import 'package:visionx/visionx.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/line_counter_data_model.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_segmentor_painter.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/segmented_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/detected_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector_painter.dart';
import '../components/bottom_bar.dart';
import '../components/custom_widgets.dart';
import '../res/constants.dart';
import '../theme/cubit/theme_cubit.dart';
import '../utils/colors.dart';
import '../utils/time_and_fps.dart';

class BuildMethods {
  List<Map<String, dynamic>> cameraList = [];

  Widget buildCameraPreview({
    required String orientation,
    required ObjectDetector objectDetector,
    required VisionxYoloCameraController controller,
    required bool objectCountVisible,
  }) {
    return RepaintBoundary(
      child: VisionxYoloCameraPreview(
        orientation: orientation,
        predictor: objectDetector,
        controller: controller,
        onCameraCreated: () {},
        boundingBoxesColorList: bBoxColorList,
        bottom:
            (orientation == 'portraitUp' || orientation == 'portraitDown')
                ? kBottomNavigationBarHeight + 130.h
                : null,
        top:
            (orientation == 'landscapeRight')
                ? 220.h
                : (orientation == 'landscapeLeft')
                ? 180.h
                : null,
        left:
            (orientation == 'landscapeRight')
                ? -10.w
                : (orientation == 'landscapeLeft')
                ? 100.w
                : 20.w,
        right: (orientation == 'landscapeLeft') ? -65.w : null,
        icon: objectCountVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
        iconSize: 28,
        iconColor: Colors.white,
        textStyle: const TextStyle(color: Colors.white),
        isListVisible: objectCountVisible,
        showDetectionFromPlugin: true,
      ),
    );
  }



  Widget buildLogo({
    required String orientation,
    bool isColored = false,
    String? subtitle,
    bool isScoreCardView = false,
  }) {
    return isScoreCardView
        ? Transform.rotate(
          angle:
              (orientation == 'landscapeRight')
                  ? pi / 2
                  : (orientation == 'landscapeLeft')
                  ? -pi / 2
                  : 0,
          child:
              subtitle == null
                  ? Image.asset(
                    isColored
                        ? 'assets/icons/yolovx_logo.png'
                        : 'assets/icons/yolovx_logo_white_tr.png',
                    color:
                        !isColored
                            ? const Color.fromARGB(200, 255, 255, 255)
                            : null,
                    height:
                        (orientation == 'portraitUp' ||
                                orientation == 'portraitDown')
                            ? 46.h
                            : 36.h,
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        isColored
                            ? 'assets/icons/yolovx_logo.png'
                            : 'assets/icons/yolovx_logo_white_tr.png',
                        color:
                            !isColored
                                ? const Color.fromARGB(200, 255, 255, 255)
                                : null,
                        height:
                            (orientation == 'portraitUp' ||
                                    orientation == 'portraitDown')
                                ? 46.h
                                : 36.h,
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF979797),
                        ),
                      ),
                    ],
                  ),
        )
        : Positioned(
          top:
              (orientation == 'portraitUp' || orientation == 'portraitDown')
                  ? 48.h
                  : 100.h,
          left:
              (orientation == 'landscapeRight')
                  ? null
                  : (orientation == 'landscapeLeft')
                  ? 5.w
                  : 20.w,
          right: (orientation == 'landscapeRight') ? 5.w : null,
          child: Transform.rotate(
            angle:
                (orientation == 'landscapeRight')
                    ? pi / 2
                    : (orientation == 'landscapeLeft')
                    ? -pi / 2
                    : 0,
            child:
                subtitle == null
                    ? Image.asset(
                      isColored
                          ? 'assets/icons/yolovx_logo.png'
                          : 'assets/icons/yolovx_logo_white_tr.png',
                      color:
                          !isColored
                              ? const Color.fromARGB(200, 255, 255, 255)
                              : null,
                      height:
                          (orientation == 'portraitUp' ||
                                  orientation == 'portraitDown')
                              ? 46.h
                              : 36.h,
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          isColored
                              ? 'assets/icons/yolovx_logo.png'
                              : 'assets/icons/yolovx_logo_white_tr.png',
                          color:
                              !isColored
                                  ? const Color.fromARGB(200, 255, 255, 255)
                                  : null,
                          height:
                              (orientation == 'portraitUp' ||
                                      orientation == 'portraitDown')
                                  ? 46.h
                                  : 36.h,
                        ),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF979797),
                          ),
                        ),
                      ],
                    ),
          ),
        );
  }

  Widget buildServer({
    required String orientation,
    required VoidCallback onServerButtonPressed,
  }) {
    return Positioned(
      // bottom: (orientation == 'portraitUp' || orientation == 'portraitDown')
      //     ? 230.h
      //     : (orientation == 'landscapeRight')
      //         ? 80.h
      //         : 80.h,
      // left: (orientation == 'landscapeRight') ? 170.w : null,
      // right: (orientation == 'landscapeLeft')
      //     ? 170.w
      //     : (orientation == 'portraitUp' || orientation == 'portraitDown')
      //         ? 20.w
      //         : null,
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 180.h
              : (orientation == 'landscapeRight')
              ? 80.h
              : 80.h,
      left: (orientation == 'landscapeRight') ? 120.w : null,
      right:
          (orientation == 'landscapeLeft')
              ? 120.w
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
          onPressed: onServerButtonPressed,
          activeIcon: 'dashboard.png',
          inActiveIcon: 'dashboard.png',
        ),
      ),
    );
  }

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

  Widget buildGestureDetector({
    required String orientation,
    required bool objectCountVisible,
    required VoidCallback onToggle,
  }) {
    double? top = (orientation == 'landscapeRight') ? 210.h : null;
    double? bottom =
        (orientation == 'portraitUp' || orientation == 'portraitDown')
            ? kBottomNavigationBarHeight + 130.h
            : (orientation == 'landscapeLeft')
            ? 500.h
            : null;
    double? left =
        (orientation == 'landscapeRight')
            ? -5.w
            : (orientation == 'portraitUp' || orientation == 'portraitDown')
            ? 20.w
            : null;
    double? right = (orientation == 'landscapeLeft') ? -5.w : null;
    return Positioned(
      bottom: bottom,
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(color: Colors.transparent, width: 100, height: 100),
      ),
    );
  }

  ///
  Widget buildTotalCount({
    required String orientation,
    required bool objectCountVisible,
    required Stream<List<dynamic>?>? objectsDetectionStream,
    required VoidCallback onToggle,
  }) {
    double? top =
        (orientation == 'landscapeRight')
            ? 220.h
            : (orientation == 'landscapeLeft')
            ? 50.h
            : null;
    double? bottom =
        (orientation == 'portraitUp' || orientation == 'portraitDown')
            ? kBottomNavigationBarHeight + 130.h
            : null;
    double? left =
        (orientation == 'landscapeRight')
            ? -10.w
            : (orientation == 'landscapeLeft')
            ? 100.w
            : 20.w;
    double? right = (orientation == 'landscapeLeft') ? 10.w : null;

    return StreamBuilder<List<dynamic>?>(
      stream: objectsDetectionStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) return Container();
        final labelCount = <String, int>{};
        for (final item in snapshot.data!) {
          if (item != null) {
            labelCount[item.label] = (labelCount[item.label] ?? 0) + 1;
          }
        }
        // Get the top 5 labels sorted by their occurrence
        var topLabels =
            labelCount.entries.toList()..sort(
              (a, b) => b.value.compareTo(a.value),
            ); // Sort by occurrence count
        return GestureDetector(
          onTap: onToggle,
          child: Stack(
            children: [
              Positioned(
                top: top,
                bottom: bottom,
                left: left,
                right: right,
                child: Transform.rotate(
                  angle:
                      orientation == 'portraitUp'
                          ? 0
                          : orientation == 'landscapeRight'
                          ? pi / 2
                          : orientation == 'portraitDown'
                          ? 0
                          : -pi / 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            objectCountVisible
                                ? Icons.arrow_drop_down
                                : Icons.arrow_drop_up,
                            size: 28,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Total Count : ${snapshot.data!.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (objectCountVisible ?? false)
                Positioned(
                  top: orientation == 'landscapeLeft' ? (top! - 50) : top,
                  bottom: bottom != null ? (bottom + 50) : bottom,
                  left:
                      orientation == 'portraitUp' ||
                              orientation == 'portraitDown'
                          ? left
                          : orientation == 'landscapeRight'
                          ? (left + 80)
                          : (left - 80),
                  right: orientation == 'landscapeLeft' ? (right! + 150) : null,
                  child: Transform.rotate(
                    angle:
                        orientation == 'portraitUp'
                            ? 0
                            : orientation == 'landscapeRight'
                            ? pi / 2
                            : orientation == 'portraitDown'
                            ? 0
                            : -pi / 2,
                    child: SizedBox(
                      width: 200,
                      height: 200, // Adjust height as needed
                      child: ListView.builder(
                        reverse: true,
                        itemCount: topLabels.length,
                        itemBuilder: (context, index) {
                          final label = topLabels[index].key;
                          final count = topLabels[index].value;
                          return Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                '$label : $count',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildInferenceTimeWidget({
    int? inferenceTime,
    Color? textColor,
    Color? iconColor,
  }) {
    return Positioned(
      bottom: kBottomNavigationBarHeight + 140.h,
      right: 60.w,
      child: Row(
        children: [
          Text(
            "Inference: ",
            style: TextStyle(color: textColor ?? Colors.white),
          ),
          SizedBox(width: 4.w),
          Text(
            "${inferenceTime ?? 0}ms",
            style: TextStyle(color: textColor ?? Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildModelNameRow({
    required String orientation,
    String? modelName,
    Color? textColor,
    Color? iconColor,
  }) {
    return Positioned(
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? kBottomNavigationBarHeight + 90.h
              : (orientation == 'landscapeLeft')
              ? 614.h
              : null,
      top: (orientation == 'landscapeRight') ? 86.h : null,
      left:
          (orientation == 'landscapeRight')
              ? 70.w
              : (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 20.w
              : null,
      right: (orientation == 'landscapeLeft') ? 70.w : null,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                orientation == 'portraitUp' || orientation == 'portraitDown'
                    ? 200.w
                    : 100.w,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.rocket_launch,
                size: 24,
                color: iconColor ?? Colors.white,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  modelName ??
                      (prefs.chosenModelName.isNotEmpty
                          ? prefs.chosenModelName
                          : initialModelName),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor ?? Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetectionRow({
    required String orientation,
    required bool isRtspPlaying,
    required bool showrtspindicator,
    String? task,
    Color? textColor,
    Color? iconColor,
  }) {
    return Positioned(
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? kBottomNavigationBarHeight + 40.h
              : (orientation == 'landscapeLeft')
              ? 624.h
              : null,
      top: (orientation == 'landscapeRight') ? 100.h : null,
      left:
          (orientation == 'landscapeRight')
              ? 10.w
              : (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 20.w
              : null,
      right: (orientation == 'landscapeLeft') ? 10.w : null,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                orientation == 'portraitUp' || orientation == 'portraitDown'
                    ? 200.w
                    : 100.w,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/detection_and_zone.svg',
                color: iconColor ?? Colors.white,
                height: 24.h,
                width: 24.w,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  task ?? "Detection",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor ?? Colors.white),
                ),
              ),
              SizedBox(width: 4.w),
              Visibility(
                visible: showrtspindicator,
                child: Image.asset(
                  isRtspPlaying
                      ? 'assets/images/rtsp_on.gif'
                      : 'assets/images/rtsp_off.gif',
                  height: 24.h,
                  width: 24.w,
                ),
              ),
            ],
          ),
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

  Widget buildLensToggleButton({
    required String orientation,
    required String icon,
    required VoidCallback onLensToggleButtonPressed,
  }) {
    return Positioned(
      bottom: 80.h,
      right:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 20.w
              : (orientation == 'landscapeLeft')
              ? 20.w
              : null,
      left: (orientation == 'landscapeRight') ? 20.w : null,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: CircularIconButton(
          onPressed: onLensToggleButtonPressed,
          activeIcon: 'act_camera_flip.png',
          inActiveIcon: icon,
        ),
      ),
    );
  }

  Widget buildIPCameraToggleButton({
    required String orientation,
    required VoidCallback onIPCameraToggleButtonPressed,
  }) {
    return Positioned(
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 230.h
              : (orientation == 'landscapeRight')
              ? 80.h
              : 80.h,
      right:
          (orientation == 'landscapeRight')
              ? 165.w
              : (orientation == 'landscapeLeft')
              ? 170.w
              : 20.w,
      child: Transform.rotate(
        angle:
            (orientation == 'landscapeRight')
                ? pi / 2
                : (orientation == 'landscapeLeft')
                ? -pi / 2
                : 0,
        child: CircularIconButton(
          onPressed: onIPCameraToggleButtonPressed,
          activeIcon: 'ip_camera.png',
          inActiveIcon: 'ip_camera.png',
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

  Widget buildScreenshotComponent({
    required String orientation,
    required BuildContext ctx,
    required VoidCallback onScreenshotButtonClicked,
  }) {
    return Positioned(
      bottom:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 180.h
              : (orientation == 'landscapeRight')
              ? 80.h
              : 80.h,
      // bottom: (orientation == 'portraitUp' || orientation == 'portraitDown')
      //     ? 130.h
      //     : 80.h,
      // top: (orientation == 'landscapeRight' || orientation == 'landscapeLeft')
      //     ? 100.h
      //     : null,
      left: (orientation == 'landscapeRight') ? 120.w : null,
      right:
          (orientation == 'landscapeLeft')
              ? 120.w
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
          onPressed: () {},
          activeIcon: 'photo_album.png',
          inActiveIcon: 'photo_album.png',
        ),
      ),
    );
  }

  Widget buildScreenshotPreview({
    required String orientation,
    required BuildContext ctx,
    required bool showPreview,
    Uint8List? screenshotBytes,
  }) {
    return Positioned(
      top:
          (orientation == 'portraitUp' || orientation == 'portraitDown')
              ? 100.h
              : (orientation == 'landscapeRight')
              ? 40.h
              : 40.h,
      right:
          (orientation == 'landscapeRight')
              ? 40.w
              : (orientation == 'landscapeLeft')
              ? 230.w
              : 20.w,
      child:
          showPreview && screenshotBytes != null
              ? Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Image.memory(
                  screenshotBytes,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              )
              : const SizedBox.shrink(),
    );
  }



  void showScreenshotPreview({required bool showPreview}) {
    // setState(() {
    showPreview = true;
    // });

    Future.delayed(const Duration(seconds: 3), () {
      // setState(() {
      showPreview = false;
      // });
    });
  }
}
