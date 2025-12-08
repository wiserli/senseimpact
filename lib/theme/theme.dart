import 'package:flutter/material.dart';
import 'package:pothole_detection_app/theme/theme_utils.dart';

enum AppTheme { lightAppTheme, darkAppTheme }

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.darkAppTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: CustomColors.scaffoldColor,
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF9EDED)),
    useMaterial3: true,
  ),
  AppTheme.lightAppTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: CustomColors.scaffoldColor,
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF9EDED)),
    useMaterial3: true,
  ),
};
