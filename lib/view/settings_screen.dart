import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsModel model = context.watch<SettingsModel>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(
              height: 72,
              child: ListTile(title: Text(t.settingsThemeModeTitle)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: SegmentedButton<ThemeMode>(
                segments: <ButtonSegment<ThemeMode>>[
                  for (var themeMode in ThemeMode.values)
                    ButtonSegment(
                      value: themeMode,
                      label: Text(t.settingsThemeModeValue(themeMode.name)),
                    ),
                ],
                showSelectedIcon: true,
                selected: {model.themeMode},
                onSelectionChanged: (selected) {
                  model.themeMode = selected.first;
                },
              ),
            ),
            SizedBox(
              height: 72,
              child: Center(
                child: ListTile(title: Text(t.settingsFontColorTitle)),
              ),
            ),
            const Placeholder(fallbackHeight: 72),
            SizedBox(
              height: 72,
              child: Center(
                child: ListTile(title: Text(t.settingsFontSizeTitle)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: SegmentedButton<FontSize>(
                segments: <ButtonSegment<FontSize>>[
                  for (var fontSize in FontSize.values)
                    ButtonSegment(
                      value: fontSize,
                      label: Text(t.settingsFontSizeValue(fontSize.name)),
                    ),
                ],
                showSelectedIcon: true,
                selected: {model.fontSize},
                onSelectionChanged: (selected) {
                  model.fontSize = selected.first;
                },
              ),
            ),
            SizedBox(
              height: 88,
              child: Center(
                child: ListTile(
                  title: Text(t.settingsSoundTitle),
                  subtitle: Text(t.settingsSoundSubtitle),
                  trailing: Switch.adaptive(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 88,
              child: Center(
                child: ListTile(
                  title: Text(t.settingsHapticTitle),
                  subtitle: Text(t.settingsHapticSubtitle),
                  trailing: Switch.adaptive(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
