import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsModel model = context.watch<SettingsModel>();
    final t = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    final List<Color> colorPallet = [
      theme.colorScheme.onSurface,
      theme.colorScheme.copyWith(primary: const Color(0xff4455ba)).primary,
      theme.colorScheme.copyWith(secondary: const Color(0xff5b5d72)).secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.copyWith(primary: const Color(0xff7889f1)).primary,
      theme.colorScheme.copyWith(secondary: const Color(0xff8d8fa6)).secondary
    ];

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 86),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    model.themeMode == ThemeMode.dark
                        ? SvgPicture.asset('assets/logo_dark.svg')
                        : SvgPicture.asset('assets/logo.svg'),
                    SizedBox(
                      height: 72,
                      child: ListTile(
                          title: Text(
                        t.settingsThemeModeTitle,
                        style: theme.textTheme.titleLarge,
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 20),
                      child: SegmentedButton<ThemeMode>(
                        segments: <ButtonSegment<ThemeMode>>[
                          for (var themeMode in ThemeMode.values)
                            if (themeMode != ThemeMode.system)
                              ButtonSegment(
                                value: themeMode,
                                label: Text(
                                  t.settingsThemeModeValue(themeMode.name),
                                  style: theme.textTheme.labelLarge,
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
                    SizedBox(
                      height: 72,
                      child: Center(
                        child: ListTile(
                            title: Text(t.settingsFontColorTitle,
                                style: theme.textTheme.titleLarge)),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 16, bottom: 16),
                        child: Row(
                          children: [
                            for (Color color in colorPallet)
                              GestureDetector(
                                onTap: () {
                                  model.fontColor = color;
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: theme.colorScheme.outline),
                                      shape: BoxShape.circle,
                                      color: color),
                                  child: model.fontColor == color
                                      ? Icon(Icons.check,
                                          color: theme
                                              .colorScheme.onInverseSurface)
                                      : null,
                                ),
                              )
                          ],
                        )),
                    SizedBox(
                      height: 72,
                      child: Center(
                        child: ListTile(
                            title: Text(t.settingsFontSizeTitle,
                                style: theme.textTheme.titleLarge)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 20),
                      child: SegmentedButton<FontSize>(
                        segments: <ButtonSegment<FontSize>>[
                          for (var fontSize in FontSize.values)
                            ButtonSegment(
                              value: fontSize,
                              label: Text(
                                t.settingsFontSizeValue(fontSize.name),
                                style: theme.textTheme.labelLarge,
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
                          title: Text(t.settingsFlushAtTitle,
                              style: theme.textTheme.titleLarge),
                          trailing: Text(
                            model.flushAt.format(context),
                            style: theme.textTheme.bodyLarge!
                                .copyWith(color: theme.colorScheme.surfaceTint),
                          ),
                          onTap: () async {
                            final tod = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.dialOnly,
                              initialTime: model.flushAt,
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                );
                              },
                            );

                            if (tod != null) {
                              model.flushAt = tod;
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 88,
                      child: Center(
                        child: ListTile(
                          title: Text(t.settingsHapticTitle,
                              style: theme.textTheme.titleLarge),
                          subtitle: Text(t.settingsHapticSubtitle),
                          trailing: Switch(
                            value: model.isHaptic,
                            onChanged: (value) {
                              model.isHaptic = value;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
