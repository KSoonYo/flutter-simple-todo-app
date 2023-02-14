import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel with ChangeNotifier {
  static const keyThemeMode = 'theme_mode';
  static const keyColor = 'color';

  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultColor = Colors.white;

  SettingsModel() {
    _loadThemeMode();
    _loadColor();
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _themeMode = _defaultThemeMode;
  Color? _color = _defaultColor;

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    _storeThemeMode(value);
  }

  Color? get color => _color;
  set color(Color? value) {
    _storeColor(value);
  }

  Future<void> _storeThemeMode(ThemeMode value) async {
    final preferences = await _prefs;
    await preferences.setInt(keyThemeMode, value.index);

    _updateThemeMode(value);
  }

  Future<void> _loadThemeMode() async {
    final preferences = await _prefs;
    final rawValue = preferences.getInt(keyThemeMode);

    final themeMode =
        rawValue != null ? ThemeMode.values[rawValue] : _defaultThemeMode;

    _updateThemeMode(themeMode);
  }

  void _updateThemeMode(ThemeMode value) {
    if (_themeMode == value) return;

    _themeMode = value;
    notifyListeners();
  }

  Future<void> _storeColor(Color? value) async {
    final preferences = await _prefs;

    if (value == null) {
      await preferences.remove(keyColor);
      return;
    }

    await preferences.setInt(keyColor, value.value);

    _updateColor(value);
  }

  Future<void> _loadColor() async {
    final preferences = await _prefs;
    final rawValue = preferences.getInt(keyThemeMode);

    final color = rawValue != null ? Color(rawValue) : _defaultColor;

    _updateColor(color);
  }

  void _updateColor(Color? value) {
    if (_color == value) return;

    _color = value;
    notifyListeners();
  }
}
