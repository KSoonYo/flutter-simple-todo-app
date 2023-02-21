import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/view/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/todo.dart';
import 'todo_input_screen.dart';
import 'todo_list.dart';
import 'vertical_pullable.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoModel = context.watch<TodoModel>();
    todoModel.initialize(AppLocalizations.of(context)!);

    final settingsModel = context.watch<SettingsModel>();
    final flushAt = settingsModel.flushAt;
    final lastFlushed = settingsModel.lastFlushed;

    bool shouldFlush = true; //_shouldFlush(flushAt, lastFlushed);

    return Scaffold(
      body: SafeArea(
        child: VerticalPullable(
          onPullDown: () => showTodoInput(
            context: context,
          ),
          onPullUp: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SettingsScreen(),
              isScrollControlled: true,
              useSafeArea: true),
          child: shouldFlush
              ? TodoList.frozen(list: todoModel.list)
              : TodoList(
                  list: todoModel.list,
                  onReorder: todoModel.moveItem,
                ),
        ),
      ),
      floatingActionButton: shouldFlush
          ? FloatingActionButton.extended(
              onPressed: () {
                todoModel.clear();
              },
              label: const Text('🚽🧻🪠'),
            )
          : null,
    );
  }

  bool _shouldFlush(TimeOfDay flushAt, DateTime lastFlushed) {
    final now = DateTime.now();
    final flush = now.copyWith(
      hour: flushAt.hour,
      minute: flushAt.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    final shouldFlush = now.isAfter(flush) && lastFlushed.isBefore(flush);
    return shouldFlush;
  }

  Future<T?> showTodoInput<T>({required BuildContext context}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          return const TodoInputScreen();
        },
        transitionsBuilder: (_, animation, ___, child) {
          return AnimatedSlide(
            offset: Offset(0, -1 + animation.value),
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastLinearToSlowEaseIn,
            child: child,
          );
        },
      ),
    );
  }
}
