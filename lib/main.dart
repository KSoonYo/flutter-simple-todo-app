import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final color = settings.color;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Nothing To Do',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: color,
            colorScheme: color == null ? lightDynamic : null,
            platform: TargetPlatform.android,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: color,
            colorScheme: color == null ? darkDynamic : null,
            platform: TargetPlatform.android,
          ),
          themeMode: themeMode,
          home: const TodoScreen(),
        );
      },
    );
  }
}
