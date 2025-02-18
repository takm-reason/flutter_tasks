import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/features/tasks/application/settings_notifier.dart';
import 'package:flutter_tasks/features/tasks/application/settings_state.dart';
import 'package:flutter_tasks/features/tasks/application/task_notifier.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';
import 'package:flutter_tasks/features/tasks/data/local_storage_task_repository.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';

/// タスクリポジトリのプロバイダー
final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  return await LocalStorageTaskRepository.getInstance();
});

/// 設定の状態管理プロバイダー
final settingsProvider = NotifierProvider<SettingsNotifier, TaskSettings>(() {
  return SettingsNotifier();
});

/// タスクの状態管理プロバイダー
final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, TaskListState>(
  () {
    return TaskNotifier();
  },
);

/// 現在のフィルターを管理するプロバイダー
final currentFilterProvider = StateProvider<TaskFilter>((ref) {
  // 設定から初期値を取得
  return ref.watch(settingsProvider).defaultFilter;
});

/// 現在のソート順を管理するプロバイダー
final currentSortProvider = StateProvider<TaskSort>((ref) {
  // 設定から初期値を取得
  return ref.watch(settingsProvider).defaultSort;
});
