import 'package:flutter/material.dart';

import '../../../app/enum/enum.dart';
import '../../../app/services/service_locator.dart';
import '../../../app/services/shared_preferences_service.dart';

class ThemeNotifier extends ChangeNotifier {
  final SharedPreferencesService _prefsService = ServiceLocator.sharedPrefs;

  late AppThemeMode _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefsService.setString(
        SharedPreferencesService.themeKey, mode.toJson());
    notifyListeners();
  }

  void _loadTheme() {
    final savedTheme =
        _prefsService.getString(SharedPreferencesService.themeKey);
    _themeMode = savedTheme != null
        ? AppThemeMode.fromJson(savedTheme)
        : AppThemeMode.system;
    notifyListeners();
  }
}
