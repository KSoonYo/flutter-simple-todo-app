import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodoModel with ChangeNotifier {
  late final List<Todo> _list;
  var _initialized = false;

  UnmodifiableListView<Todo> get list => UnmodifiableListView(_list);

  void initialize(AppLocalizations appLocalizations) {
    if (_initialized) return;

    _initialized = true;
    _list = [
      Todo(appLocalizations.todoDefaultItem1),
      Todo(appLocalizations.todoDefaultItem2),
      Todo(appLocalizations.todoDefaultItem3),
      Todo(appLocalizations.todoDefaultItem4),
      Todo(appLocalizations.todoDefaultItem5),
    ];
  }

  void addItem(String content) {
    _list.add(Todo(content));
    notifyListeners();
  }

  void removeItem({required Todo item}) {
    _list.remove(item);
    notifyListeners();
  }

  void archiveItem({required Todo item}) {
    final index = _list.indexOf(item);
    if (index == -1) return;

    _list[index] = item.copyWith(archived: true);
    notifyListeners();
  }

  void unarchiveItem({required Todo item}) {
    final index = _list.indexOf(item);
    if (index == -1) return;

    _list[index] = item.copyWith(archived: false);
    notifyListeners();
  }

  void moveItem(int from, int to) {
    final item = _list.removeAt(from);
    if (from < to) to--;
    _list.insert(to, item);
    notifyListeners();
  }
}

class Todo {
  final String content;
  final bool archived;

  const Todo(this.content, {this.archived = false});

  Todo copyWith({String? content, bool? archived}) {
    return Todo(
      content ?? this.content,
      archived: archived ?? this.archived,
    );
  }
}
