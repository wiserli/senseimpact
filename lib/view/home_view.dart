import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole_detection_app/configs/model_configs.dart';
import 'package:pothole_detection_app/utils/indicators.dart';
import 'package:pothole_detection_app/utils/permission_controller.dart';
import 'package:pothole_detection_app/view/build_methods.dart';
import 'package:pothole_detection_app/view/permission_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_controller.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_preview.dart';
import 'package:visionx/visionx.dart';
import 'package:visionx/visionx_model.dart';
import 'package:visionx/visionx_platform_interface.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/line_counter_data_model.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_segmentor_painter.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/segmented_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/detected_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector_painter.dart';
// import 'package:yolovx/components/custom_widgets.dart';
// import 'package:yolovx/components/server_control_bottomsheet.dart';
// import 'package:yolovx/database/screenshot_gallery_db.dart';
// import 'package:yolovx/main.dart';
// import 'package:yolovx/res/constants.dart';
// import 'package:yolovx/res/user_events.dart';
// import 'package:yolovx/theme/cubit/theme_cubit.dart';
// import 'package:yolovx/utils/colors.dart';
// import 'package:yolovx/utils/cpu_info.dart';
// import 'package:yolovx/utils/custom_functions.dart';
// import 'package:yolovx/utils/in_app_update.dart';
// import 'package:yolovx/utils/indicators.dart';
// import 'package:yolovx/utils/line_drawer.dart';
// import 'package:yolovx/utils/permission_controller.dart';
// import 'package:yolovx/utils/remote_config.dart';
// import 'package:yolovx/utils/system_utilization.dart';
// import 'package:yolovx/utils/user_journey.dart' hide prefs;
// import 'package:yolovx/views/post_auth/home_view/components/build_methods.dart';
// import 'package:yolovx/views/post_auth/home_view/ip_cam_view.dart';
// import 'package:yolovx/views/post_auth/home_view/main_page_view.dart';
// import 'package:yolovx/views/post_auth/model_view/model_repo.dart';
// import 'package:yolovx/views/post_auth/permission_screen.dart';
// import 'package:yolovx/views/post_auth/profile_view/ai_benchmarking_view.dart';
// import 'package:yolovx/views/post_auth/profile_view/profile_view.dart';
import '../../../components/bottom_bar.dart';
import '../../../utils/animations/object_detection_loading_indicator_animation.dart';
// import '../../pre_auth/initial_model_download_view.dart';
// import '../profile_view/app_settings_view.dart';
// import 'components/custom_slider.dart';
// import 'package:sensors_plus/sensors_plus.dart';
import '../main.dart';
import '../res/constants.dart';
import '../res/user_events.dart';
import '../theme/cubit/theme_cubit.dart';
import 'dart:math' as math;

