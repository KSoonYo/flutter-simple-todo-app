import 'dart:collection';

import 'package:flutter/material.dart';

class TodoModel with ChangeNotifier {
  final _list = <Todo>[
    const Todo('Pull down to add'),
    const Todo('Swipe left to remove'),
    const Todo('Swipe right to mark completed'),
    const Todo('Pull up to sham 🫠'),
  ];

  UnmodifiableListView<Todo> get list => UnmodifiableListView(_list);

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
