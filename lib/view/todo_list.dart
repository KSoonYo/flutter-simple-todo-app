import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    required this.list,
    required this.onEdit,
    this.controller,
  });

  final UnmodifiableListView<Todo> list;
  final AnimatedListController? controller;
  final void Function(Todo item) onEdit;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> with TickerProviderStateMixin {
  late AnimatedListController _controller;
  late bool outdated;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? AnimatedListController();

    final settingsModel = context.read<SettingsModel>();
    outdated = _isOutdated(settingsModel);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    var theme = Theme.of(context);
    final visibleItems = widget.list.where((i) => !i.toRemove).toList();

    if (outdated) {
      outdated = false;

      final todoModel = context.read<TodoModel>();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t!.todoItemOutdated,
              style: theme.textTheme.bodyLarge!
                  .copyWith(color: theme.colorScheme.onInverseSurface)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(days: 1),
          onVisible: () => todoModel.clear(),
        ),
      );
    }

    return Center(
      child: visibleItems.isNotEmpty
          ? AutomaticAnimatedListView<Todo>(
              comparator: AnimatedListDiffListComparator(
                sameItem: (a, b) => a.id == b.id,
                sameContent: (a, b) =>
                    a.content == b.content &&
                    a.archived == b.archived &&
                    a.toRemove == b.toRemove,
              ),
              reorderModel: AutomaticAnimatedListReorderModel(visibleItems),
              shrinkWrap: true,
              list: visibleItems,
              listController: _controller,
              itemBuilder: (context, element, data) {
                return TodoItem(
                  item: element,
                  onEdit: widget.onEdit,
                );
              },
            )
          : Text(
              t!.todoItemHint,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
    );
  }

  bool _isOutdated(SettingsModel settingsModel) {
    final now = DateTime.now();
    final flush = now.copyWith(
      hour: settingsModel.flushAt.hour,
      minute: settingsModel.flushAt.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    return now.isAfter(flush) && settingsModel.lastFlushed.isBefore(flush);
  }
}
