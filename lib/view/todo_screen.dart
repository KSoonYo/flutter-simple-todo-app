import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/view/settings_screen.dart';
import 'package:simple_todo/view/todo_input.dart';

import '../models/todo.dart';
import 'todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  var _editing = false;

  void _setEditing(bool value) {
    setState(() {
      _editing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TodoModel>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            VerticalSwiper(
              onPullDown: () => _setEditing(true),
              onPullUp: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                  fullscreenDialog: true,
                ),
              ),
              child: TodoList(
                list: model.active,
                onReorder: model.moveItem,
              ),
            ),
            AnimatedOpacity(
              opacity: _editing ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn,
              child: Stack(
                children: [
                  if (_editing)
                    ModalBarrier(
                      color: Theme.of(context).dialogBackgroundColor,
                      onDismiss: () => _setEditing(false),
                    ),
                  AnimatedSlide(
                    offset: _editing ? const Offset(0, 0) : const Offset(0, -1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: Column(
                      children: [
                        TodoInput(
                          onSubmit: (value) {
                            model.addItem(value);
                            _setEditing(false);
                          },
                          onCancel: () => _setEditing(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerticalSwiper extends StatelessWidget {
  const VerticalSwiper({
    super.key,
    this.onPullDown,
    this.onPullUp,
    required this.child,
  });

  final void Function()? onPullDown;
  final void Function()? onPullUp;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: onPullDown != null || onPullUp != null
          ? (details) {
              final velocity = details.primaryVelocity;

              if (velocity == null || velocity.abs() < 400) return;

              if (velocity > 0) {
                onPullDown?.call();
              } else {
                onPullUp?.call();
              }
            }
          : null,
      child: child,
    );
  }
}

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
