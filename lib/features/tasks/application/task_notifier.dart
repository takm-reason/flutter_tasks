import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/features/tasks/application/settings_state.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';
import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';
import 'package:flutter_tasks/features/tasks/providers.dart';

class TaskNotifier extends AsyncNotifier<TaskListState> {
  late final TaskRepository _repository;

  @override
  Future<TaskListState> build() async {
    _repository = ref.watch(taskRepositoryProvider);
    try {
      final tasks = await _repository.findAll();
      return TaskListState(tasks: tasks);
    } catch (e) {
      throw Exception('タスクの読み込みに失敗しました: $e');
    }
  }

  /// タスク一覧を読み込む
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();

    try {
      final tasks = await _repository.findAll();
      final currentFilter = ref.read(currentFilterProvider);
      final currentSort = ref.read(currentSortProvider);
      final settings = ref.read(settingsProvider);

      // フィルタリングとソートを適用
      final filteredTasks = _filterTasks(tasks, currentFilter, settings);
      final sortedTasks = _sortTasks(filteredTasks, currentSort);
      state = AsyncValue.data(
        TaskListState(
          tasks: sortedTasks,
          filterDescription:
              currentFilter == TaskFilter.all ? null : currentFilter.label,
        ),
      );
    } catch (e) {
      state = AsyncError('タスクの読み込みに失敗しました: $e', StackTrace.current);
    }
  }

  /// タスクを作成する
  Future<void> createTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(task);
      loadTasks();
    } catch (e) {
      state = AsyncError('タスクの作成に失敗しました: $e', StackTrace.current);
    }
  }

  /// タスクを更新する
  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      // タスクの存在確認を行う
      final existingTask = await _repository.findById(task.id);
      if (existingTask == null) {
        state = AsyncError('タスクが見つかりませんでした', StackTrace.current);
        return;
      }
      await _repository.save(task);
      loadTasks();
    } catch (e) {
      state = AsyncError('タスクの更新に失敗しました: $e', StackTrace.current);
    }
  }

  /// タスクを削除する
  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      loadTasks();
    } catch (e) {
      state = AsyncError('タスクの削除に失敗しました: $e', StackTrace.current);
    }
  }

  /// タスクの完了状態を切り替える
  Future<void> toggleTaskCompletion(String id) async {
    state = const AsyncValue.loading();
    try {
      final task = await _repository.findById(id);
      if (task == null) {
        state = AsyncError('タスクが見つかりません: $id', StackTrace.current);
        return;
      }

      if (task.isCompleted) {
        await _repository.uncomplete(id);
      } else {
        await _repository.complete(id);
      }

      // 最新のタスク一覧を読み込む
      await loadTasks();
    } catch (e) {
      state = AsyncError('タスクの完了状態の更新に失敗しました: $e', StackTrace.current);
    }
  }

  /// フィルターを設定する
  void setFilter(TaskFilter filter) {
    ref.read(currentFilterProvider.notifier).state = filter;
    loadTasks();
  }

  /// ソート順を設定する
  void setSort(TaskSort sort) {
    ref.read(currentSortProvider.notifier).state = sort;
    loadTasks();
  }

  /// タスクをフィルタリングする
  List<Task> _filterTasks(
    List<Task> tasks,
    TaskFilter filter,
    TaskSettings settings,
  ) {
    // 24時間以上経過した完了済みタスクを非表示にする設定の適用
    if (settings.hideCompletedAfter24Hours) {
      final twentyFourHoursAgo = DateTime.now().subtract(
        const Duration(hours: 24),
      );
      tasks = tasks
          .where((task) {
            if (!task.isCompleted) return true;
            return task.completedAt?.isAfter(twentyFourHoursAgo) ?? true;
          })
          .toList(growable: true);
    }

    return switch (filter) {
      TaskFilter.all => List.from(tasks),
      TaskFilter.incomplete => tasks
          .where((task) => !task.isCompleted)
          .toList(growable: true),
      TaskFilter.completed => tasks
          .where((task) => task.isCompleted)
          .toList(growable: true),
      TaskFilter.overdue => tasks
          .where((task) {
            final now = DateTime.now();
            return !task.isCompleted &&
                task.dueDate != null &&
                task.dueDate!.isBefore(now);
          })
          .toList(growable: true),
      TaskFilter.priority => tasks
          .where((task) => task.priority.index >= 1)
          .toList(growable: true),
    };
  }

  /// タスクをソートする
  List<Task> _sortTasks(List<Task> tasks, TaskSort sort) {
    final sortedTasks = List<Task>.from(tasks);
    switch (sort) {
      case TaskSort.createdDesc:
        sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSort.createdAsc:
        sortedTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TaskSort.dueDate:
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case TaskSort.priority:
        sortedTasks.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
    }
    return sortedTasks;
  }
}
