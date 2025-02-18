import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/providers.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormDialog({super.key, this.task});

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime? _dueDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _dueDate = task?.dueDate;
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return AlertDialog(
      title: Text(isEditing ? 'タスクの編集' : 'タスクの作成'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル入力
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 説明入力
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明（任意）',
                  filled: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 優先度選択
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: '優先度',
                  filled: true,
                ),
                items:
                    TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text('${priority.emoji} ${priority.label}'),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 期限日選択
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dueDate != null ? _formatDate(_dueDate!) : '期限日（任意）',
                ),
                trailing:
                    _dueDate != null
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                        )
                        : null,
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selected != null) {
                    setState(() {
                      _dueDate = selected;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final task = Task(
                id: widget.task?.id,
                title: _titleController.text,
                description: _descriptionController.text,
                dueDate: _dueDate,
                priority: _priority,
                isCompleted: widget.task?.isCompleted ?? false,
                completedAt: widget.task?.completedAt,
              );

              if (isEditing) {
                ref.read(taskNotifierProvider.notifier).updateTask(task);
              } else {
                ref.read(taskNotifierProvider.notifier).createTask(task);
              }

              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? '更新' : '作成'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
