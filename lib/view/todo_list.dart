import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.list,
    required this.onReorder,
  });

  final UnmodifiableListView<Todo> list;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ReorderableListView.builder(
        itemBuilder: (context, index) {
          final item = list[index];

          return TodoItem(
            key: ValueKey(item),
            item: item,
          );
        },
        itemCount: list.length,
        onReorderStart: (index) => HapticFeedback.lightImpact(),
        onReorder: onReorder,
        shrinkWrap: true,
      ),
    );
  }
}
