import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    required this.list,
    required this.onEdit,
    this.controller,
  });

  final UnmodifiableListView<Todo> list;
  final AnimatedListController? controller;
  final void Function(Todo item) onEdit;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimatedListController _controller;
  late bool outdated;

  @override
  void initState() {
    super.initState();
    var settings = context.read<SettingsModel>();

    _controller = widget.controller ?? AnimatedListController();
    WidgetsBinding.instance.addObserver(this);
    outdated = _isOutdated(settings);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var settings = context.read<SettingsModel>();
    if (state == AppLifecycleState.resumed) {
      setState(() {
        outdated = _isOutdated(settings);
      });
    }
  }

  @override
  void didUpdateWidget(covariant TodoList oldWidget) {
    super.didUpdateWidget(oldWidget);

    var settings = context.read<SettingsModel>();
    setState(() {
      outdated = _isOutdated(settings);
    });
  }

  @override
  Widget build(BuildContext context) {
    // build 완료 후 한번 만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));

    final t = AppLocalizations.of(context);
    var theme = Theme.of(context);
    final visibleItems = widget.list.where((i) => !i.toRemove).toList();

    return Center(
      child: visibleItems.isNotEmpty
          ? AutomaticAnimatedListView<Todo>(
              comparator: AnimatedListDiffListComparator(
                sameItem: (a, b) => a.id == b.id,
                sameContent: (a, b) =>
                    a.content == b.content &&
                    a.archived == b.archived &&
                    a.toRemove == b.toRemove,
              ),
              reorderModel: CustomAutomaticAnimatedListReorderModel(
                  context, visibleItems),
              shrinkWrap: true,
              list: visibleItems,
              listController: _controller,
              itemBuilder: (context, element, data) {
                return TodoItem(
                  item: element,
                  onEdit: widget.onEdit,
                );
              },
            )
          : Text(
              t!.todoItemHint,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
    );
  }

  bool _isOutdated(SettingsModel settingsModel) {
    final now = DateTime.now();
    final flush = now.copyWith(
      hour: settingsModel.flushAt.hour,
      minute: settingsModel.flushAt.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    return now.isAfter(flush) && settingsModel.lastFlushed.isBefore(flush);
  }

  void _onAfterBuild(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settingsModel = context.read<SettingsModel>();
    final todoModel = context.read<TodoModel>();
    var theme = Theme.of(context);

    if (todoModel.cache != null && outdated) {
      outdated = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t!.todoItemOutdated,
              style: theme.textTheme.bodyLarge!
                  .copyWith(color: theme.colorScheme.onInverseSurface)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(days: 1),
          onVisible: () => todoModel.clear(),
        ),
      );

      settingsModel.lastFlushed = DateTime.now();
    }
  }
}

class CustomAutomaticAnimatedListReorderModel<T>
    extends AnimatedListBaseReorderModel {
  const CustomAutomaticAnimatedListReorderModel(this.context, this.list);

  final BuildContext context;
  final List<Todo> list;

  @override
  bool onReorderStart(int index, double dx, double dy) => true;

  @override
  Object? onReorderFeedback(
          int index, int dropIndex, double offset, double dx, double dy) =>
      null;

  @override
  bool onReorderMove(int index, int dropIndex) => true;

  @override
  bool onReorderComplete(int index, int dropIndex, Object? slot) {
    var todoModel = context.read<TodoModel>();
    list.insert(dropIndex, list.removeAt(index));
    todoModel.update(list);
    return true;
  }
}
