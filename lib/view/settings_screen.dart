import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsModel model = context.watch<SettingsModel>();

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const SizedBox(
              height: 72,
              child: ListTile(title: Text('Theme')),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: SegmentedButton<ThemeMode>(
                segments: <ButtonSegment<ThemeMode>>[
                  for (var themeMode in ThemeMode.values)
                    ButtonSegment(
                      value: themeMode,
                      label: Text(
                        themeMode.name.capitalize(),
                      ),
                    ),
                ],
                showSelectedIcon: true,
                selected: {model.themeMode},
                onSelectionChanged: (selected) {
                  model.themeMode = selected.first;
                },
              ),
            ),
            const SizedBox(
              height: 72,
              child: Center(
                child: ListTile(title: Text('Font Color')),
              ),
            ),
            const Placeholder(fallbackHeight: 72),
            const SizedBox(
              height: 72,
              child: Center(
                child: ListTile(title: Text('Font Size')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: SegmentedButton<FontSize>(
                segments: <ButtonSegment<FontSize>>[
                  for (var fontSize in FontSize.values)
                    ButtonSegment(
                      value: fontSize,
                      label: Text(
                        fontSize.name.capitalize(),
                      ),
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
                  title: const Text('Sound'),
                  subtitle: const Text(
                    'Enable or disable sound on app actions',
                  ),
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
                  title: const Text('Haptic'),
                  subtitle: const Text(
                    'Enable or disable tactile feedbacks for app actions',
                  ),
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
