import 'package:flutter_tasks/features/tasks/domain/task.dart';

class TaskListState {
  final List<Task> tasks;
  final String? filterDescription;

  const TaskListState({required this.tasks, this.filterDescription});
}

// フィルタの種類
enum TaskFilter {
  all('すべてのタスク'),
  incomplete('未完了のタスク'),
  completed('完了済みのタスク'),
  overdue('期限切れのタスク'),
  priority('優先度でフィルタ');

  final String label;
  const TaskFilter(this.label);
}

// タスクの並び順
enum TaskSort {
  createdDesc('作成日時（新しい順）'),
  createdAsc('作成日時（古い順）'),
  dueDate('期限日'),
  priority('優先度');

  final String label;
  const TaskSort(this.label);
}
