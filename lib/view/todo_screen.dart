import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final model = context.watch<TodoModel>();
    model.initialize(AppLocalizations.of(context)!);

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
          child: TodoList(
            list: model.list,
            onReorder: model.moveItem,
          ),
        ),
      ),
    );
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
