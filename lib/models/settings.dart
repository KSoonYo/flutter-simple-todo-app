import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel with ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyFontColor = 'font_color';
  static const _keyFontSize = 'font_size';

  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultFontSize = FontSize.large;

  SettingsModel() {
    _load();
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _themeMode = _defaultThemeMode;
  Color? _fontColor;
  FontSize _fontSize = _defaultFontSize;

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    _store(_keyThemeMode, value.index);

    _themeMode = value;
    notifyListeners();
  }

  Color? get fontColor => _fontColor;
  set fontColor(Color? value) {
    _store(_keyFontColor, value?.value);

    _fontColor = value;
    notifyListeners();
  }

  FontSize get fontSize => _fontSize;
  set fontSize(FontSize value) {
    _store(_keyFontSize, value.index);

    _fontSize = value;
    notifyListeners();
  }

  Future<bool> _store<T>(String key, T? value) async {
    final preferences = await _prefs;

    if (value == null) return preferences.remove(key);

    switch (T) {
      case int:
        preferences.setInt(key, value as int);
        break;
      case bool:
        preferences.setBool(key, value as bool);
        break;
      case String:
        preferences.setString(key, value as String);
        break;
      default:
        throw UnsupportedError('Unsupported type $T');
    }

    return true;
  }

  Future<void> _load<T>() async {
    final preferences = await _prefs;

    _themeMode = ThemeMode
        .values[preferences.getInt(_keyThemeMode) ?? _defaultThemeMode.index];

    final rawFontColor = preferences.getInt(_keyFontColor);
    _fontColor = rawFontColor != null ? Color(rawFontColor) : null;

    final rawFontSize = preferences.getInt(_keyFontSize);
    _fontSize =
        rawFontSize != null ? FontSize.values[rawFontSize] : _defaultFontSize;
  }
}

enum FontSize {
  small,
  medium,
  large;
}
