import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/utils/swipeable.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.item,
  });

  final Todo item;

  @override
  Widget build(BuildContext context) {
    final model = context.read<TodoModel>();

    return Swipeable(
      onSwiped: (swipeDirection) {
        if (swipeDirection == SwipeDirection.right) {
          model.archiveItem(item: item);
        } else if (swipeDirection == SwipeDirection.left) {
          model.removeItem(item: item);
        }
      },
      child: ListTile(
        title: Text(
          item.content,
          style: Theme.of(context).textTheme.headlineLarge,
          maxLines: 1,
        ),
        onTap: () => context.showSnackBar('Toasty!'),
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
