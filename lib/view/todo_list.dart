import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';

import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    required this.list,
    this.controller,
  }) : frozen = false;

  const TodoList.frozen({super.key, required this.list})
      : frozen = true,
        controller = null;

  final UnmodifiableListView<Todo> list;
  final bool frozen;
  final AnimatedListController? controller;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> with TickerProviderStateMixin {
  late AnimatedListController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? AnimatedListController();
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.list.where((i) => !i.toRemove).toList();

    var theme = Theme.of(context);
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
              addLongPressReorderable: !widget.frozen,
              itemBuilder: (context, element, data) {
                return TodoItem(
                  item: element,
                  enabled: !widget.frozen,
                );
              },
            )
          : Text(
              '🌝Empty🌚Dumpty!',
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
    );
  }
}
