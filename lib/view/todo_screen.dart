import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/view/todo_input.dart';

import '../models/todo.dart';
import 'pull_to_reveal.dart';
import 'shake.dart';
import 'todo_input_screen.dart';
import 'todo_list.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  late PullToRevealController _pullToRevealController;
  late FocusNode _focusNode;
  late AnimatedListController _todoListController;
  late AnimationController _limitAnimationController;
  late Animation<Offset> _limitAnimation;
  late AnimationController _outdatedAnimationController;
  late Animation<Offset> _outdatedAnimation;

  @override
  void initState() {
    super.initState();
    _pullToRevealController = PullToRevealController();
    _todoListController = AnimatedListController();
    _focusNode = FocusNode();

    _limitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _limitAnimation = _limitAnimationController
        .drive(CurveTween(curve: Shake()))
        .drive(Animatable.fromCallback((value) => Offset(value * 0.01, 0)));

    _outdatedAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _outdatedAnimation = _outdatedAnimationController
        .drive(CurveTween(curve: Curves.fastOutSlowIn))
        .drive(Animatable.fromCallback((value) => Offset(-value, 0)));
  }

  @override
  void dispose() {
    _pullToRevealController.dispose();
    _focusNode.dispose();
    _limitAnimationController.dispose();
    _outdatedAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoModel = context.watch<TodoModel>();
    todoModel.initialize(AppLocalizations.of(context)!);

    final settingsModel = context.watch<SettingsModel>();
    bool outdated =
        _isOutdated(settingsModel.flushAt, settingsModel.lastFlushed);

    return Scaffold(
      body: PullToReveal(
        controller: _pullToRevealController,
        onReveal: () => _focusNode.requestFocus(),
        onHide: () => _focusNode.unfocus(),
        revealableChild: SafeArea(
          child: TodoInput(
            focusNode: _focusNode,
            onSubmit: (value) {
              if (value.isNotEmpty) todoModel.add(value);
              _pullToRevealController.hide();
            },
          ),
        ),
        child: SafeArea(
          child: outdated
              ? SlideTransition(
                  position: _outdatedAnimation,
                  child: TodoList.frozen(list: todoModel.list),
                )
              : SlideTransition(
                  position: _limitAnimation,
                  child: TodoList(
                    list: todoModel.list,
                    controller: _todoListController,
                  ),
                ),
        ),
      ),
      floatingActionButton: outdated
          ? FloatingActionButton.extended(
              onPressed: () async {
                await _outdatedAnimationController.forward();
                todoModel.clear();
                settingsModel.lastFlushed = DateTime.now();
                _outdatedAnimationController.reset();
              },
              label: const Text('🚽🧻🪠'),
            )
          : null,
      resizeToAvoidBottomInset: false,
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
