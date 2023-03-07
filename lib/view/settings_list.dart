import 'package:flutter/material.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_svg/svg.dart';

typedef ChangeSettingsCallback = void Function(ChangeSettingsDetail detail);

class SettingsList extends StatefulWidget {
  const SettingsList({
    super.key,
    required this.fontColor,
    required this.fontSize,
    required this.flushAt,
    this.isHaptic = false,
    this.themeMode = ThemeMode.light,
    this.onChange,
  });

  final ThemeMode? themeMode;
  final Color? fontColor;
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
    this.isHaptic = false,
    this.themeMode = ThemeMode.light,
  });
  final ThemeMode themeMode;
  final Color fontColor;
  final FontSize fontSize;
  final TimeOfDay flushAt;
  final bool isHaptic;

  ChangeSettingsDetail copyWith(
      {ThemeMode? themeMode,
      Color? fontColor,
      FontSize? fontSize,
      TimeOfDay? flushAt,
      bool? isHaptic}) {
    return ChangeSettingsDetail(
        themeMode: themeMode ?? this.themeMode,
        fontColor: fontColor ?? this.fontColor,
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
        fontColor: widget.fontColor!,
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
      theme.colorScheme.tertiary,
      theme.colorScheme.copyWith(primary: const Color(0xff7889f1)).primary,
      theme.colorScheme.copyWith(secondary: const Color(0xff8d8fa6)).secondary
    ];
  }

  void _handleChangedSettings(ChangeSettingsDetail? newDetails) {
    if (newDetails == null) return;
    if (widget.onChange != null) {
      widget.onChange?.call(newDetails);
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
            shrinkWrap: true,
            children: <Widget>[
              widget.themeMode == ThemeMode.dark
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
                    _handleChangedSettings(
                        _settingsDetail?.copyWith(themeMode: selected.first));
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
                      for (Color color in colorPallet)
                        GestureDetector(
                          onTap: () {
                            _handleChangedSettings(
                                _settingsDetail?.copyWith(fontColor: color));
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
                              child: _settingsDetail!.fontColor == color
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
