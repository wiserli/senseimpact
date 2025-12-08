// import 'package:firebase_analytics/firebase_analytics.dart';

// logEvent(String event) {
//   // FirebaseAnalytics.instance.logEvent(
//   //   name: event,
//   //   parameters: <String, dynamic>{
//   //     'string_parameter': 'string',
//   //     'int_parameter': 42,
//   //   },
//   // );
// }
// logScreen(String screenName) {
//   FirebaseAnalytics.instance.logScreenView(
//       screenName: screenName,
//       screenClass: 'FlutterScreens',
//       parameters: <String, dynamic>{
//         'dateTime': DateTime.now().toUtc().toString()
//       });
// }

// class ScreenName {
//   static const String main = 'main.dart';
//   static const String bottomNavBar = 'BottomNavBar';
//   static const String homeView = 'HomeView';
//   static const String modelView = 'ModelView';
//   static const String profileView = 'ProfileView';

//   get name => toString();
// }

// class EventName {
//   static const String loginEvent = 'loginEvent';

//   get name => toString();
// }