import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/view/settings_screen.dart';
import 'package:simple_todo/view/todo_input.dart';

import '../models/todo.dart';
import 'todo_list.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TodoModel>();

    return Scaffold(
      body: SafeArea(
        child: VerticalSwiper(
          onPullDown: () => Navigator.of(context).push(
            _TodoInputRoute(),
          ),
          onPullUp: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SettingsScreen(),
              isScrollControlled: true,
              useSafeArea: true),
          child: TodoList(
            list: model.list,
            onReorder: model.moveItem,
          ),
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

class _TodoInputRoute extends PopupRoute {
  @override
  Color? get barrierColor => const Color.fromRGBO(0, 0, 0, 0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final model = context.read<TodoModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TodoInput(
            onSubmit: (value) {
              model.addItem(value);
              Navigator.pop(context);
            },
            // onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedSlide(
      offset: Offset(0, -0.5 + animation.value / 2),
      duration: transitionDuration,
      curve: Curves.fastLinearToSlowEaseIn,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
}
