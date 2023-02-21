import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/utils/swipeable.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.item,
    this.enabled = true,
  });

  final Todo item;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final model = context.read<TodoModel>();
    final fontSize =
        context.select<SettingsModel, FontSize>((model) => model.fontSize);

    return Swipeable(
      onSwiped: enabled
          ? (swipeDirection) {
              if (swipeDirection == SwipeDirection.right) {
                model.archiveItem(item: item);
              } else if (swipeDirection == SwipeDirection.left) {
                model.removeItem(item: item);
              }
            }
          : null,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            item.content,
            style: _getTextStyle(context, enabled, fontSize),
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  TextStyle? _getTextStyle(
      BuildContext context, bool enabled, FontSize fontSize) {
    final textTheme = Theme.of(context).textTheme;

    late TextStyle? style;

    switch (fontSize) {
      case FontSize.small:
        style = textTheme.headlineSmall;
        break;
      case FontSize.medium:
        style = textTheme.headlineMedium;
        break;
      case FontSize.large:
        style = textTheme.headlineLarge;
        break;
    }

    return style;
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
