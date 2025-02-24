import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';

class LocalStorageTaskRepository implements TaskRepository {
  static const _keyTasks = 'tasks';

  static LocalStorageTaskRepository? _instance;
  static SharedPreferences? _prefs;
  final List<Task> _cache = [];

  LocalStorageTaskRepository._();

  static Future<LocalStorageTaskRepository> getInstance() async {
    if (_instance == null) {
      WidgetsFlutterBinding.ensureInitialized();
      _prefs = await SharedPreferences.getInstance();
      _instance = LocalStorageTaskRepository._();
      await _instance!._loadFromStorage();
    }
    return _instance!;
  }

  Future<void> _loadFromStorage() async {
    final jsonString = _prefs?.getString(_keyTasks);
    if (jsonString == null) return;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      _cache.clear();
      _cache.addAll(
        jsonList.map((json) => Task.fromJson(json as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('Error loading tasks from storage: $e');
      // エラーが発生した場合は既存のデータを削除
      await _prefs?.remove(_keyTasks);
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final jsonString = jsonEncode(
        _cache.map((task) => task.toJson()).toList(),
      );
      await _prefs?.setString(_keyTasks, jsonString);
    } catch (e) {
      debugPrint('Error saving tasks to storage: $e');
    }
  }

  @override
  Future<List<Task>> findCompleted() async {
    final tasks = _cache.where((task) => task.completedAt != null).toList();
    tasks.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return List.unmodifiable(tasks);
  }

  @override
  Future<List<Task>> findAll({TaskSort? sort}) async {
    final tasks = List<Task>.from(_cache);
    if (sort != null) {
      switch (sort) {
        case TaskSort.priority:
          tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        case TaskSort.dueDate:
          tasks.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });
        case TaskSort.createdDesc:
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        case TaskSort.createdAsc:
          tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    }
    return List.unmodifiable(tasks);
  }

  @override
  Future<Task?> findById(String id) async {
    return _cache.where((task) => task.id == id).firstOrNull;
  }

  @override
  Future<void> save(Task task) async {
    final index = _cache.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _cache[index] = task;
    } else {
      _cache.add(task);
    }
    await _saveToStorage();
  }

  @override
  Future<void> delete(String id) async {
    _cache.removeWhere((task) => task.id == id);
    await _saveToStorage();
  }

  @override
  Future<Task> complete(String id) async {
    final index = _cache.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw Exception('タスクが見つかりません: $id');
    }
    final task = _cache[index];
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    _cache[index] = updatedTask;
    await _saveToStorage();
    return updatedTask;
  }

  @override
  Future<Task> uncomplete(String id) async {
    final index = _cache.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw Exception('タスクが見つかりません: $id');
    }
    final task = _cache[index];
    final updatedTask = task.copyWith(isCompleted: false, completedAt: null);
    _cache[index] = updatedTask;
    await _saveToStorage();
    return updatedTask;
  }
}
