part of 'theme_cubit.dart';

class ThemeState {
  final bool isDarkThemeOn;
  late ThemeData theme;
  ThemeState({required this.isDarkThemeOn}) {
    if (isDarkThemeOn) {
      theme = appThemeData[AppTheme.darkAppTheme] as ThemeData;
    } else {
      theme = appThemeData[AppTheme.lightAppTheme] as ThemeData;
    }
  }

  ThemeState copyWith({required bool changeState}) {
    return ThemeState(isDarkThemeOn: changeState);
  }
}
