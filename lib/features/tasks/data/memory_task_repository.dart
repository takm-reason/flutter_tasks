import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';

class MemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> findCompleted() async {
    final tasks = _tasks.where((task) => task.completedAt != null).toList();
    tasks.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return tasks;
  }

  @override
  Future<List<Task>> findAll({TaskSort? sort}) async {
    final tasks = List<Task>.from(_tasks);
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
    return tasks;
  }

  @override
  Future<Task?> findById(String id) async {
    return _tasks.where((task) => task.id == id).firstOrNull;
  }

  @override
  Future<void> save(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<Task> complete(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw Exception('タスクが見つかりません: $id');
    }
    final task = _tasks[index];
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    _tasks[index] = updatedTask;
    return updatedTask;
  }

  @override
  Future<Task> uncomplete(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw Exception('タスクが見つかりません: $id');
    }
    final task = _tasks[index];
    final updatedTask = task.copyWith(isCompleted: false, completedAt: null);
    _tasks[index] = updatedTask;
    return updatedTask;
  }
}
