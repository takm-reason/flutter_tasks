import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';

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
  Future<List<Task>> findAll() async {
    return List.unmodifiable(_cache);
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
}