import '../utils/colors.dart';
import '../utils/custom_functions.dart';
import '../utils/line_drawer.dart';
import 'custom_slider.dart';
import 'initial_model_download_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isClockwise = false; // Track whether image is in landscape
  Map<String, dynamic>? _pendingUpdateInfo;
  static const int CAMERA_LENS_FRONT = 0;
  static const int CAMERA_LENS_BACK = 1;
  LocalYoloModel? model;
  late Directory screenshotDirectory;
  List<DetectedObject?>? detectionList;
  // late VlcPlayerController _videoPlayerController;
  final VisionxYoloCameraController _controller = VisionxYoloCameraController(
    deferredProcessing: true,
    trackingEnabled: true,
    trackingAlgorithm: "IOU",
  );
  late ObjectDetector objectDetector;
  bool _isControllerDisposed = false;
  final bool _isLoopRunning = false;
  var topLabels;
  bool _showUpdateDialog = false;

  // Stream<List<DetectedObject?>?>? detectionResultStream;
  bool isLoading = true; // Added to track loading state
  bool isError = false;
  bool isAndroid = false;
  final operationList = [
    const Text('Detection'),
    // const Text('Segmentation'),
    // const Text('OB Boxes'),
  ];
  var modelPath, metadataPath, mlModelPath;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double? pitch;
  double? roll;
  String orientation = "portraitUp";
  Uint8List? screenshotBytes;
  bool showPreview = false;
  final _snapshotTimerQueue = <Timer>[];
  Timer? _snapshotTimer;
  String? selectedCamera;
  final double _confidenceThreshold = double.parse(prefs.confidenceThreshold);
  final double _iouThreshold = double.parse(prefs.iouThreshold);
  final double _numItemsThreshold = double.parse(prefs.numItemsThreshold);
  final int _cameraLens = int.parse(prefs.cameraLens);
  final bool _showConfidence = prefs.showConfidence;
  final String trackingAlgorithm = prefs.trackingAlgorithm;
  List<String> algorithmsList = ["IOU", "HUNGARIAN"];
  final int maxMissedFrames = int.parse(prefs.maxMissedFrames);
  bool objectCountVisible = false;
  final bool _isIPCameraActive = false;
  final bool _isDrawLineModeActive = true;
  BuildMethods homeBuildMethods = BuildMethods();
  List<Map<String, dynamic>> cameraList = [];
  String previousOrientation = "portraitUp";
  double rotationAngle = 0;
  bool animationVisible = false;
  Timer? _timer;
  // final double currentZoomFactor = 1.0;

  @override
  void initState() {
    super.initState();
    checkPermissionsAndLoadModel();
    _initializeScreenshotDirectory();
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      final absoluteX = event.x.abs();
      final absoluteY = event.y.abs();
      final absoluteZ = event.z.abs();

      String newOrientation;
      if (absoluteZ > absoluteX && absoluteZ > absoluteY) {
        newOrientation = orientation; // Default if Z-axis is dominant
      } else {
        if (absoluteX > absoluteY) {
          newOrientation = event.x > 0 ? "landscapeRight" : "landscapeLeft";
        } else {
          newOrientation = event.y > 0 ? "portraitUp" : "portraitDown";
        }
      }
      // print("orientation: $orientation");
      // print("newOrientation: $newOrientation");
      if (newOrientation != orientation) {
        // print("newOrientation: $newOrientation");
        _controller.updateOrientation(newOrientation);
        setState(() {
          previousOrientation = orientation;
          orientation = newOrientation;
          animationVisible = true;
          if (previousOrientation == "portraitUp" &&
              orientation == "landscapeLeft") {
            _isClockwise = false;
            // rotationAngle = math.pi + math.pi / 2;
            rotationAngle = -math.pi / 2;
          }
          if (previousOrientation == "landscapeLeft" &&
              orientation == "portraitDown") {
            _isClockwise = false;
            // rotationAngle = math.pi;
            rotationAngle = -math.pi;
          }
          if (previousOrientation == "portraitDown" &&
              orientation == "landscapeRight") {
            _isClockwise = false;
            // rotationAngle = math.pi / 2;
            rotationAngle = -(math.pi + math.pi / 2);
          }
          if (previousOrientation == "landscapeRight" &&
              orientation == "portraitUp") {
            _isClockwise = false;
            rotationAngle = 0;
            // rotationAngle = 2*math.pi;
          }
          if (previousOrientation == "portraitUp" &&
              orientation == "landscapeRight") {
            _isClockwise = true;
            rotationAngle = math.pi / 2;
          }
          if (previousOrientation == "landscapeRight" &&
              orientation == "portraitDown") {
            _isClockwise = true;
            rotationAngle = math.pi;
          }
          if (previousOrientation == "portraitDown" &&
              orientation == "landscapeLeft") {
            _isClockwise = true;
            rotationAngle = math.pi + math.pi / 2;
          }
          if (previousOrientation == "landscapeLeft" &&
              orientation == "portraitUp") {
            _isClockwise = true;
            rotationAngle = 2 * math.pi; //2*math.pi
          }
          Future.delayed(const Duration(seconds: 2), () {
            // Your command or code to execute after 1 second
            if (mounted) {
              setState(() {
                animationVisible = false;
              });
            }
          });
        });
        debugPrint("Orientation changed to $orientation");
      }
    });
  }

  @override
  void dispose() {
    print('dispose called');
    _isControllerDisposed = true;
    _snapshotTimer?.cancel();
    isTrackingOn = false;
    isCountingOn = false;
    isLineDrawModeOn = false;
    for (var timer in _snapshotTimerQueue) {
      timer.cancel();
    }
    _accelerometerSubscription?.cancel();
    _controller.closeCamera();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeScreenshotDirectory() async {
    if (Platform.isAndroid) {
      Directory? directory = await getExternalStorageDirectory();
      screenshotDirectory = Directory('${directory!.path}/screenshots');
    }
    if (Platform.isIOS) {
      Directory? directory = await getApplicationSupportDirectory();
      screenshotDirectory = Directory('${directory.path}/screenshots');
    }
    if (!await screenshotDirectory.exists()) {
      await screenshotDirectory.create(
        recursive: true,
      ); // Create directory if not exists
    }
  }

  bool shouldSwitchCamera(int storedLens, int currentLens) {
    if (Platform.isAndroid) {
      // Android: 0=front, 1=back
      return (storedLens != currentLens);
    } else {
      // iOS: 0=back, 1=front
      // We need to invert the logic for iOS
      int iosAdjustedStoredLens =
          storedLens == CAMERA_LENS_FRONT
              ? CAMERA_LENS_BACK
              : CAMERA_LENS_FRONT;
      return (iosAdjustedStoredLens != currentLens);
    }
  }

  Future<void> checkPermissionsAndLoadModel() async {
    final permissionsController = PermissionsController();
    final hasPermissions = await permissionsController.build();

    if (hasPermissions) {
      await loadModel();
      if (prefs.frontCameraAlertShown == false &&
          prefs.frontCameraAlertShownOneTime == false) {
        // Capture a safe parent context to use after awaiting operations
        final parentContext = context;
        prefs.frontCameraAlertShownOneTime = true;
      } else if (prefs.frontCameraAlertShown == false &&
          prefs.frontCameraAlertShownOneTime == true) {
        setState(() {
          prefs.frontCameraAlertShown = true;
        });
      }
      // detectionResultStream = objectDetector.detectionResultStream;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PermissionScreen()),
      );
    }
  }

  Future<void> loadModel() async {
    print("orientation from loadModel: $orientation");
    try {
      if (Platform.isAndroid) {
        modelPath = await copy(assetPath: ModelConfigs.tfliteModelPath);
        metadataPath = await copy(assetPath: ModelConfigs.metadataPath);
      } else if (Platform.isIOS) {
        mlModelPath = await copy(assetPath: ModelConfigs.mlModelPath);
      }

      if (Platform.isAndroid) {
        if (prefs.chosenModelMode == "Detection") {
          model = LocalYoloModel(
            id: '',
            task: Task.detect,
            // or Task.classify
            format: Format.tflite,
            // or Format.coreml
            modelPath: modelPath,
            metadataPath: metadataPath,
            inputsize: await readMetadataYamlImageSize(metadataPath),
          );
        } else if (prefs.chosenModelMode == "Segmentation") {
          model = LocalYoloModel(
            id: '',
            task: Task.segment,
            // or Task.classify
            format: Format.tflite,
            // or Format.coreml
            modelPath: modelPath,
            metadataPath: metadataPath,
            inputsize: await readMetadataYamlImageSize(metadataPath),
          );
        }
        if (model != null) {
          objectDetector = ObjectDetector(model: model!);
        }

        await objectDetector.loadModel(useGpu: true);
        setState(() {
          objectDetector.setConfidenceThreshold(_confidenceThreshold);
          objectDetector.setIouThreshold(_iouThreshold);
          objectDetector.setNumItemsThreshold(_numItemsThreshold.ceil());
          objectDetector.setMaxMissedFrames(int.parse(prefs.maxMissedFrames));
          if (shouldSwitchCamera(
            int.parse(prefs.cameraLens),
            _controller.value.lensDirection,
          )) {
            // handleToggleLensDirection(context, _controller);
          }
          isLoading = false;
          isError = false;
        });
      } else if (Platform.isIOS) {
        if (prefs.chosenModelMode == "Detection") {
          model = LocalYoloModel(
            id: '',
            task: Task.detect,
            // or Task.classify
            format: Format.coreml,
            // or Format.coreml
            modelPath: mlModelPath,
            inputsize: initialInputSize,
          );
        } else if (prefs.chosenModelMode == "Segmentation") {
          model = LocalYoloModel(
            id: '',
            task: Task.segment,
            // or Task.classify
            format: Format.coreml,
            // or Format.coreml
            modelPath: mlModelPath,
            inputsize: initialInputSize,
          );
        }
        if (model != null) {
          objectDetector = ObjectDetector(model: model!);
        }
        await objectDetector.loadModel(useGpu: true);
        print(
          "prefs.cameraLens ${prefs.cameraLens} _controller.value.lensDirection (c2)${_controller.value.lensDirection}",
        );
        setState(() {
          objectDetector.setConfidenceThreshold(_confidenceThreshold);
          objectDetector.setIouThreshold(_iouThreshold);
          objectDetector.setNumItemsThreshold(_numItemsThreshold.ceil());
          objectDetector.setMaxMissedFrames(int.parse(prefs.maxMissedFrames));
          if (shouldSwitchCamera(
            int.parse(prefs.cameraLens),
            _controller.value.lensDirection,
          )) {
            // handleToggleLensDirection(context, _controller);

            //print("camera toggled");
          }
          isLoading = false;
          isError = false;
        });
      } else {
        throw Exception('Platform not supported');
      }
    } catch (e) {
      if (e.toString().contains("Unable to load asset:") &&
          prefs.chosenTfliteModelFileName != "" &&
          e.toString().contains(
            prefs.chosenTfliteModelFileName.replaceAll('.aes', '').trim(),
          )) {
        prefs.chosenModelName = "";
        prefs.chosenTfliteModelFileName = "";
        prefs.chosenTfliteModelFileLink = "";
        prefs.chosenMetadataFileName = "";
        prefs.chosenMetadataFileLink = "";
        prefs.chosenMLModelModelFileName = "";
        prefs.chosenMLModelFileLink = "";
        prefs.chosenEncryptionSecretKey = "";
        prefs.chosenSharedModelOwnerId = "";
        setState(() {
          loadModel();
        });
      } else if (e.toString().contains("Unable to load asset:") &&
          e.toString().contains(
            initialTfliteModelFileName.replaceAll('.aes', '').trim(),
          )) {
        CustomSnackBar().showAlertDialog(
          title: "Download Required!",
          message: "Default Model of size 2 mb will be downloaded.",
          rbtntxt: "Proceed",
          rbtnFunction: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const InitialModelDownloadView(),
              ),
            );
          },
          ctx: context,
        );
        setState(() {
          isError = true;
        });
      } else {
        debugPrint(e.toString());
      }
    }
  }

  void showScreenshotPreview() {
    setState(() {
      showPreview = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showPreview = false;
        });
      }
    });
  }

  void toggleObjectCountVisible() {
    setState(() {
      objectCountVisible = !objectCountVisible;
    });
  }

  // Future<double> getCpuUsage() async {
  //   return await _channel.invokeMethod('getCpuUsage');
  // }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? isError
            ? _buildErrorView(context)
            : _buildCameraView(context, orientation, isLoading)
        // : _buildIPCameraPreview();
        : _buildCameraView(context, orientation, isLoading);
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Download Required!",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                prefs.appEventsList = [UserEvents.initialModelDownloadClick];
                // FirebaseAnalytics.instance.logEvent(
                //   name: UserEvents.initialModelDownloadClick,
                // );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitialModelDownloadView(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Proceed"),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(
    BuildContext context,
    String orientation,
    bool isLoading,
  ) {
    return isLoading
        ? Scaffold(
          backgroundColor: Colors.black,
          body: CircularProgressIndicator(),
        )
        : GestureDetector(
          onLongPress: () {
            _controller.pauseLivePrediction();
            CustomSnackBar().SnackBarMessage(
              "Live Preview Paused\nDouble Tap to Resume",
            );
          },
          onDoubleTap: () {
            if (!isLineDrawModeOn) {
              _controller.resumeLivePrediction();
              CustomSnackBar().SnackBarMessage(
                "Live Preview Resumed\nLong Press to Pause",
              );
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                if (prefs.frontCameraAlertShown)
                  _buildCameraPreview(orientation),
                if (isCountingOn)
                  LineDrawerScreen(_controller, orientation: orientation),
                homeBuildMethods.buildLogo(orientation: orientation),
                homeBuildMethods.buildTimeAndFps(
                  orientation: orientation,
                  objectDetector: objectDetector,
                  inferenceTimeStream: objectDetector.inferenceTime,
                  fpsRateStream: objectDetector.fpsRate,
                ),
                homeBuildMethods.buildGestureDetector(
                  orientation: orientation,
                  objectCountVisible: objectCountVisible,
                  onToggle: toggleObjectCountVisible,
                ),
                homeBuildMethods.buildModelNameRow(orientation: orientation),
                homeBuildMethods.buildDetectionRow(
                  task: ModelConfigs.defaultMode,
                  orientation: orientation,
                  showrtspindicator: false,
                  isRtspPlaying: false,
                ),
                homeBuildMethods.buildSettingsButton(
                  orientation: orientation,
                  onSettingsButtonPressed: () {
                    prefs.appEventsList = [UserEvents.parameterTuningButton];
                    // FirebaseAnalytics.instance.logEvent(
                    //   name: UserEvents.parameterTuningButton,
                    // );
                    showDetectionSettings(
                      context: context,
                      objectDetector: objectDetector,
                      confidenceThreshold: _confidenceThreshold,
                      iouThreshold: _iouThreshold,
                      numItemsThreshold: _numItemsThreshold,
                      showConfidence: _showConfidence,
                    );
                  },
                ),
                homeBuildMethods.buildTrackAndCountButton(
                  orientation: orientation,
                  onTrackAndCountButtonPressed: () {
                    debugPrint("Track and Count Button Pressed");
                    showTrackAndCountSettings(
                      context: context,
                      objectDetector: objectDetector,
                      cameraController: _controller,
                      trackingEnabled: isTrackingOn,
                      trackingAlgorithm: prefs.trackingAlgorithm,
                      algorithmsList: algorithmsList,
                      maxMissedFrames: int.parse(prefs.maxMissedFrames),
                      counterEnabled: isCountingOn,
                      counterLabel: prefs.counterLabel,
                      labelsList: prefs.chosenModelClasses,
                    );
                  },
                ),
                if (_showUpdateDialog && _pendingUpdateInfo != null)
                  _buildUpdateDialog(),
              ],
            ),
          ),
        );
  }

  Widget _buildCameraPreview(String orientation) {
    // Add these variables to your class
    double currentZoomFactor = 1.0;
    const double zoomSensitivity = 0.05;
    const double minZoomLevel = 1.0;
    const double maxZoomLevel = 5.0;
    //print("From camera preview:${_controller.value.lensDirection}");
    return Stack(
      children: [
        if (!(Platform.isIOS && kDebugMode))
          RepaintBoundary(
            child: VisionxYoloCameraPreview(
              orientation: orientation,
              predictor: objectDetector,
              controller: _controller,
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
                      ? 20.h
                      : null,
              left:
                  (orientation == 'landscapeRight')
                      ? -10.w
                      : (orientation == 'landscapeLeft')
                      ? 220.w
                      : 20.w,
              right: (orientation == 'landscapeLeft') ? 0.w : null,
              icon:
                  objectCountVisible
                      ? Icons.arrow_drop_down
                      : Icons.arrow_drop_up,
              iconSize: 28,
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
              isListVisible: objectCountVisible,
              isConfidenceValueVisible: true,
              showDetectionFromPlugin: false,
            ),
          ),
        Center(
          child: Visibility(
            maintainState: true,
            maintainAnimation: true,
            child: AnimatedRotation(
              duration: const Duration(seconds: 1),
              // Adjust duration for smoothness
              curve: Curves.easeInOut,
              // Add easing for smooth transition
              turns: rotationAngle / (2 * 3.141592653589793),
              // Convert radians to turns
              child:
                  animationVisible
                      ? Image.asset(
                        _isClockwise
                            ? 'assets/icons/yolovx_logo_sqr_right.png' // Switch to landscape image
                            : 'assets/icons/yolovx_logo_sqr_left.png',
                        // Default portrait image
                        width: 150,
                        height: 150,
                        semanticLabel:
                            _isClockwise
                                ? 'Landscape Right' // Switch to landscape image
                                : 'Portrait',
                      )
                      : const SizedBox.shrink(),
              onEnd: () {
                rotationAngle = 0;
              },
            ),
          ),
        ),
        if (prefs.chosenModelMode == "Detection")
          StreamBuilder<DetectionStreamResults>(
            stream: detectionStreamResultsController.stream,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              var streamResult = snapshot.data!;
              final labelCount = <String, int>{};
              for (final item in streamResult.detectionResult!) {
                if (item != null) {
                  labelCount[item.label] = (labelCount[item.label] ?? 0) + 1;
                }
              }
              // Get the top 5 labels sorted by their occurrence
              topLabels =
                  labelCount.entries.toList()..sort(
                    (a, b) => b.value.compareTo(a.value),
                  ); // Sort by occurrence count
              // sendDetectionsManually(topLabels);
              // webSocket.add(topLabels);
              // Convert the list of MapEntry to a Map
              Map<String, int> map = Map.fromEntries(topLabels);
              // Transform the map to the desired format
              List<Map<String, dynamic>> transformedList =
                  map.entries.map((entry) {
                    return {"label": entry.key, "count": entry.value};
                  }).toList();
              // Encode the Map to a JSON string
              String jsonString = jsonEncode(transformedList);
              // if (activeWebSocket != null) {
              //   String currentTime = DateTime.now().toString();
              //   var data = jsonEncode({
              //     "timestamp": currentTime,
              //     "detections": transformedList,
              //     "inferenceTime": streamResult.inferenceTime,
              //     "fpsRate": streamResult.fpsRate
              //   });
              //   activeWebSocket!.add(data);
              // }
              print(topLabels);
              return CustomPaint(
                painter: ObjectDetectorPainter(
                  orientation,
                  snapshot.data!.detectionResult as List<DetectedObject>,
                  labelColorsList: bBoxColorList,
                  strokeWidth: 2.5,
                  isConfidenceValueVisible: prefs.showConfidence,
                  trackingEnabled: _controller.value.trackingEnabled,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom:
                          (orientation == 'portraitUp' ||
                                  orientation == 'portraitDown')
                              ? kBottomNavigationBarHeight + 130.h
                              : (orientation == 'landscapeLeft')
                              ? 500.h
                              : null,
                      top: (orientation == 'landscapeRight') ? 210.h : null,
                      left:
                          (orientation == 'landscapeRight')
                              ? -5.w
                              : (orientation == 'portraitUp' ||
                                  orientation == 'portraitDown')
                              ? 20.w
                              : null,
                      right: (orientation == 'landscapeLeft') ? -5.w : null,
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
                          mainAxisSize: MainAxisSize.min,
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
                                  'Total Count : ${snapshot.data!.detectionResult!.length}',
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
                        bottom:
                            (orientation == 'portraitUp' ||
                                    orientation == 'portraitDown')
                                ? kBottomNavigationBarHeight + 160.h
                                : (orientation == 'landscapeLeft')
                                ? 480.h
                                : null,
                        top: (orientation == 'landscapeRight') ? 190.h : null,
                        left:
                            (orientation == 'landscapeRight')
                                ? 74.w
                                : (orientation == 'portraitUp' ||
                                    orientation == 'portraitDown')
                                ? 44.w
                                : null,
                        right: (orientation == 'landscapeLeft') ? 70.w : null,
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
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
          ),
        if (prefs.chosenModelMode == "Segmentation")
          StreamBuilder<SegmentationStreamResults>(
            stream: segmentationStreamResultsController.stream,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              var streamResult = snapshot.data!;
              final labelCount = <String, int>{};
              for (final item in streamResult.detectionResult!) {
                if (item != null) {
                  labelCount[item.label] = (labelCount[item.label] ?? 0) + 1;
                }
              }
              // Get the top 5 labels sorted by their occurrence
              topLabels =
                  labelCount.entries.toList()..sort(
                    (a, b) => b.value.compareTo(a.value),
                  ); // Sort by occurrence count
              // sendDetectionsManually(topLabels);
              // webSocket.add(topLabels);
              // Convert the list of MapEntry to a Map
              Map<String, int> map = Map.fromEntries(topLabels);
              // Transform the map to the desired format
              List<Map<String, dynamic>> transformedList =
                  map.entries.map((entry) {
                    return {"label": entry.key, "count": entry.value};
                  }).toList();
              // Encode the Map to a JSON string
              String jsonString = jsonEncode(transformedList);
              // if (activeWebSocket != null) {
              //   String currentTime = DateTime.now().toString();
              //   var data = jsonEncode({
              //     "timestamp": currentTime,
              //     "detections": transformedList,
              //     "inferenceTime": streamResult.inferenceTime,
              //     "fpsRate": streamResult.fpsRate
              //   });
              //   activeWebSocket!.add(data);
              // }
              print(topLabels);
              return Stack(
                children: [
                  ...streamResult.detectionResult!.asMap().entries.map(
                    (entry) =>
                        entry.value != null
                            ? Image.memory(
                              entry.value!.mask!,
                              fit: BoxFit.cover,
                              repeat: ImageRepeat.repeat,
                              color:
                                  Platform.isAndroid
                                      ? bBoxColorList[entry.value!.index %
                                              bBoxColorList.length]
                                          .withOpacity(0.5)
                                      : null,
                              key: ValueKey(entry.key),
                              height: double.infinity,
                              width: double.infinity,
                            )
                            : Container(),
                  ),
                  CustomPaint(
                    painter: ObjectSegmentorPainter(
                      orientation,
                      streamResult.detectionResult as List<SegmentedObject>,
                      labelColorsList: bBoxColorList,
                      isConfidenceValueVisible: prefs.showConfidence,
                      strokeWidth: 2.5,
                      trackingEnabled: _controller.value.trackingEnabled,
                      // isConfidenceValueVisible: true
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom:
                              (orientation == 'portraitUp' ||
                                      orientation == 'portraitDown')
                                  ? kBottomNavigationBarHeight + 130.h
                                  : (orientation == 'landscapeLeft')
                                  ? 500.h
                                  : null,
                          top: (orientation == 'landscapeRight') ? 210.h : null,
                          left:
                              (orientation == 'landscapeRight')
                                  ? -5.w
                                  : (orientation == 'portraitUp' ||
                                      orientation == 'portraitDown')
                                  ? 20.w
                                  : null,
                          right: (orientation == 'landscapeLeft') ? -5.w : null,
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
                                      'Total Count : ${snapshot.data!.detectionResult!.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (objectCountVisible ?? false)
                          Positioned(
                            bottom:
                                (orientation == 'portraitUp' ||
                                        orientation == 'portraitDown')
                                    ? kBottomNavigationBarHeight + 160.h
                                    : (orientation == 'landscapeLeft')
                                    ? 480.h
                                    : null,
                            top:
                                (orientation == 'landscapeRight')
                                    ? 190.h
                                    : null,
                            left:
                                (orientation == 'landscapeRight')
                                    ? 74.w
                                    : (orientation == 'portraitUp' ||
                                        orientation == 'portraitDown')
                                    ? 44.w
                                    : null,
                            right:
                                (orientation == 'landscapeLeft') ? 70.w : null,
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
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
                  ),
                ],
              );
            },
          ),
        GestureDetector(
          onScaleUpdate: (details) {
            if (details.pointerCount == 2) {
              // Calculate the new zoom factor
              var newZoomFactor = currentZoomFactor * details.scale;

              // Adjust the sensitivity for zoom out
              if (newZoomFactor < currentZoomFactor) {
                newZoomFactor =
                    currentZoomFactor -
                    (zoomSensitivity * (currentZoomFactor - newZoomFactor));
              } else {
                newZoomFactor =
                    currentZoomFactor +
                    (zoomSensitivity * (newZoomFactor - currentZoomFactor));
              }

              // Limit the zoom factor to a range between
              // _minZoomLevel and _maxZoomLevel
              final clampedZoomFactor = max(
                minZoomLevel,
                min(maxZoomLevel, newZoomFactor),
              );

              // Update the zoom factor
              VisionxYoloPlatform.instance.setZoomRatio(clampedZoomFactor);

              // Update the current zoom factor for the next update
              currentZoomFactor = clampedZoomFactor;
            }
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.transparent,
            child: const Center(child: Text('')),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Update icon with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.primaries[0].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'New Update Available!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Version info
            Text(
              'Version ${_pendingUpdateInfo!['latestVersion']}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // Update message
            Text(
              _pendingUpdateInfo!['updateMessage'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            // Update buttons
            Row(
              children: [
                if (!_pendingUpdateInfo!['isForcedUpdate'])
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showUpdateDialog = false;
                        });
                      },
                      child: const Text('Later'),
                    ),
                  ),
                if (!_pendingUpdateInfo!['isForcedUpdate'])
                  const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final url =
                          Platform.isIOS
                              ? 'https://apps.apple.com/us/app/yolovx/id6499067892'
                              : 'https://play.google.com/store/apps/details?id=com.wiserli.yolovx';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Update Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showLensOptions({
    required BuildContext context,
    required bool isIpCamView,
  }) async {
    int? selectedIndex;
    bool ipViewSelected = prefs.authFlag; // Open list by default if logged in
    Map<int, bool> cameraStatus = {};
    Map<int, bool> checkingStatus = {};

    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            if (prefs.authFlag && checkingStatus.isEmpty) {
              for (int index = 0; index < cameraList.length; index++) {
                checkingStatus[index] = true;
                setModalState(() {});

                String link = cameraList[index].values.first['link'];
              }
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.switch_camera),
                    title: const Text("IP Camera"),
                    trailing:
                        prefs.authFlag
                            ? GestureDetector(
                              onTap:
                                  () => Navigator.of(
                                    context,
                                  ).pushNamed('/profile'),
                              child: const Icon(Icons.settings_outlined),
                            )
                            : const Icon(Icons.lock, color: Colors.red),
                    onTap: () {
                      if (!prefs.authFlag) {
                        CustomSnackBar().snackBarLoginReqIPCamera(context);
                      }
                    },
                  ),
                  if (!isIpCamView && ipViewSelected)
                    Column(
                      children: [
                        if (cameraList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "The IP camera list is currently empty.\nPlease add an IP camera by navigating to\nProfile > IP Camera Settings.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (cameraList.isNotEmpty)
                          SizedBox(
                            height: 200.h,
                            child: ListView.builder(
                              itemCount: cameraList.length,
                              itemBuilder: (context, index) {
                                bool? isWorking = cameraStatus[index];
                                bool isChecking =
                                    checkingStatus[index] ?? false;

                                return ListTile(
                                  title: Text(
                                    cameraList[index].values.first['name'],
                                  ),
                                  subtitle:
                                      isChecking
                                          ? const Text(
                                            "Checking...",
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          )
                                          : Text(
                                            isWorking == true
                                                ? "Status: Working"
                                                : "Status: Not Working",
                                            style: TextStyle(
                                              color:
                                                  isWorking == true
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                  onTap: () {
                                    setModalState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  trailing:
                                      selectedIndex == index
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.blue,
                                          )
                                          : const Icon(Icons.circle_outlined),
                                );
                              },
                            ),
                          ),
                        if (selectedIndex != null)
                          ListTile(
                            title: Text(
                              "Selected: ${cameraList[selectedIndex!].values.first['name']}",
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                String selectedCamera =
                                    cameraList[selectedIndex!]
                                        .values
                                        .first['link'];

                                Navigator.pop(context);
                                prefs.appEventsList = [
                                  UserEvents.cameraSwitchIpCam,
                                ];
                                // FirebaseAnalytics.instance.logEvent(
                                //   name: UserEvents.cameraSwitchIpCam,
                                // );
                                Future.delayed(const Duration(seconds: 1));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    settings: const RouteSettings(
                                      name: UserEvents.ipCamPageView,
                                    ),
                                    builder:
                                        (context) => BottomNavBar(
                                          initialPage: 0,
                                          initialModelViewTab: 1,
                                          additionalArg: selectedCamera,
                                        ),
                                  ),
                                );
                              },
                              child: const Text("Go ahead!"),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Dart
  // Replace the existing showTrackAndCountSettings bottom-sheet logic with this.
  void showTrackAndCountSettings({
    required BuildContext context,
    required ObjectDetector objectDetector,
    required VisionxYoloCameraController cameraController,
    required bool trackingEnabled,
    required String trackingAlgorithm,
    required List<String> algorithmsList,
    required int maxMissedFrames,
    required bool counterEnabled,
    required String counterLabel,
    required List<String> labelsList,
  }) {
    String trackingAlgorithmDropdownValue = prefs.trackingAlgorithm;
    String counterLabelDropdownValue = prefs.counterLabel;

    // ✅ Pause when opening
    CustomSnackBar().SnackBarMessage("Live Preview Paused");
    _controller.pauseLivePrediction();
    // final bottomSheetController = Scaffold.of(context).showBottomSheet((
    //   BuildContext context,
    // ) {
    //   bool isTrackerExpanded = false;
    //   bool isCounterExpanded = false;
    //
    //   return
    // });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        bool isTrackerExpanded = false;
        bool isCounterExpanded = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              // height: 600.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Track & Count",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 26),
                          ),
                        ],
                      ),
                    ),

                    // Switch + Reset in one row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero, // reduces space
                              title: const Text(
                                'Object Tracking',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              value: trackingEnabled,
                              onChanged: (bool value) {
                                prefs.appEventsList = [
                                  value
                                      ? UserEvents.objectTrackingTurnOn
                                      : UserEvents.objectTrackingTurnOff,
                                ];
                                setModalState(() {
                                  trackingEnabled = value;
                                });
                                cameraController.setTrackingSettings(
                                  trackingEnabled: value,
                                  trackingAlgorithm: trackingAlgorithm,
                                );
                                setState(() {
                                  isTrackingOn = value;
                                });
                                if (value == false) {
                                  counterEnabled = false;
                                  isCounterExpanded = false;
                                  isCountingOn = false;
                                  setState(() {
                                    isCountingOn = value;
                                  });
                                  cameraController.setLineCounterSettings(
                                    enableLineCounterStats: value,
                                    lineCounterStatsLabel: prefs.counterLabel,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (trackingEnabled)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row with toggle button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tracking Settings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isTrackerExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      isTrackerExpanded = !isTrackerExpanded;
                                    });
                                  },
                                ),
                              ],
                            ),

                            // Expandable content
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child:
                                  isTrackerExpanded
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Reset Tracker',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: "Reset Tracker",
                                                onPressed: () {
                                                  prefs.appEventsList = [
                                                    UserEvents
                                                        .resetTrackerClicked,
                                                  ];
                                                  // FirebaseAnalytics.instance
                                                  //     .logEvent(
                                                  //       name:
                                                  //           UserEvents
                                                  //               .resetTrackerClicked,
                                                  //     );
                                                  cameraController
                                                      .resetTrackingId();
                                                  CustomSnackBar()
                                                      .snackBarTrackerReset();
                                                },
                                                icon: const Icon(
                                                  Icons.refresh_rounded,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Tracking Algorithm
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Tracking Algorithm',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              DropdownButton<String>(
                                                value:
                                                    trackingAlgorithmDropdownValue,
                                                icon: const Icon(
                                                  Icons.arrow_downward,
                                                ),
                                                elevation: 16,
                                                style: const TextStyle(
                                                  color: Colors.deepPurple,
                                                ),
                                                underline: Container(
                                                  height: 2,
                                                  color:
                                                      Colors.deepPurpleAccent,
                                                ),
                                                onChanged: (String? value) {
                                                  if (value != null) {
                                                    prefs.appEventsList = [
                                                      UserEvents
                                                          .trackingAlgorithmChanged,
                                                    ];
                                                    // FirebaseAnalytics.instance
                                                    //     .logEvent(
                                                    //       name:
                                                    //           UserEvents
                                                    //               .trackingAlgorithmChanged,
                                                    //     );
                                                    cameraController
                                                        .setTrackingSettings(
                                                          trackingEnabled:
                                                              cameraController
                                                                  .value
                                                                  .trackingEnabled,
                                                          trackingAlgorithm:
                                                              value,
                                                        );
                                                    setModalState(() {
                                                      trackingAlgorithmDropdownValue =
                                                          value;
                                                    });
                                                    prefs.trackingAlgorithm =
                                                        value;
                                                  }
                                                },
                                                items:
                                                    algorithmsList
                                                        .map<
                                                          DropdownMenuItem<
                                                            String
                                                          >
                                                        >(
                                                          (String value) =>
                                                              DropdownMenuItem<
                                                                String
                                                              >(
                                                                value: value,
                                                                child: Text(
                                                                  value,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),
                                        ],
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    // Max Missed Frames Slider
                    isTrackerExpanded
                        ? CustomSlider(
                          title: 'Maximum missed frames',
                          currentSliderValue: double.parse(
                            prefs.maxMissedFrames,
                          ),
                          sliderValueType: SliderValueType.Integer,
                          maxSliderValue: 100,
                          numOfDivision: 100,
                          onSliderChanged: (double value) {
                            maxMissedFrames = value.toInt();
                            prefs.maxMissedFrames = value.toStringAsFixed(0);
                            objectDetector.setMaxMissedFrames(value.toInt());
                          },
                        )
                        : const SizedBox.shrink(),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero, // reduces space
                              title: const Text(
                                'Object Counter',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              value: counterEnabled,
                              onChanged: (bool value) {
                                if (trackingEnabled) {
                                  setModalState(() {
                                    counterEnabled = value;
                                  });
                                  setState(() {
                                    isCountingOn = value;
                                  });
                                  cameraController.setLineCounterSettings(
                                    enableLineCounterStats: value,
                                    lineCounterStatsLabel: prefs.counterLabel,
                                  );
                                } else {
                                  CustomSnackBar()
                                      .snackBarEnableTrackingFirst();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (counterEnabled) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row with toggle button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Counting Settings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isCounterExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      isCounterExpanded = !isCounterExpanded;
                                    });
                                  },
                                ),
                              ],
                            ),

                            // Expandable content
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child:
                                  isCounterExpanded
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'Reset Counter',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: "Reset Counter",
                                                onPressed: () {
                                                  prefs.appEventsList = [
                                                    UserEvents
                                                        .resetCounterClicked,
                                                  ];
                                                  // FirebaseAnalytics.instance
                                                  //     .logEvent(
                                                  //       name:
                                                  //           UserEvents
                                                  //               .resetCounterClicked,
                                                  //     );
                                                  cameraController
                                                      .resetLineCounter();
                                                  CustomSnackBar()
                                                      .snackBarCounterReset();
                                                },
                                                icon: const Icon(
                                                  Icons.refresh_rounded,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Stats Label
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Stats Label',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              DropdownButton<String>(
                                                value:
                                                    counterLabelDropdownValue,
                                                icon: const Icon(
                                                  Icons.arrow_downward,
                                                ),
                                                elevation: 16,
                                                style: const TextStyle(
                                                  color: Colors.deepPurple,
                                                ),
                                                underline: Container(
                                                  height: 2,
                                                  color:
                                                      Colors.deepPurpleAccent,
                                                ),
                                                onChanged: (String? value) {
                                                  if (value != null) {
                                                    prefs.appEventsList = [
                                                      UserEvents
                                                          .counterLabelChanged,
                                                    ];
                                                    // FirebaseAnalytics.instance
                                                    //     .logEvent(
                                                    //       name:
                                                    //           UserEvents
                                                    //               .counterLabelChanged,
                                                    //     );
                                                    setModalState(() {
                                                      counterLabelDropdownValue =
                                                          value;
                                                    });
                                                    cameraController
                                                        .setLineCounterSettings(
                                                          enableLineCounterStats:
                                                              cameraController
                                                                  .value
                                                                  .enableLineCounterStats,
                                                          lineCounterStatsLabel:
                                                              value,
                                                        );
                                                    prefs.counterLabel =
                                                        cameraController
                                                            .value
                                                            .lineCounterStatsLabel;
                                                  }
                                                },
                                                items:
                                                    labelsList.asMap().entries.map<
                                                      DropdownMenuItem<String>
                                                    >((entry) {
                                                      final index =
                                                          entry
                                                              .key; // serial number starts from 0
                                                      final value = entry.value;
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: value,
                                                        child: Text(
                                                          '$index. $value',
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),
                                        ],
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _controller.resumeLivePrediction();
      CustomSnackBar().SnackBarMessage("Live Preview Resumed");
      debugPrint("Bottom sheet closed");
    });
  }
}

class DetectionStreamResults {
  List<DetectedObject?>? detectionResult;
  double inferenceTime;
  double fpsRate;
  LineCounterDataModel? countingResult;
  DetectionStreamResults({
    this.detectionResult,
    this.countingResult,
    required this.inferenceTime,
    required this.fpsRate,
  });
}

class SegmentationStreamResults {
  List<SegmentedObject?>? detectionResult;
  double inferenceTime;
  double fpsRate;
  LineCounterDataModel? countingResult;
  SegmentationStreamResults({
    this.detectionResult,
    this.countingResult,
    required this.inferenceTime,
    required this.fpsRate,
  });
}
