import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';

class MemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> findAll() async {
    return _tasks;
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
}
