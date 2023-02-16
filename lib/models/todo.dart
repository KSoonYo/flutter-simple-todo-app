import 'dart:collection';

import 'package:flutter/material.dart';

class TodoModel with ChangeNotifier {
  final _active = <Todo>[
    const Todo('Pull down to add'),
    const Todo('Swipe left to remove'),
    const Todo('Swipe right to mark completed'),
    const Todo('Pull up to sham 🫠'),
  ];

  final _archived = <Todo>[];

  UnmodifiableListView<Todo> get active => UnmodifiableListView(_active);
  UnmodifiableListView<Todo> get archived => UnmodifiableListView(_archived);

  bool get isEmpty => _active.isEmpty && _archived.isEmpty;

  void addItem(String content) {
    _active.add(Todo(content));
    notifyListeners();
  }

  void removeItem({required Todo item}) {
    if (_active.contains(item)) {
      _active.remove(item);
    } else {
      _archived.remove(item);
    }
    notifyListeners();
  }

  void archiveItem({required Todo item, required int index}) {
    _active[index] = _active[index].copyWith(archived: true);
    _archived.add(item.copyWith(archived: true));
    notifyListeners();
  }

  void unarchiveItem({required Todo item, required int index}) {
    _active[index] = _active[index].copyWith(archived: false);
    _archived.remove(item);
    notifyListeners();
  }

  void moveItem(int from, int to) {
    final item = _active.removeAt(from);
    if (from < to) to--;
    _active.insert(to, item);
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
