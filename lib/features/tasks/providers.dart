import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/features/tasks/application/settings_notifier.dart';
import 'package:flutter_tasks/features/tasks/application/settings_state.dart';
import 'package:flutter_tasks/features/tasks/application/task_notifier.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';
import 'package:flutter_tasks/features/tasks/data/local_storage_task_repository.dart';
import 'package:flutter_tasks/features/tasks/data/api_task_repository.dart';
import 'package:flutter_tasks/features/tasks/domain/task_repository.dart';
import 'package:flutter_tasks/core/config/api_config.dart';

/// リポジトリの種類を選択するためのプロバイダー
final repositoryTypeProvider = StateProvider<RepositoryType>((ref) {
  return RepositoryType.api; // デフォルトでAPIリポジトリを使用
});

/// リポジトリの種類
enum RepositoryType { api, localStorage }

/// タスクリポジトリのプロバイダー
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final repositoryType = ref.watch(repositoryTypeProvider);

  return switch (repositoryType) {
    RepositoryType.api => ApiTaskRepository(),
    RepositoryType.localStorage =>
      throw UnimplementedError(
        'LocalStorageTaskRepositoryは非同期初期化が必要なため、この方法では使用できません',
      ),
  };
});

/// ローカルストレージリポジトリのプロバイダー（必要な場合のみ使用）
final localStorageRepositoryProvider =
    FutureProvider<LocalStorageTaskRepository>((ref) async {
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

/// 環境設定を管理するプロバイダー
final environmentProvider = StateProvider<Environment>((ref) {
  return Environment.development; // デフォルトで開発環境を使用
});
