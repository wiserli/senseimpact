// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/cubit/theme_cubit.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  factory UserPreferences() => _instance;
  UserPreferences._internal();
  late SharedPreferences _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setDemoVariable(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  set pendingAnalytics(List<String> list) {
    _prefs.setStringList('pendingAnalytics', list);
  }

  List<String> get pendingAnalytics {
    return _prefs.getStringList('pendingAnalytics') ?? [];
  }

  bool getDemoVariable(String key) {
    return _prefs.getBool(key) ?? false;
  }

  set pendingActions(List<String> list) {
    _prefs.setStringList('pendingActions', list);
  }

  List<String> get pendingActions {
    return _prefs.getStringList('pendingActions') ?? [];
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  Future<bool> clearUserPrefs() async {
    await _prefs.remove('loginType');
    await _prefs.remove('chosenModelName');
    await _prefs.remove('chosenTfliteModelFileName');
    await _prefs.remove('chosenTfliteModelFileLink');
    await _prefs.remove('chosenMetadataFileName');
    await _prefs.remove('chosenMetadataFileLink');
    await _prefs.remove('chosenMLModelModelFileName');
    await _prefs.remove('chosenMLModelFileLink');
    await _prefs.remove('chosenEncryptionSecretKey');
    await _prefs.remove('previousDeployedModelType');
    await _prefs.remove('previousSharedModelOwnerId');
    await _prefs.remove('chosenSharedModelOwnerId');
    await _prefs.remove('dateJoined');
    await _prefs.remove('jobFunction');
    await _prefs.remove('orgName');
    await _prefs.remove('email');
    await _prefs.remove('username');
    await _prefs.remove('userId');
    await _prefs.remove('fcmToken');
    await _prefs.remove('lastVerificationDate');
    await _prefs.remove('userSubscription');
    await _prefs.remove('authFlag');
    await _prefs.remove('guestAuthFlag');
    await _prefs.remove('isDarkTheme');
    await _prefs.remove('confidenceThreshold');
    await _prefs.remove('iouThreshold');
    await _prefs.remove('numItemsThreshold');
    await _prefs.remove('cameraLens');
    await _prefs.remove('showConfidence');
    return true;
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  String get loginType {
    return _prefs.getString('loginType') ?? '';
  }

  set loginType(String value) {
    _prefs.setString('loginType', value);
  }

  /// Variables for Demo Tutorials

  get initScreen {
    return _prefs.getInt('initScreen');
  }

  set initScreen(value) {
    _prefs.setInt('initScreen', value);
  }

  /// Variable for benchmark banner on the home screen
  get showBenchmarkBanner {
    return _prefs.getBool('showBenchmarkBanner') ?? true;
  }

  set showBenchmarkBanner(value) {
    _prefs.setBool('showBenchmarkBanner', value);
  }

  get showNavDemo {
    return _prefs.getBool('showNavDemo') ?? false;
  }

  set showNavDemo(value) {
    _prefs.setBool('showNavDemo', value);
  }

  get publicDemoDone {
    return _prefs.getBool('publicDemoDone') ?? false;
  }

  set publicDemoDone(value) {
    _prefs.setBool('publicDemoDone', value);
  }

  get privateDemoDone {
    return _prefs.getBool('privateDemoDone') ?? false;
  }

  set privateDemoDone(value) {
    _prefs.setBool('privateDemoDone', value);
  }

  get sharedDemoDone {
    return _prefs.getBool('sharedDemoDone') ?? false;
  }

  set sharedDemoDone(value) {
    _prefs.setBool('sharedDemoDone', value);
  }

  String get chosenModelName {
    return _prefs.getString('chosenModelName') ?? '';
  }

  set chosenModelName(String value) {
    _prefs.setString('chosenModelName', value);
  }

  String get chosenModelMode {
    return _prefs.getString('chosenModelMode') ?? "Detection";
  }

  set chosenModelMode(String value) {
    _prefs.setString('chosenModelMode', value);
  }

  String get chosenTfliteModelFileName {
    return _prefs.getString('chosenTfliteModelFileName') ?? '';
  }

  set chosenTfliteModelFileName(String value) {
    _prefs.setString('chosenTfliteModelFileName', value);
  }

  String get chosenTfliteModelFileLink {
    return _prefs.getString('chosenTfliteModelFileLink') ?? '';
  }

  set chosenTfliteModelFileLink(String value) {
    _prefs.setString('chosenTfliteModelFileLink', value);
  }

  set chosenMetadataFileName(String value) {
    _prefs.setString('chosenMetadataFileName', value);
  }

  String get chosenMetadataFileName {
    return _prefs.getString('chosenMetadataFileName') ?? '';
  }

  set chosenMetadataFileLink(String value) {
    _prefs.setString('chosenMetadataFileLink', value);
  }

  String get chosenMetadataFileLink {
    return _prefs.getString('chosenMetadataFileLink') ?? '';
  }

  set chosenMLModelModelFileName(String value) {
    _prefs.setString('chosenMLModelModelFileName', value);
  }

  String get chosenMLModelModelFileName {
    return _prefs.getString('chosenMLModelModelFileName') ?? '';
  }

  set chosenMLModelFileLink(String value) {
    _prefs.setString('chosenMLModelFileLink', value);
  }

  String get chosenMLModelFileLink {
    return _prefs.getString('chosenMLModelFileLink') ?? '';
  }

  set chosenModelClasses(List<String> list) {
    _prefs.setStringList('chosenModelClasses', list);
  }

  List<String> get chosenModelClasses {
    return _prefs.getStringList('chosenModelClasses') ?? [];
  }

  String get chosenBenchmarkModelName {
    return _prefs.getString('chosenBenchmarkModelName') ?? '';
  }

  set chosenBenchmarkModelName(String value) {
    _prefs.setString('chosenBenchmarkModelName', value);
  }

  String get chosenBenchmarkTfliteModelFileName {
    return _prefs.getString('chosenBenchmarkTfliteModelFileName') ?? '';
  }

  set chosenBenchmarkTfliteModelFileName(String value) {
    _prefs.setString('chosenBenchmarkTfliteModelFileName', value);
  }

  String get chosenBenchmarkTfliteModelFileLink {
    return _prefs.getString('chosenBenchmarkTfliteModelFileLink') ?? '';
  }

  set chosenBenchmarkTfliteModelFileLink(String value) {
    _prefs.setString('chosenBenchmarkTfliteModelFileLink', value);
  }

  set chosenBenchmarkMetadataFileName(String value) {
    _prefs.setString('chosenBenchmarkMetadataFileName', value);
  }

  String get chosenBenchmarkMetadataFileName {
    return _prefs.getString('chosenBenchmarkMetadataFileName') ?? '';
  }

  set chosenBenchmarkMetadataFileLink(String value) {
    _prefs.setString('chosenBenchmarkMetadataFileLink', value);
  }

  String get chosenBenchmarkMetadataFileLink {
    return _prefs.getString('chosenBenchmarkMetadataFileLink') ?? '';
  }

  set chosenBenchmarkMLModelModelFileName(String value) {
    _prefs.setString('chosenBenchmarkMLModelModelFileName', value);
  }

  String get chosenBenchmarkMLModelModelFileName {
    return _prefs.getString('chosenBenchmarkMLModelModelFileName') ?? '';
  }

  set chosenBenchmarkMLModelFileLink(String value) {
    _prefs.setString('chosenMLModelFileLink', value);
  }

  String get chosenBenchmarkMLModelFileLink {
    return _prefs.getString('chosenBenchmarkMLModelFileLink') ?? '';
  }

  set chosenEncryptionSecretKey(String value) {
    _prefs.setString('chosenEncryptionSecretKey', value);
  }

  String get chosenEncryptionSecretKey {
    return _prefs.getString('chosenEncryptionSecretKey') ?? '';
  }

  set previousDeployedModelType(String value) {
    _prefs.setString('previousDeployedModelType', value);
  }

  String get previousDeployedModelType {
    return _prefs.getString('previousDeployedModelType') ?? '';
  }

  set previousSharedModelOwnerId(String value) {
    _prefs.setString('previousSharedModelOwnerId', value);
  }

  String get previousSharedModelOwnerId {
    return _prefs.getString('previousSharedModelOwnerId') ?? '';
  }

  set chosenSharedModelOwnerId(String value) {
    _prefs.setString('chosenSharedModelOwnerId', value);
  }

  String get chosenSharedModelOwnerId {
    return _prefs.getString('chosenSharedModelOwnerId') ?? '';
  }

  // List<String> get rUModelDetail {
  //   return _prefs.getStringList('chosenModelDetailList') ?? [];
  // }
  //
  //  set rUModelDetail(List<String> chosenModelDetailList) {
  //    _prefs.setStringList('chosenModelDetailList',chosenModelDetailList);
  // }

  /// Variables for User Information

  set dateJoined(String value) {
    _prefs.setString('dateJoined', value);
  }

  String get dateJoined {
    return _prefs.getString('dateJoined') ?? '';
  }

  set jobFunction(String value) {
    _prefs.setString('jobFunction', value);
  }

  String get jobFunction {
    return _prefs.getString('jobFunction') ?? '';
  }

  set orgName(String value) {
    _prefs.setString('orgName', value);
  }

  String get orgName {
    return _prefs.getString('orgName') ?? '';
  }

  set email(String value) {
    _prefs.setString('email', value);
  }

  String get email {
    return _prefs.getString('email') ?? '';
  }

  String get deviceId {
    return _prefs.getString('deviceId') ?? '';
  }

  set deviceId(String value) {
    _prefs.setString('deviceId', value);
  }

  String get deviceName {
    return _prefs.getString('deviceName') ?? '';
  }

  set deviceName(String value) {
    _prefs.setString('deviceName', value);
  }

  String get deviceVersion {
    return _prefs.getString('deviceVersion') ?? '';
  }

  set deviceVersion(String value) {
    _prefs.setString('deviceVersion', value);
  }

  String get appVersion {
    return _prefs.getString('appVersion') ?? '';
  }

  set appVersion(String value) {
    _prefs.setString('appVersion', value);
  }

  // String get userType {
  //   return _prefs.getString('userType') ?? '';
  // }
  //
  // set userType(String value) {
  //   _prefs.setString('userType', value);
  // }

  String get username {
    return _prefs.getString('username') ?? '';
  }

  set username(String value) {
    _prefs.setString('username', value);
  }

  String get userId {
    return _prefs.getString('userId') ?? '';
  }

  set userId(String value) {
    _prefs.setString('userId', value);
  }

  String get fcmToken {
    return _prefs.getString('fcmToken') ?? '';
  }

  set fcmToken(String value) {
    _prefs.setString('fcmToken', value);
  }

  String get lastVerificationDate {
    return _prefs.getString('lastVerificationDate') ?? '';
  }

  set lastVerificationDate(String value) {
    _prefs.setString('lastVerificationDate', value);
  }

  String get userSubscription {
    return _prefs.getString('userSubscription') ?? '';
  }

  set userSubscription(String value) {
    _prefs.setString('userSubscription', value);
  }

  String get localCameraDatabase {
    return _prefs.getString('localCameraDatabase') ?? '';
  }

  set localCameraDatabase(String value) {
    _prefs.setString('localCameraDatabase', value);
  }

  bool get authFlag {
    return _prefs.getBool('authFlag') ??
        false; // Returns true if user is authenticated
  }

  set authFlag(bool value) {
    _prefs.setBool('authFlag', value);
  }

  bool get guestAuthFlag {
    return _prefs.getBool('guestAuthFlag') ?? false;
  }

  set guestAuthFlag(bool value) {
    _prefs.setBool('guestAuthFlag', value);
  }

  String get buildNumber {
    return _prefs.getString('buildNumber') ?? '';
  }

  set buildNumber(String value) {
    _prefs.setString('buildNumber', value);
  }

  bool get isPhysicalDevice {
    return _prefs.getBool('isPhysicalDevice') ?? false;
  }

  set isPhysicalDevice(bool value) {
    _prefs.setBool('isPhysicalDevice', value);
  }

  bool get isDarkTheme {
    return _prefs.getBool('isDarkTheme') ?? false;
  }

  set isDarkTheme(bool value) {
    _prefs.setBool('isDarkTheme', value);
  }

  String getLogDate({DateTime? custom}) {
    return DateFormat('dd-MM-yyyy').format((custom ?? DateTime.now()).toUtc());
  }

  /// Variables for App Events

  // List<String> get appEventsList {
  //   return _prefs.getStringList('appEventsList') ?? [];
  // }
  //
  // set appEventsList(List<String> value) {
  //   List<String> previousEvents = _prefs.getStringList('appEventsList') ?? [];
  //   List<String> newEvents = [];
  //   for (String ele in value) {
  //     String formattedTime = DateFormat.Hms().format(DateTime.now());
  //     newEvents.add('${ele}_$formattedTime');
  //   }
  //   previousEvents.addAll(newEvents);
  //   _prefs.setStringList('appEventsList', previousEvents);
  // }
  //
  // clearAppEvents() {
  //   _prefs.setStringList('appEventsList', []);
  // }

  Map<String, List<String>> get appEventsMap {
    String? raw = _prefs.getString('appEventsMap');
    if (raw == null) return {};
    Map<String, dynamic> decoded = jsonDecode(raw);
    return decoded.map((k, v) => MapEntry(k, List<String>.from(v)));
  }

  set appEventsList(List<String> value) {
    // Load existing map {date: [events]}
    Map<String, dynamic> allEvents = {};
    String? raw = _prefs.getString('appEventsMap');
    if (raw != null) {
      allEvents = Map<String, dynamic>.from(jsonDecode(raw));
    }

    // Today’s date (UTC)
    String logDate = DateFormat('dd-MM-yyyy').format(DateTime.now().toUtc());
    // String logDate =
    //     getLogDate(custom: DateTime.now().add(const Duration(days: 1)));

    // Build new events with timestamp
    List<String> newEvents = [];
    for (String ele in value) {
      String formattedTime = DateFormat("HH:mm:ss").format(DateTime.now());
      // String formattedTime = DateFormat("HH:mm:ss")
      //     .format(DateTime.now().add(const Duration(days: 1)));
      newEvents.add('${ele}_$formattedTime');
    }

    // Append into today’s bucket
    List<String> existing = List<String>.from(allEvents[logDate] ?? []);
    existing.addAll(newEvents);
    allEvents[logDate] = existing;

    // Save back
    _prefs.setString('appEventsMap', jsonEncode(allEvents));
  }

  clearAppEvents() {
    _prefs.remove('appEventsMap');
  }

  /// Benchmark Data Storage

  Future<void> storeBenchmarkDataLocally({
    required Map<String, dynamic> deviceInfoData,
    required int aiScore,
    required int totalTime,
    required List<dynamic> testResults,
    required double avgInitTime,
    required double avgInferTimeOD,
    required double avgInferTimeSeg,
    required double avgUsageRAM,
    required double avgUsageCPU,
    required double avgMapOD,
    required double avgMapSeg,
    required int speedScore,
    required int accuracyScore,
    required int resourceScore,
    required String dataSet,
  }) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    final Map<String, dynamic> benchmarkData = {
      'created_at': DateTime.now().toIso8601String(),
      'user_id':
          prefs.userId == '' ? deviceInfoData['device_id'] : prefs.userId,
      'device_name': deviceInfoData['device_name'],
      'os': deviceInfoData['OS'],
      'os_version': deviceInfoData['OS_Version'],
      'soc_model': deviceInfoData['soc_model'],
      'ram': deviceInfoData['RAM'],
      'bm_version': '1.0',
      'add_info': {
        'device_model': deviceInfoData['Model'],
        'soc_manufacturer': deviceInfoData['soc_manufacturer'],
        'max_clock_speed': deviceInfoData['Frequency'],
        'cpu_cores': deviceInfoData['Cores'],
      },
      'ai_score': aiScore,
      'total_time': totalTime,
      'test_results': testResults,
      'avg_init_time': avgInitTime,
      'avg_inf_time_od': avgInferTimeOD,
      'avg_inf_time_seg': avgInferTimeSeg,
      'avg_usage_cpu': avgUsageCPU,
      'avg_usage_ram': avgUsageRAM,
      'avg_map_od': avgMapOD,
      'avg_map_seg': avgMapSeg,
      'speed_score': speedScore,
      'accuracy_score': accuracyScore,
      'resource_score': resourceScore,
    };

    dataSet == 'benchmark_data'
        ? await sp.setString('benchmark_data', jsonEncode(benchmarkData))
        : await sp.setString('ai_score_data', jsonEncode(benchmarkData));
  }

  Future<Map<String, dynamic>?> getBenchmarkDataLocally(String dataset) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? jsonString = sp.getString(dataset);

    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> clearBenchmarkDataLocally(String dataset) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove(dataset);
  }

  Future<bool> hasBenchmarkData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.containsKey('ai_score_data');
  }

  Future<Map<String, dynamic>?> getBenchmarkSummary() async {
    final benchmarkData = await getBenchmarkDataLocally('ai_score_data');
    if (benchmarkData == null) return null;

    return {
      'device_info': {
        'device_name': benchmarkData['device_name'],
        'os': benchmarkData['os'],
        'os_version': benchmarkData['os_version'],
        'soc_model': benchmarkData['soc_model'],
        'ram': benchmarkData['ram'],
      },
      'scores': {
        'ai_score': benchmarkData['ai_score'],
        'speed_score': benchmarkData['speed_score'],
        'accuracy_score': benchmarkData['accuracy_score'],
        'resource_score': benchmarkData['resource_score'],
      },
      'performance_metrics': {
        'total_time': benchmarkData['total_time'],
        'avg_init_time': benchmarkData['avg_init_time'],
        'avg_inf_time_od': benchmarkData['avg_inf_time_od'],
        'avg_inf_time_seg': benchmarkData['avg_inf_time_seg'],
        'avg_usage_cpu': benchmarkData['avg_usage_cpu'],
        'avg_usage_ram': benchmarkData['avg_usage_ram'],
        'avg_map_od': benchmarkData['avg_map_od'],
        'avg_map_seg': benchmarkData['avg_map_seg'],
      },
      'test_results': benchmarkData['test_results'],
      'timestamp': benchmarkData['created_at'],
    };
  }

  /// Variables for hyper parameters tuning

  set confidenceThreshold(String value) {
    _prefs.setString('confidenceThreshold', value);
  }

  String get confidenceThreshold {
    return _prefs.getString('confidenceThreshold') ?? "0.25";
  }

  set iouThreshold(String value) {
    _prefs.setString('iouThreshold', value);
  }

  String get iouThreshold {
    return _prefs.getString('iouThreshold') ?? "0.5";
  }

  set numItemsThreshold(String value) {
    _prefs.setString('numItemsThreshold', value);
  }

  String get numItemsThreshold {
    return _prefs.getString('numItemsThreshold') ??
        "10"; // Edit this value to set default numItemsThreshold value
  }

  set maxMissedFrames(String value) {
    _prefs.setString('maxMissedFrames', value);
  }

  String get maxMissedFrames {
    return _prefs.getString('maxMissedFrames') ??
        "30"; // Edit this value to set default maxMissedFrames value
  }

  set showConfidence(bool value) {
    _prefs.setBool('showConfidence', value);
  }

  bool get showConfidence {
    return _prefs.getBool('showConfidence') ??
        false; // Edit this value to set default numItemsThreshold value
  }

  set trackingEnabled(bool value) {
    _prefs.setBool('trackingEnabled', value);
  }

  bool get trackingEnabled {
    return _prefs.getBool('trackingEnabled') ??
        false; // Tracking disabled by default
  }

  set trackingAlgorithm(String value) {
    _prefs.setString('trackingAlgorithm', value);
  }

  String get trackingAlgorithm {
    return _prefs.getString('trackingAlgorithm') ??
        "IOU"; // Edit this value to set default maxMissedFrames value
  }

  set counterEnabled(bool value) {
    _prefs.setBool('counterEnabled', value);
  }

  bool get counterEnabled {
    return _prefs.getBool('counterEnabled') ??
        false; // Tracking disabled by default
  }

  set drawModeEnabled(bool value) {
    _prefs.setBool('drawModeEnabled', value);
  }

  bool get drawModeEnabled {
    return _prefs.getBool('drawModeEnabled') ??
        false; // Tracking disabled by default
  }

  set counterLabel(String value) {
    _prefs.setString('counterLabel', value);
  }

  String get counterLabel {
    return _prefs.getString('counterLabel') ?? prefs.chosenModelClasses.first;
  }

  set frontCameraAlertShown(bool value) {
    _prefs.setBool('frontCameraAlertShown', value);
  }

  bool get frontCameraAlertShown {
    return _prefs.getBool('frontCameraAlertShown') ??
        true; // Edit this value to set default numItemsThreshold value
  }

  set frontCameraAlertShownOneTime(bool value) {
    _prefs.setBool('frontCameraAlertShownOneTime', value);
  }

  bool get frontCameraAlertShownOneTime {
    return _prefs.getBool('frontCameraAlertShownOneTime') ??
        false; // Edit this value to set default numItemsThreshold value
  }

  set cameraLens(String value) {
    _prefs.setString('cameraLens', value);
  }

  String get cameraLens {
    return _prefs.getString('cameraLens') ??
        "1"; // Edit this value to set default numItemsThreshold value
  }

  set hasSeenLensWarning(bool value) {
    _prefs.setBool('hasSeenLensWarning', value);
  }

  bool get hasSeenLensWarning {
    return _prefs.getBool('hasSeenLensWarning') ?? false;
  }

  get appOpenCount {
    return _prefs.getInt('appOpenCount');
  }

  set appOpenCount(value) {
    _prefs.setInt('appOpenCount', value);
  }
}
