import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import 'color_picker_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsModel model = context.watch<SettingsModel>();
    final Color color = model.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: <ButtonSegment<ThemeMode>>[
                for (var themeMode in ThemeMode.values)
                  ButtonSegment(
                    value: themeMode,
                    label: Text(
                      themeMode.name.capitalize(),
                    ),
                  ),
              ],
              showSelectedIcon: false,
              selected: {model.themeMode},
              onSelectionChanged: (selected) {
                model.themeMode = selected.first;
              },
            ),
          ),
          ListTile(
            title: const Text('Color'),
            trailing: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ColorPickerDialog(
                    initialColor: color,
                    onPick: (color) => model.color = color,
                  ),
                );
              },
              child: SizedBox.square(
                dimension: 20.0,
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
