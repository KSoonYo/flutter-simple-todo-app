import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/view/settings_screen.dart';
import 'package:simple_todo/view/todo_input.dart';

import '../models/todo.dart';
import 'pull_to_reveal.dart';
import 'shake.dart';
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

  Todo? _editingItem;

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
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _limitAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoModel = context.watch<TodoModel>();
    todoModel.initialize(AppLocalizations.of(context));
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: PullToReveal(
        controller: _pullToRevealController,
        onRevealing: (direction) {
          ScaffoldMessenger.of(context).clearSnackBars();

          if (direction != PullDirection.down || !todoModel.isFull) return true;

          _limitAnimationController
              .forward()
              .then((_) => _limitAnimationController.reset());

          final messenger = ScaffoldMessenger.of(context);

          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: theme.colorScheme.errorContainer,
              content: Text(
                t!.todoItemMaxCountReached,
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          );

          return false;
        },
        onReveal: () => _focusNode.requestFocus(),
        onHide: () {
          _editingItem = null;
          _focusNode.unfocus();
        },
        topChild: SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: TodoInput(
                focusNode: _focusNode,
                initialValue: _editingItem?.content,
                onSubmit: (value) {
                  if (value.isNotEmpty) {
                    final item = _editingItem;

                    if (item != null) {
                      todoModel.edit(item: item, content: value);
                    } else {
                      todoModel.add(value);
                    }
                  }
                  _pullToRevealController.hide();
                },
              ),
            ),
          ),
        ),
        bottomChild: const SettingsScreen(),
        child: SafeArea(
          child: SlideTransition(
            position: _limitAnimation,
            child: TodoList(
              list: todoModel.list,
              controller: _todoListController,
              onEdit: (item) {
                setState(() {
                  _editingItem = item;
                });
                _pullToRevealController.show(PullDirection.down);
              },
            ),
          ),
        ),
      ),
    );
  }
}
