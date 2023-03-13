import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TodoModel with ChangeNotifier {
  static const _maxCount = 5;
  static const _keyCache = 'cache';
  static const uuid = Uuid();

  late Map<String, dynamic>? _cacheTable;
  late String _nextIndex;
  bool _initialized = false;
  Cache? _cache;
  List<Todo> _list = [];

  UnmodifiableListView<Todo> get list => UnmodifiableListView(_list);
  bool get isFull => _list.length >= _maxCount;
  Cache? get cache => _cache;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void initialize(AppLocalizations? appLocalizations) async {
    if (appLocalizations == null) return;
    if (_initialized) return;

    await _load();

    _initialized = true;

    if (_cache == null) {
      _list = [
        Todo(id: uuid.v4(), content: appLocalizations.todoDefaultItem1),
        Todo(id: uuid.v4(), content: appLocalizations.todoDefaultItem2),
        Todo(id: uuid.v4(), content: appLocalizations.todoDefaultItem3),
        Todo(id: uuid.v4(), content: appLocalizations.todoDefaultItem4),
        Todo(id: uuid.v4(), content: appLocalizations.todoDefaultItem5),
      ];
      _nextIndex = uuid.v4();
      _cacheTable = {
        'list': _list.map((todo) => todo.toJson()).toList(),
        'nextIndex': _nextIndex
      };
      _cache = Cache.fromJson(_cacheTable!);
      debugPrint('cache object: ${_cache?.toJson()}');
      debugPrint('cache todo list; ${_cache?.toJson()['list']}');
      debugPrint('encoded cache data: ${jsonEncode(_cache?.toJson())}');
      _store(_keyCache, jsonEncode(_cache?.toJson()));
    } else {
      _list = _cache!.list;
      _nextIndex = _cache!.nextIndex;
      debugPrint('initialize with cache data');
    }
  }

  void add(String content) {
    if (isFull) return; // should we just throw?

    _list.add(Todo(id: _nextIndex, content: content));
    _nextIndex = uuid.v4();
    cacheUpdate(_list, _nextIndex);
  }

  void edit({required Todo item, required String content}) {
    final index = _list.indexWhere((element) => element.id == item.id);
    if (index == -1) return;

    if (item.content == content) return;

    _list[index] = item.copyWith(content: content);
    cacheUpdate(_list, _nextIndex);
  }

  Todo markRemoval({required Todo item, required bool remove}) {
    final index = _list.indexWhere((element) => element.id == item.id);
    if (index == -1) throw 'WTF';
    final marked = item.copyWith(toRemove: remove);
    _list[index] = marked;
    cacheUpdate(_list, _nextIndex);
    return marked;
  }

  void remove({required Todo item}) {
    _list.removeWhere((element) => element.id == item.id);
    cacheUpdate(_list, _nextIndex);
  }

  void setArchived({required Todo item, required bool archived}) {
    final index = _list.indexWhere((element) => element.id == item.id);
    if (index == -1) return;

    _list[index] = item.copyWith(archived: archived);
    cacheUpdate(_list, _nextIndex);
  }

  void move(int from, int to) {
    final item = _list.removeAt(from);
    if (from < to) to--;
    _list.insert(to, item);
    cacheUpdate(_list, _nextIndex);
  }

  void update(List<Todo> newList) {
    _list = newList;
    cacheUpdate(_list, _nextIndex);
  }

  void clear() {
    _list.clear();
    cacheUpdate(_list, _nextIndex);
  }

  void cacheUpdate(List<Todo> list, String nextIndex) {
    _cacheTable = {
      'list': list.map((todo) => todo.toJson()).toList(),
      'nextIndex': nextIndex
    };
    _cache = Cache.fromJson(_cacheTable!);
    _store(_keyCache, jsonEncode(_cache?.toJson()));
    debugPrint('[update] cache object: ${_cache?.toJson()}');
    debugPrint('[update] encoded cache data: ${jsonEncode(_cache?.toJson())}');

    notifyListeners();
  }

  Future<bool> _store(String key, String? value) async {
    final preferences = await _prefs;
    if (value == null) return preferences.remove(key);

    preferences.setString(key, value);
    return true;
  }

  Future<void> _load<T>() async {
    debugPrint('todo data loading...');

    final preferences = await _prefs;
    final rawCacheData = preferences.getString(_keyCache);
    debugPrint('raw cache data: $rawCacheData');
    _cacheTable = rawCacheData != null ? jsonDecode(rawCacheData) : null;
    debugPrint('cache table: $_cacheTable');
    _cache = _cacheTable != null ? Cache.fromJson(_cacheTable!) : null;

    notifyListeners();
  }
}

class Todo {
  final String id;
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

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        content = json['content'],
        archived = json['archived'],
        toRemove = json['toRemove'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'archived': archived,
        'toRemove': toRemove
      };
}

class Cache {
  final List<Todo> list;
  final String nextIndex;

  Cache(this.list, this.nextIndex);

  Cache.fromJson(Map<String, dynamic> json)
      : list =
            (json['list'] as List).map((todo) => Todo.fromJson(todo)).toList(),
        nextIndex = json['nextIndex'];
  Map<String, dynamic> toJson() => {
        'list': list.map((todo) => todo.toJson()).toList(),
        'nextIndex': nextIndex
      };
}
