import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole_detection_app/configs/model_configs.dart';
import 'package:pothole_detection_app/utils/indicators.dart';
import 'package:pothole_detection_app/utils/location.dart';
import 'package:pothole_detection_app/utils/permission_controller.dart';
import 'package:pothole_detection_app/view/build_methods.dart';
import 'package:pothole_detection_app/view/permission_screen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_controller.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_preview.dart';
import 'package:visionx/visionx_model.dart';
import 'package:visionx/visionx_platform_interface.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/line_counter_data_model.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_segmentor_painter.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/segmented_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/detected_object.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector_painter.dart';
import '../main.dart';
import '../res/constants.dart';
import '../res/user_events.dart';
import '../theme/cubit/theme_cubit.dart';
import 'dart:math' as math;
import '../utils/colors.dart';
import '../utils/custom_functions.dart';
import '../utils/line_drawer.dart';
import '../utils/road_sensor_service.dart';
import 'custom_slider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final RoadSensorService _roadSensorService = RoadSensorService();
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
  var topLabels;
  bool isLoading = true; // Added to track loading state
  bool isError = false;
  bool isAndroid = false;
  final operationList = [const Text('Detection')];
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
  StreamSubscription<Position>? positionStream;
  Position? lastPosition;
  double totalDistance = 0; // in meters
  late Stream<LocationUpdate> _locationStream;
  final StreamController<double> _roughnessStream =
      StreamController.broadcast();
  final List<double> _buffer = [];
  static const int bufferSize = 50; // 1-second window approx
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  Duration sensorInterval = SensorInterval.normalInterval;
  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  final Set<int> _detectedPersonIds = {};
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initializeScreenshotDirectory();
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (AccelerometerEvent event) {
          final now = event.timestamp;
          setState(() {
            _accelerometerEvent = event;
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor Not Found"),
                content: Text(
                  "It seems that your device doesn't support Accelerometer Sensor",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (GyroscopeEvent event) {
          final now = event.timestamp;
          setState(() {
            _gyroscopeEvent = event;
            if (_gyroscopeUpdateTime != null) {
              final interval = now.difference(_gyroscopeUpdateTime!);
              if (interval > _ignoreDuration) {
                _gyroscopeLastInterval = interval.inMilliseconds;
              }
            }
          });
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor Not Found"),
                content: Text(
                  "It seems that your device doesn't support Gyroscope Sensor",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
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
      if (newOrientation != orientation) {
        _controller.updateOrientation(newOrientation);
        setState(() {
          previousOrientation = orientation;
          orientation = newOrientation;
          animationVisible = true;
          if (previousOrientation == "portraitUp" &&
              orientation == "landscapeLeft") {
            _isClockwise = false;
            rotationAngle = -math.pi / 2;
          }
          if (previousOrientation == "landscapeLeft" &&
              orientation == "portraitDown") {
            _isClockwise = false;
            rotationAngle = -math.pi;
          }
          if (previousOrientation == "portraitDown" &&
              orientation == "landscapeRight") {
            _isClockwise = false;
            rotationAngle = -(math.pi + math.pi / 2);
          }
          if (previousOrientation == "landscapeRight" &&
              orientation == "portraitUp") {
            _isClockwise = false;
            rotationAngle = 0;
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

      /// Road Roughness Calculation Data Collection
      double az = event.z - 9.81; // Remove Earth's gravity

      _buffer.add(az);
      if (_buffer.length > bufferSize) {
        _buffer.removeAt(0);
      }

      // --- Roughness Calculation (RMS) ---
      double rms = sqrt(
        _buffer.map((v) => v * v).reduce((a, b) => a + b) / _buffer.length,
      );

      // Push value to StreamBuilder
      _roughnessStream.add(rms);
    });
  }

  @override
  void dispose() {
    print('dispose called');
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
    positionStream?.cancel();
    _roughnessStream.close();
    _detectedPersonIds.clear();
    _roadSensorService.dispose();
    super.dispose();
  }

  // New method to handle sequential initialization
  Future<void> _initializeApp() async {
    // FIRST: Request location permission
    await checkLocationPermissionAndFetchLocation();

    // SECOND: Request other permissions (storage, notifications, etc.)
    await checkPermissionsAndLoadModel();

    // THIRD: Start location tracking (if needed)
    _locationStream = LocationService.startTracking().asBroadcastStream();

    // FOURTH: Start road sensor service and Start collecting road sensor data
    await _roadSensorService.init();
    await _roadSensorService.start(_locationStream);
  }

  String getRoadStatus(double rms) {
    if (rms < 0.8) return "Smooth Road";
    if (rms < 1.5) return "Normal Road";
    if (rms < 2.5) return "Rough Road";
    return "Very Rough Road";
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

  Future<void> checkLocationPermissionAndFetchLocation() async {
    Position? location = await LocationService.getCurrentLocation(context);
    developer.log("Location: $location");
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
            format: Format.tflite,
            modelPath: modelPath,
            metadataPath: metadataPath,
            inputsize: await readMetadataYamlImageSize(metadataPath),
          );
        } else if (prefs.chosenModelMode == "Segmentation") {
          model = LocalYoloModel(
            id: '',
            task: Task.segment,
            format: Format.tflite,
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
            format: Format.coreml,
            modelPath: mlModelPath,
            inputsize: initialInputSize,
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
          isLoading = false;
          isError = false;
        });
      } else {
        throw Exception('Platform not supported');
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  void toggleObjectCountVisible() {
    setState(() {
      objectCountVisible = !objectCountVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? isError
            ? _buildErrorView(context)
            : _buildCameraView(context, orientation, isLoading)
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
              onPressed: () {},
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
          body: Center(child: CircularProgressIndicator()),
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
                homeBuildMethods.buildTimeAndFps(
                  orientation: orientation,
                  objectDetector: objectDetector,
                  inferenceTimeStream: objectDetector.inferenceTime,
                  fpsRateStream: objectDetector.fpsRate,
                ),
                homeBuildMethods.buildSettingsButton(
                  orientation: orientation,
                  onSettingsButtonPressed: () {
                    prefs.appEventsList = [UserEvents.parameterTuningButton];
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
                homeBuildMethods.buildMetricsCard(
                  context: context,
                  orientation: orientation,
                  locationStream: _locationStream,
                  inferenceTimeStream: objectDetector.inferenceTime,
                  fpsRateStream: objectDetector.fpsRate,
                  roughnessStream: _roughnessStream.stream,
                  accelerometerEvent: _accelerometerEvent,
                  gyroscopeEvent: _gyroscopeEvent,
                ),
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
    return Screenshot(
      controller: screenshotController,
      child: Stack(
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
                    (orientation == 'portraitUp' ||
                            orientation == 'portraitDown')
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
                checkForPersonDetection(
                  streamResult.detectionResult,
                  _locationStream,
                  _detectedPersonIds,
                  screenshotController,
                  _controller,
                );
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
                Map<String, int> map = Map.fromEntries(topLabels);
                // Transform the map to the desired format
                List<Map<String, dynamic>> transformedList =
                    map.entries.map((entry) {
                      return {"label": entry.key, "count": entry.value};
                    }).toList();
                // Encode the Map to a JSON string
                String jsonString = jsonEncode(transformedList);
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
                // Convert the list of MapEntry to a Map
                Map<String, int> map = Map.fromEntries(topLabels);
                // Transform the map to the desired format
                List<Map<String, dynamic>> transformedList =
                    map.entries.map((entry) {
                      return {"label": entry.key, "count": entry.value};
                    }).toList();
                // Encode the Map to a JSON string
                String jsonString = jsonEncode(transformedList);
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
                            top:
                                (orientation == 'landscapeRight')
                                    ? 210.h
                                    : null,
                            left:
                                (orientation == 'landscapeRight')
                                    ? -5.w
                                    : (orientation == 'portraitUp' ||
                                        orientation == 'portraitDown')
                                    ? 20.w
                                    : null,
                            right:
                                (orientation == 'landscapeLeft') ? -5.w : null,
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
                                  (orientation == 'landscapeLeft')
                                      ? 70.w
                                      : null,
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
      ),
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
