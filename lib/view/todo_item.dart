import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/utils/swipeable.dart';

import '../models/todo.dart';
import '../utils/text.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.item,
    required this.onEdit,
  });

  final Todo item;
  final void Function(Todo item) onEdit;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final model = context.read<TodoModel>();
    final fontSize =
        context.select<SettingsModel, FontSize>((model) => model.fontSize);

    final TextStyle style = _getTextStyle(context, item.archived, fontSize);

    final Size textSize = getTextSize(item.content, style);

    final content = ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CustomPaint(
          foregroundPainter: item.archived
              ? TextLinePainter(context: context, textSize: textSize)
              : null,
          child: Text(
            item.content,
            style: style,
            maxLines: 1,
          ),
        ),
      ),
    );

    return Swipeable(
      resizeDuration: null, // resize will be taken care by list view
      onSwiped: (swipeDirection) async {
        if (swipeDirection == SwipeDirection.right) {
          model.setArchived(item: item, archived: !item.archived);
        } else if (swipeDirection == SwipeDirection.left) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();

          final marked = model.markRemoval(item: item, remove: true);
          final controller = messenger.showSnackBar(
            SnackBar(
              content: Text(t.todoItemRemovedLabel),
              behavior: SnackBarBehavior.floating,
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
      onEditPressed: () => onEdit(item),
      child: content,
    );
  }

  TextStyle _getTextStyle(
      BuildContext context, bool disabled, FontSize fontSize) {
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

    if (disabled) {
      style = style.copyWith(color: theme.disabledColor);
    }
    return style;
  }
}

class TextLinePainter extends CustomPainter {
  const TextLinePainter({required this.context, required this.textSize});

  final BuildContext context;
  final Size textSize;

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final p1 = Offset(0, textSize.height / 2);
    final p2 = Offset(textSize.width > size.width ? size.width : textSize.width,
        textSize.height / 2);
    final paint = Paint()
      ..color = theme.disabledColor
      ..strokeWidth = 1;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(TextLinePainter oldDelegate) {
    return oldDelegate.textSize != textSize;
  }
}
