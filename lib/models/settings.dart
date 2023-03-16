import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel with ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyFontColor = 'font_color';
  static const _keySelectedFontColorIndex = 'selected_font_color_index';
  static const _keyFontSize = 'font_size';
  static const _keyLastFlushed = 'last_flushed';
  static const _keyFlushAt = 'flush_at';
  static const _keyIsHaptic = 'is_haptic';

  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultFontSize = FontSize.small;
  static final _defaultLastFlushed = DateTime.now();
  static const _defaultFlushAt = TimeOfDay(hour: 3, minute: 0);
  static const _defaultIsHaptic = false;

  SettingsModel() {
    _load();
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _themeMode = _defaultThemeMode;
  Color? _fontColor;
  int _selectedFontColorIndex = 0;
  FontSize _fontSize = _defaultFontSize;
  DateTime _lastFlushed = _defaultLastFlushed;
  TimeOfDay _flushAt = _defaultFlushAt;
  bool _isHptic = _defaultIsHaptic;

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

  int get selectedFontColorIndex => _selectedFontColorIndex;
  set selectedFontColorIndex(int index) {
    _store(_keySelectedFontColorIndex, index);
    _selectedFontColorIndex = index;
    notifyListeners();
  }

  FontSize get fontSize => _fontSize;
  set fontSize(FontSize value) {
    _store(_keyFontSize, value.index);

    _fontSize = value;
    notifyListeners();
  }

  DateTime get lastFlushed => _lastFlushed;
  set lastFlushed(DateTime value) {
    _store(_keyLastFlushed, value.millisecondsSinceEpoch);

    _lastFlushed = value;
    notifyListeners();
  }

  TimeOfDay get flushAt => _flushAt;
  set flushAt(TimeOfDay value) {
    _store(_keyFlushAt, '${value.hour}:${value.minute}');

    _flushAt = value;
    notifyListeners();
  }

  bool get isHaptic => _isHptic;
  set isHaptic(bool value) {
    _store(_keyIsHaptic, value);
    _isHptic = value;
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
    debugPrint('settings info loading...');
    final preferences = await _prefs;

    _themeMode = ThemeMode
        .values[preferences.getInt(_keyThemeMode) ?? _defaultThemeMode.index];

    final rawFontColor = preferences.getInt(_keyFontColor);
    _fontColor = rawFontColor != null ? Color(rawFontColor) : null;

    final rawSelectedFontColorIndex =
        preferences.getInt(_keySelectedFontColorIndex);
    _selectedFontColorIndex = rawSelectedFontColorIndex ?? 0;

    final rawFontSize = preferences.getInt(_keyFontSize);
    _fontSize =
        rawFontSize != null ? FontSize.values[rawFontSize] : _defaultFontSize;

    final rawLastFlushed = preferences.getInt(_keyLastFlushed);
    _lastFlushed = rawLastFlushed != null
        ? DateTime.fromMillisecondsSinceEpoch(rawLastFlushed)
        : _defaultLastFlushed;

    final rawFlushAt = preferences.getString(_keyFlushAt);
    _flushAt = rawFlushAt != null
        ? TimeOfDay(
            hour: int.parse(rawFlushAt.split(':')[0]),
            minute: int.parse(rawFlushAt.split(':')[1]))
        : _defaultFlushAt;

    final rawIsHaptic = preferences.getBool(_keyIsHaptic);
    _isHptic = rawIsHaptic ?? false;

    notifyListeners();
  }
}

enum FontSize {
  small,
  medium,
  large;
}
