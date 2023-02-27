import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/models/settings.dart';
import 'package:simple_todo/view/settings_screen.dart';
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
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: PullToReveal(
        controller: _pullToRevealController,
        onRevealing: (direction) {
          if (direction != PullDirection.down || !todoModel.isFull) return true;

          _limitAnimationController
              .forward()
              .then((_) => _limitAnimationController.reset());

          final messenger = ScaffoldMessenger.of(context);

          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: theme.colorScheme.errorContainer,
              content: Text(
                t.todoItemMaxCountReached,
                style: theme.snackBarTheme.contentTextStyle?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          );

          return false;
        },
        onReveal: () => _focusNode.requestFocus(),
        onHide: () => _focusNode.unfocus(),
        topChild: SafeArea(
          child: TodoInput(
            focusNode: _focusNode,
            onSubmit: (value) {
              if (value.isNotEmpty) todoModel.add(value);
              _pullToRevealController.hide();
            },
          ),
        ),
        bottomChild: const SettingsScreen(),
        child: SafeArea(
          child: SlideTransition(
            position: _limitAnimation,
            child: TodoList(
              list: todoModel.list,
              controller: _todoListController,
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
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
