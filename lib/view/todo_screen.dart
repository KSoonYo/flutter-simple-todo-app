import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/view/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/todo.dart';
import 'shake.dart';
import 'todo_input_screen.dart';
import 'todo_list.dart';
import 'vertical_pullable.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin {
  Offset _listOffset = Offset.zero;
  late AnimatedListController _todoListController;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _todoListController = AnimatedListController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = _animationController
        .drive(CurveTween(curve: Shake()))
        .drive(Animatable.fromCallback((value) => Offset(value * 0.01, 0)));
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void _showList(bool show) {
    setState(() {
      _listOffset = Offset(show ? 0 : -1, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoModel = context.watch<TodoModel>();
    todoModel.initialize(AppLocalizations.of(context)!);

    final settingsModel = context.watch<SettingsModel>();
    bool outdated =
        _isOutdated(settingsModel.flushAt, settingsModel.lastFlushed);

    return Scaffold(
      body: SafeArea(
        child: VerticalPullable(
          onPullDown: () async {
            if (outdated) return;
            if (todoModel.isFull) {
              _animationController
                  .forward()
                  .then((_) => _animationController.reset());

              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(const SnackBar(content: Text('FULL')));

              return;
            }

            final content = await showTodoInput(context: context);

            if (content != null && content.isNotEmpty) {
              todoModel.add(content);
            }
          },
          onPullUp: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SettingsScreen(),
              isScrollControlled: true,
              useSafeArea: true),
          child: outdated
              ? AnimatedSlide(
                  offset: _listOffset,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 300),
                  onEnd: () {
                    todoModel.clear();
                    settingsModel.lastFlushed = DateTime.now();
                    _showList(true);
                  },
                  child: TodoList.frozen(list: todoModel.list),
                )
              : SlideTransition(
                  position: _animation,
                  child: TodoList(
                    list: todoModel.list,
                    controller: _todoListController,
                  ),
                ),
        ),
      ),
      floatingActionButton: outdated
          ? FloatingActionButton.extended(
              onPressed: () {
                _showList(false);
              },
              label: const Text('🚽🧻🪠'),
            )
          : null,
    );
  }

  bool _isOutdated(TimeOfDay flushAt, DateTime lastFlushed) {
    final now = DateTime.now();
    final flush = now.copyWith(
      hour: flushAt.hour,
      minute: flushAt.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    return now.isAfter(flush) && lastFlushed.isBefore(flush);
  }

  Future<String?> showTodoInput({required BuildContext context}) {
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
