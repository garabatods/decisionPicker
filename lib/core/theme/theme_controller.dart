import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({required SharedPreferences preferences})
      : _preferences = preferences;

  static const String _darkModeKey = 'decision_maker.dark_mode.v1';

  final SharedPreferences _preferences;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadThemeMode() async {
    _isDarkMode = _preferences.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    if (_isDarkMode == isDarkMode) {
      return;
    }

    _isDarkMode = isDarkMode;
    await _preferences.setBool(_darkModeKey, isDarkMode);
    notifyListeners();
  }
}
