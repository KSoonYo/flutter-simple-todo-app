import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final t = AppLocalizations.of(context)!;

    final model = context.read<TodoModel>();
    final fontSize =
        context.select<SettingsModel, FontSize>((model) => model.fontSize);

    final content = ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          item.content,
          style: _getTextStyle(context, enabled, fontSize),
          maxLines: 2,
        ),
      ),
    );

    return enabled
        ? Swipeable(
            onSwiped: (swipeDirection) async {
              if (swipeDirection == SwipeDirection.right) {
                model.setArchived(item: item, archived: true);
              } else if (swipeDirection == SwipeDirection.left) {
                final marked = model.markRemoval(item: item, remove: true);

                final messenger = ScaffoldMessenger.of(context);
                final controller = messenger.showSnackBar(
                  SnackBar(
                    content: Text(t.todoItemRemovedLabel),
                    action: SnackBarAction(
                      label: t.todoItemUndoRemoval,
                      onPressed: () {
                        model.markRemoval(item: marked, remove: false);
                        messenger.hideCurrentSnackBar(
                          reason: SnackBarClosedReason.action,
                        );
                      },
                    ),
                  ),
                );

                final reason = await controller.closed;
                if (reason != SnackBarClosedReason.action) {
                  model.remove(item: item);
                }
              }
            },
            child: content,
          )
        : content;
  }

  TextStyle _getTextStyle(
      BuildContext context, bool enabled, FontSize fontSize) {
    final theme = Theme.of(context);

    TextStyle style;

    switch (fontSize) {
      case FontSize.small:
        style = theme.textTheme.headlineSmall!;
        break;
      case FontSize.medium:
        style = theme.textTheme.headlineMedium!;
        break;
      case FontSize.large:
        style = theme.textTheme.headlineLarge!;
        break;
      default:
        throw UnsupportedError('Unsupported font size $fontSize');
    }

    if (!enabled) {
      style = style.copyWith(color: theme.disabledColor);
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
