import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart';
import 'models/todo.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'view/todo_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoModel()),
        ChangeNotifierProvider(create: (context) => SettingsModel()),
      ],
      child: const SimpleTodoApp(),
    ),
  );
}

class SimpleTodoApp extends StatelessWidget {
  const SimpleTodoApp({super.key});
  static const _defaultLightColorScheme = lightColorScheme;
  static const _defaultDarkColorScheme = darkColorScheme;
  static const _snackBarThemeData =
      SnackBarThemeData(behavior: SnackBarBehavior.floating);

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
          theme: ThemeData(
              useMaterial3: true,
              snackBarTheme: _snackBarThemeData,
              colorScheme: lightDynamic ?? _defaultLightColorScheme,
              textTheme: TextTheme(
                  headlineSmall: TextStyle(
                      color: settings.fontColor, fontWeight: FontWeight.w600),
                  headlineMedium: TextStyle(
                      color: settings.fontColor, fontWeight: FontWeight.w600),
                  headlineLarge: TextStyle(
                      color: settings.fontColor, fontWeight: FontWeight.w600),
                  titleLarge: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                  labelLarge: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  bodyLarge: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  bodyMedium: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
          darkTheme: ThemeData(
              useMaterial3: true,
              snackBarTheme: _snackBarThemeData,
              colorScheme: darkDynamic ?? _defaultDarkColorScheme,
              textTheme: TextTheme(
                  headlineSmall: TextStyle(
                      color: settings.fontColor, fontWeight: FontWeight.w600),
                  headlineMedium: TextStyle(
                      color: settings.fontColor, fontWeight: FontWeight.w600),
                  headlineLarge: TextStyle(
                      color: settings.fontColor, fontWeight: FontWeight.w600),
                  titleLarge: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                  labelLarge: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  bodyLarge: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  bodyMedium: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
          themeMode: themeMode,
          home: const TodoScreen(),
        );
      },
    );
  }
}
