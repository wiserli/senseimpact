import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/user_prefs.dart';
import '../theme.dart';

part 'theme_state.dart';

final prefs = UserPreferences();

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(isDarkThemeOn: prefs.isDarkTheme));

  void toggleSwitch(bool value) {
   // UserRepository().editThemeInDB(UserModel(theme: value ? 'dark' : 'light'));
    prefs.isDarkTheme = value;
    emit(state.copyWith(changeState: value));
  }
}