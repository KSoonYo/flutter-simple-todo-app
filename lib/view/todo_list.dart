import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList(
      {super.key, required this.list, this.onReorder, this.addAnimation})
      : frozen = false;

  const TodoList.frozen({super.key, required this.list})
      : onReorder = null,
        addAnimation = null,
        frozen = true;

  final UnmodifiableListView<Todo> list;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final bool frozen;
  final Animation<double>? addAnimation;

  @override
  Widget build(BuildContext context) {
    int newItemIndex = list.length - 1;
    return Center(
      child: !frozen
          ? list.isNotEmpty
              ? ReorderableListView(
                  onReorderStart: (index) => HapticFeedback.lightImpact(),
                  onReorder: (oldIndex, newIndex) {
                    onReorder?.call(oldIndex, newIndex);
                  },
                  shrinkWrap: true,
                  children: [
                    for (var item in list.where((i) => !i.toRemove))
                      _buildListItem(
                          addAnimation, list.indexOf(item), newItemIndex, item)
                  ],
                )
              : Text(
                  'Empty Dumpty!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (var item in list)
                  TodoItem(
                    item: item,
                    enabled: false,
                  )
              ],
            ),
    );
  }
}

Widget _buildListItem(
    Animation<double>? animation, int index, int newIndex, Todo item) {
  if (animation != null && animation.value > 0 && index == newIndex) {
    return AnimatedBuilder(
        key: ValueKey(item),
        animation: animation,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            child: SizedBox(
                child: TodoItem(
              key: ValueKey(item),
              item: item,
            )),
          );
        });
  }
  return TodoItem(
    key: ValueKey(item),
    item: item,
  );
}
