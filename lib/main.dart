import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/theme/dark_theme.dart';

import 'theme/light_theme.dart';
import 'models/settings.dart';
import 'models/todo.dart';
import 'view/todo_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoModel()),
        ChangeNotifierProvider(create: (context) => SettingsModel()),
      ],
      child: SimpleTodoApp(),
    ),
  );
}

class SimpleTodoApp extends StatelessWidget {
  SimpleTodoApp({super.key});
  static const _defaultLightColorScheme = lightColorScheme;
  static const _defaultDarkColorScheme = darkColorScheme;
  final _baseThemeData = ThemeData(
    useMaterial3: true,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final themeMode = settings.themeMode;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Simple Todo',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: _baseThemeData.copyWith(
            colorScheme: lightDynamic ?? _defaultLightColorScheme,
          ),
          darkTheme: _baseThemeData.copyWith(
            colorScheme: darkDynamic ?? _defaultDarkColorScheme,
          ),
          themeMode: themeMode,
          home: const TodoScreen(),
        );
      },
    );
  }
}
