import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';

abstract class TaskRepository {
  Future<List<Task>> findAll({TaskSort? sort});
  Future<List<Task>> findCompleted();
  Future<Task?> findById(String id);
  Future<void> save(Task task);
  Future<void> delete(String id);
  Future<Task> complete(String id);
  Future<Task> uncomplete(String id);
}
