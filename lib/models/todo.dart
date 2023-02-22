import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodoModel with ChangeNotifier {
  static const _maxCount = 5;

  late final List<Todo> _list;
  var _initialized = false;

  UnmodifiableListView<Todo> get list => UnmodifiableListView(_list);
  bool get isFull => _list.length >= _maxCount;

  void initialize(AppLocalizations appLocalizations) {
    if (_initialized) return;

    _initialized = true;
    _list = [
      Todo(id: 0, content: appLocalizations.todoDefaultItem1),
      Todo(id: 1, content: appLocalizations.todoDefaultItem2),
      Todo(id: 2, content: appLocalizations.todoDefaultItem3),
      Todo(id: 3, content: appLocalizations.todoDefaultItem4),
      Todo(id: 4, content: appLocalizations.todoDefaultItem5),
    ];
  }

  void add(String content) {
    _list.add(Todo(id: _list.length, content: content));
    notifyListeners();
  }

  Todo markRemoval({required Todo item, required bool remove}) {
    final index = _list.indexWhere((element) => element.id == item.id);
    if (index == -1) throw 'WTF';

    final marked = item.copyWith(toRemove: remove);

    _list[index] = marked;
    notifyListeners();

    return marked;
  }

  void remove({required Todo item}) {
    _list.remove(item);
    notifyListeners();
  }

  void setArchived({required Todo item, required bool archived}) {
    final index = _list.indexWhere((element) => element.id == item.id);
    if (index == -1) return;

    _list[index] = item.copyWith(archived: archived);
    notifyListeners();
  }

  void move(int from, int to) {
    final item = _list.removeAt(from);
    if (from < to) to--;
    _list.insert(to, item);
    notifyListeners();
  }

  void clear() {
    _list.clear();
    notifyListeners();
  }
}

class Todo {
  final int id;
  final String content;
  final bool archived;
  final bool toRemove;

  const Todo({
    required this.id,
    required this.content,
    this.archived = false,
    this.toRemove = false,
  });

  Todo copyWith({String? content, bool? archived, bool? toRemove}) {
    return Todo(
      id: id,
      content: content ?? this.content,
      archived: archived ?? this.archived,
      toRemove: toRemove ?? this.toRemove,
    );
  }
}
