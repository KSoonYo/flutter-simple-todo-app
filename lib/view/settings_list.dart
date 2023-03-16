import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/settings.dart';
import '../theme/dark_theme.dart';
import '../theme/light_theme.dart';
import 'logo.dart';

typedef ChangeSettingsCallback = void Function(ChangeSettingsDetail detail);

class SettingsList extends StatefulWidget {
  const SettingsList({
    super.key,
    required this.fontColor,
    required this.fontSize,
    required this.flushAt,
    this.selectedFontColorIndex = 0,
    this.isHaptic = false,
    this.themeMode = ThemeMode.light,
    this.onChange,
  });

  final ThemeMode? themeMode;
  final Color? fontColor;
  final int selectedFontColorIndex;
  final FontSize? fontSize;
  final TimeOfDay? flushAt;
  final bool? isHaptic;

  final ChangeSettingsCallback? onChange;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class ChangeSettingsDetail {
  ChangeSettingsDetail({
    required this.fontColor,
    required this.fontSize,
    required this.flushAt,
    this.selectedFontColorIndex = 0,
    this.isHaptic = false,
    this.themeMode = ThemeMode.light,
  });
  final ThemeMode themeMode;
  final Color? fontColor;
  final int selectedFontColorIndex;
  final FontSize fontSize;
  final TimeOfDay flushAt;
  final bool isHaptic;

  ChangeSettingsDetail copyWith(
      {ThemeMode? themeMode,
      Color? fontColor,
      int? selectedFontColorIndex,
      FontSize? fontSize,
      TimeOfDay? flushAt,
      bool? isHaptic}) {
    return ChangeSettingsDetail(
        themeMode: themeMode ?? this.themeMode,
        fontColor: fontColor ?? this.fontColor,
        selectedFontColorIndex:
            selectedFontColorIndex ?? this.selectedFontColorIndex,
        fontSize: fontSize ?? this.fontSize,
        flushAt: flushAt ?? this.flushAt,
        isHaptic: isHaptic ?? this.isHaptic);
  }
}

class _SettingsListState extends State<SettingsList> {
  ChangeSettingsDetail? _settingsDetail;
  @override
  void initState() {
    super.initState();
    _settingsDetail = ChangeSettingsDetail(
        fontColor: widget.fontColor,
        selectedFontColorIndex: widget.selectedFontColorIndex,
        fontSize: widget.fontSize!,
        flushAt: widget.flushAt!,
        isHaptic: widget.isHaptic!,
        themeMode: widget.themeMode!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Color> _getColorPallet(ThemeData theme) {
    return [
      theme.colorScheme.onSurface,
      theme.colorScheme.copyWith(primary: const Color(0xff4455ba)).primary,
      theme.colorScheme.copyWith(secondary: const Color(0xff5b5d72)).secondary,
      theme.colorScheme.copyWith(tertiary: const Color(0xff77536d)).tertiary,
      theme.colorScheme.copyWith(primary: const Color(0xff7889f1)).primary,
      theme.colorScheme.copyWith(secondary: const Color(0xff8d8fa6)).secondary
    ];
  }

  void _handleChangedSettings(ChangeSettingsDetail? newDetails) {
    if (newDetails == null) return;
    if (widget.onChange != null) {
      widget.onChange?.call(newDetails);
      _settingsDetail = newDetails;
      return;
    }

    setState(() {
      _settingsDetail = newDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    List<Color> colorPallet = _getColorPallet(theme);

    return Column(
      children: [
        const SizedBox(height: 86),
        Expanded(
          child: ListView(
            // Ensure the parent widget is always scrollable regardless of this child list view physics.
            // because the ancestor widget is NotificationListener for listening over scroll notifications.
            // that need a scrollable child widget with no clamping scroll boundary.
            physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            shrinkWrap: true,
            children: <Widget>[
              const Logo(),
              SizedBox(
                height: 72,
                child: ListTile(
                    title: Text(
                  t.settingsThemeModeTitle,
                  style: theme.textTheme.titleLarge,
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
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
                  selected: {widget.themeMode!},
                  onSelectionChanged: (selected) {
                    // TODO: consider if there is another way to manage "colorPallet"
                    if (selected.first == ThemeMode.light) {
                      colorPallet[0] = selectedLightColorScheme.onSurface;
                    } else {
                      colorPallet[0] = selectedDarkColorScheme.onSurface;
                    }
                    ScaffoldMessenger.of(context).clearSnackBars();
                    _handleChangedSettings(_settingsDetail?.copyWith(
                        themeMode: selected.first,
                        fontColor: colorPallet[widget.selectedFontColorIndex]));
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
                  padding:
                      const EdgeInsets.only(left: 20, right: 16, bottom: 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < colorPallet.length; i++)
                        GestureDetector(
                          onTap: () {
                            if (_settingsDetail!.fontColor != colorPallet[i]) {
                              _handleChangedSettings(_settingsDetail?.copyWith(
                                  fontColor: colorPallet[i],
                                  selectedFontColorIndex: i));
                            }
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
                                  color: colorPallet[i]),
                              child: _settingsDetail!.selectedFontColorIndex ==
                                      i
                                  ? Icon(Icons.check,
                                      color: theme.colorScheme.onInverseSurface)
                                  : null),
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
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
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
                  selected: {widget.fontSize!},
                  onSelectionChanged: (selected) {
                    _handleChangedSettings(
                        _settingsDetail?.copyWith(fontSize: selected.first));
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
                      widget.flushAt!.format(context),
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.colorScheme.surfaceTint),
                    ),
                    onTap: () async {
                      final tod = await showTimePicker(
                        context: context,
                        initialEntryMode: TimePickerEntryMode.dialOnly,
                        initialTime: widget.flushAt!,
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );

                      if (tod != null) {
                        _handleChangedSettings(
                            _settingsDetail?.copyWith(flushAt: tod));
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
                      value: widget.isHaptic!,
                      onChanged: (value) {
                        if (value) HapticFeedback.vibrate();
                        _handleChangedSettings(
                            _settingsDetail?.copyWith(isHaptic: value));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
