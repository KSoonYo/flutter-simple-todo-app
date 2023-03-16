import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/view/settings_list.dart';

import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsModel model = context.watch<SettingsModel>();

    return Scaffold(
      body: Center(
        child: SafeArea(
            child: SettingsList(
          themeMode: model.themeMode,
          fontColor: model.fontColor,
          selectedFontColorIndex: model.selectedFontColorIndex,
          fontSize: model.fontSize,
          flushAt: model.flushAt,
          isHaptic: model.hapticEnabled,
          onChange: (detail) {
            model.themeMode = detail.themeMode;
            model.fontColor = detail.fontColor;
            model.selectedFontColorIndex = detail.selectedFontColorIndex;
            model.fontSize = detail.fontSize;
            model.flushAt = detail.flushAt;
            model.hapticEnabled = detail.hapticEnabled;
          },
        )),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
