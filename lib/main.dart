import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pothole_detection_app/utils/user_prefs.dart';
import 'package:pothole_detection_app/view/home_view.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/line_counter_data_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences().initPrefs();
  runApp(const MyApp());
}

WebSocket? activeWebSocket;
bool isServerOn = false;
bool isCountingOn = false;
bool isTrackingOn = false;
bool isLineDrawModeOn = false;
Connectivity connectivity = Connectivity();
ConnectivityResult? connectivityResult;
final detectionStreamResultsController =
    StreamController<DetectionStreamResults>.broadcast();

final segmentationStreamResultsController =
    StreamController<SegmentationStreamResults>.broadcast();

final lineCounterStreamResultsController =
    StreamController<LineCounterDataModel>.broadcast();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 780),
      child: MaterialApp(
        title: 'Pothole Detection App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: HomeView(),
      ),
    );
  }
}
