import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/view/settings_list.dart';

import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsModel model = context.watch<SettingsModel>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SafeArea(
            child: SettingsList(
          themeMode: model.themeMode,
          fontColor: model.fontColor,
          fontSize: model.fontSize,
          flushAt: model.flushAt,
          isHaptic: model.isHaptic,
          onChange: (detail) {
            model.themeMode = detail.themeMode;
            model.fontColor = detail.fontColor;
            model.fontSize = detail.fontSize;
            model.flushAt = detail.flushAt;
            model.isHaptic = detail.isHaptic;
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
