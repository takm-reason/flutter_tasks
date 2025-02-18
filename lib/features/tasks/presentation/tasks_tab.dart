import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/core/presentation/navigation/app_navigation_tab.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';
import 'package:flutter_tasks/features/tasks/presentation/tasks_page.dart';
import 'package:flutter_tasks/features/tasks/providers.dart';

/// タスクタブのファクトリープロバイダー
final tasksTabProvider = Provider<TasksTab>((ref) {
  // フィルターとソートメニューを作成
  final filterMenu = Consumer(
    builder:
        (context, ref, _) => PopupMenuButton<TaskFilter>(
          icon: const Icon(Icons.filter_list),
          initialValue: ref.watch(currentFilterProvider),
          onSelected: (filter) {
            ref.read(taskNotifierProvider.notifier).setFilter(filter);
          },
          itemBuilder: (context) {
            return TaskFilter.values.map((filter) {
              return PopupMenuItem(value: filter, child: Text(filter.label));
            }).toList();
          },
        ),
  );

  final sortMenu = Consumer(
    builder:
        (context, ref, _) => PopupMenuButton<TaskSort>(
          icon: const Icon(Icons.sort),
          initialValue: ref.watch(currentSortProvider),
          onSelected: (sort) {
            ref.read(taskNotifierProvider.notifier).setSort(sort);
          },
          itemBuilder: (context) {
            return TaskSort.values.map((sort) {
              return PopupMenuItem(value: sort, child: Text(sort.label));
            }).toList();
          },
        ),
  );

  return TasksTab(const TasksPage(), actions: [filterMenu, sortMenu]);
});
