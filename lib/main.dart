import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart';
import 'models/todo.dart';
import 'view/settings_screen.dart';

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
          home: const Home(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TodoModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            key: ValueKey(model.active[index]),
            title: Text(model.active[index].content),
            onTap: () => context.showSnackBar('Toasty!'),
          );
        },
        itemCount: model.active.length,
        onReorder: (oldIndex, newIndex) => model.moveItem(oldIndex, newIndex),
      ),
    );
  }
}

extension SnackBarExtension on BuildContext {
  void showSnackBar(String content) {
    final messenger = ScaffoldMessenger.of(this);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }
}
