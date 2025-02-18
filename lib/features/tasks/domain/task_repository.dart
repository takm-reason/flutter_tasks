import 'package:flutter_tasks/features/tasks/domain/task.dart';

abstract class TaskRepository {
  Future<List<Task>> findAll();
  Future<Task?> findById(String id);
  Future<void> save(Task task);
  Future<void> delete(String id);
}
