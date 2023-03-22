import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/theme/dark_theme.dart';
import 'package:simple_todo/theme/light_theme.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  bool _isDark(ThemeMode themeMode) {
    return themeMode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = context.watch<SettingsModel>().themeMode;
    return SvgPicture.asset(
      'assets/logo.svg',
      colorFilter: ColorFilter.mode(
        _isDark(themeMode)
            ? darkColorScheme.onPrimaryContainer
            : lightColorScheme.onPrimaryContainer,
        BlendMode.srcIn,
      ),
    );
  }
}
