import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart';
import 'models/todo.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'theme/text.dart';
import 'view/todo_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoModel()),
        ChangeNotifierProvider(create: (context) => SettingsModel()),
      ],
      builder: (context, child) {
        return const SimpleTodoApp();
      },
    ),
  );
}

class SimpleTodoApp extends StatelessWidget {
  const SimpleTodoApp({super.key});
  static const _snackBarThemeData =
      SnackBarThemeData(behavior: SnackBarBehavior.floating);

  @override
  Widget build(BuildContext context) {
    final themeMode = context
        .select<SettingsModel, ThemeMode>((settings) => settings.themeMode);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        selectedLightColorScheme = lightDynamic;
        selectedDarkColorScheme = darkDynamic;
        return MaterialApp(
          title: 'Simple Todo',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            snackBarTheme: _snackBarThemeData,
            colorScheme: selectedLightColorScheme,
            textTheme: textTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            snackBarTheme: _snackBarThemeData,
            colorScheme: selectedDarkColorScheme,
            textTheme: textTheme,
          ),
          themeMode: themeMode,
          home: const TodoScreen(),
        );
      },
    );
  }
}
