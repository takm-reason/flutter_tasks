import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/presentation/task_form_dialog.dart';
import 'package:flutter_tasks/features/tasks/providers.dart';
import 'package:intl/intl.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  @override
  void initState() {
    super.initState();
    // 画面表示時にタスク一覧を読み込む
    Future.microtask(() {
      ref.read(taskNotifierProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);

    return taskState.when(
      data:
          (state) => Column(
            children: [
              if (state.filterDescription != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state.filterDescription!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              Expanded(
                child:
                    state.tasks.isEmpty
                        ? const Center(child: Text('タスクがありません'))
                        : ListView.builder(
                          itemCount: state.tasks.length,
                          itemBuilder: (context, index) {
                            return _TaskListItem(task: state.tasks[index]);
                          },
                        ),
              ),
            ],
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
    );
  }
}

class _TaskListItem extends ConsumerWidget {
  final Task task;

  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // 期限切れかどうかの判定
    final isOverdue =
        task.dueDate != null &&
        !task.isCompleted &&
        task.dueDate!.isBefore(DateTime.now());

    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) {
          ref.read(taskNotifierProvider.notifier).toggleTaskCompletion(task.id);
        },
      ),
      title: Text(
        task.title,
        style: textTheme.bodyLarge?.copyWith(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.description.isNotEmpty)
            Text(
              task.description,
              style: textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(task.priority.emoji),
              const SizedBox(width: 8),
              if (task.dueDate != null)
                Text(
                  DateFormat.yMMMd('ja_JP').format(task.dueDate!),
                  style: textTheme.bodySmall?.copyWith(
                    color: isOverdue ? colorScheme.error : null,
                  ),
                ),
            ],
          ),
        ],
      ),
      // 長押しメニューを表示
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('編集'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) => TaskFormDialog(task: task),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      '削除',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      // 削除前に確認ダイアログを表示
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('タスクの削除'),
                            content: Text('「${task.title}」を削除してもよろしいですか？'),
                            actions: <Widget>[
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text(
                                  '削除',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true && context.mounted) {
                        Navigator.of(context).pop(); // ボトムシートを閉じる
                        ref
                            .read(taskNotifierProvider.notifier)
                            .deleteTask(task.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('「${task.title}」を削除しました'),
                              action: SnackBarAction(
                                label: '元に戻す',
                                onPressed: () {
                                  // TODO: 元に戻す機能の実装
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      // タップで編集ダイアログを表示
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => TaskFormDialog(task: task),
        );
      },
    );
  }
}
