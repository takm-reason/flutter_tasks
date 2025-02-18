import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/features/tasks/domain/task.dart';
import 'package:flutter_tasks/features/tasks/providers.dart';
import 'package:intl/intl.dart';

class CalendarViewPage extends ConsumerWidget {
  const CalendarViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month, 1);
    final lastDay = DateTime(today.year, today.month + 1, 0);
    final state = ref.watch(taskNotifierProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('エラー: $error')),
      data:
          (data) => _CalendarView(
            firstDay: firstDay,
            lastDay: lastDay,
            tasks: data.tasks,
            today: today,
          ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final List<Task> tasks;
  final DateTime today;

  const _CalendarView({
    required this.firstDay,
    required this.lastDay,
    required this.tasks,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;
    final weeks = ((daysInMonth + firstWeekday - 1) / 7).ceil();

    return Column(
      children: [
        // 月表示
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            DateFormat.yMMMM('ja').format(firstDay),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // 曜日ヘッダー
        Row(
          children: ['月', '火', '水', '木', '金', '土', '日']
              .map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              })
              .toList(growable: true),
        ),
        const Divider(),
        // カレンダーグリッド
        Expanded(
          child: ListView.builder(
            itemCount: weeks,
            itemBuilder: (context, weekIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 2;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }

                  final date = DateTime(
                    firstDay.year,
                    firstDay.month,
                    dayNumber,
                  );

                  final dayTasks = tasks
                      .where((task) {
                        return task.dueDate?.year == date.year &&
                            task.dueDate?.month == date.month &&
                            task.dueDate?.day == date.day;
                      })
                      .toList(growable: true);

                  final isToday =
                      date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;

                  return Expanded(
                    child: InkWell(
                      onTap:
                          dayTasks.isEmpty
                              ? null
                              : () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => _DayTasksDialog(
                                        date: date,
                                        tasks: dayTasks,
                                      ),
                                );
                              },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          color:
                              isToday
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1)
                                  : null,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  color:
                                      isToday
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : null,
                                  fontWeight: isToday ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                            if (dayTasks.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.all(2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${dayTasks.length}件',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(growable: true),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayTasksDialog extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;

  const _DayTasksDialog({required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(DateFormat.yMMMd('ja').format(date)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              leading: Text(task.priority.emoji),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle:
                  task.description.isNotEmpty ? Text(task.description) : null,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
