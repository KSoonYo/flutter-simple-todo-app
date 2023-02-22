import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.list,
    this.onReorder,
  }) : frozen = false;

  const TodoList.frozen({super.key, required this.list})
      : onReorder = null,
        frozen = true;

  final UnmodifiableListView<Todo> list;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !frozen
          ? list.isNotEmpty
              ? ReorderableListView.builder(
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return TodoItem(
                      key: ValueKey(item),
                      item: item,
                    );
                  },
                  itemCount: list.length,
                  onReorderStart: (index) => HapticFeedback.lightImpact(),
                  onReorder: (oldIndex, newIndex) {
                    onReorder?.call(oldIndex, newIndex);
                  },
                  shrinkWrap: true,
                )
              : Text(
                  'Empty Dumpty!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (var i = 0; i < list.length; i++)
                  TodoItem(
                    item: list[i],
                    enabled: false,
                  )
              ],
            ),
    );
  }
}
