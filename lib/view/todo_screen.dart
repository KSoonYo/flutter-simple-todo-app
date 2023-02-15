import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/view/todo_input.dart';

import '../models/todo.dart';
import 'settings_screen.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TodoModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Todo'),
        centerTitle: true,
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
        header: TodoInput(onSubmit: model.addItem),
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
