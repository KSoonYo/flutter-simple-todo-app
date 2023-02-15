import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.item,
  });

  final Todo item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.content,
        style: Theme.of(context).textTheme.headlineLarge,
        maxLines: 1,
      ),
      onTap: () => context.showSnackBar('Toasty!'),
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
