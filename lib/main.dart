import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart';
import 'models/todo.dart';
import 'view/todo_screen.dart';

void main() {
  debugPrintGestureArenaDiagnostics = true;
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
            colorScheme: lightDynamic,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic,
          ),
          themeMode: themeMode,
          home: const TodoScreen(),
        );
      },
    );
  }
}
