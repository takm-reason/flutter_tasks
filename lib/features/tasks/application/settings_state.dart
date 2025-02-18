import 'package:flutter_tasks/features/tasks/application/task_state.dart';

/// タスク設定の状態を表すクラス
class TaskSettings {
  final TaskSort defaultSort;
  final TaskFilter defaultFilter;
  final bool hideCompletedAfter24Hours;
  final WeekStart weekStart;
  final CalendarViewType calendarViewType;
  final TaskCalendarDisplay taskCalendarDisplay;

  const TaskSettings({
    this.defaultSort = TaskSort.createdDesc,
    this.defaultFilter = TaskFilter.all,
    this.hideCompletedAfter24Hours = false,
    this.weekStart = WeekStart.monday,
    this.calendarViewType = CalendarViewType.month,
    this.taskCalendarDisplay = TaskCalendarDisplay.dueDate,
  });

  TaskSettings copyWith({
    TaskSort? defaultSort,
    TaskFilter? defaultFilter,
    bool? hideCompletedAfter24Hours,
    WeekStart? weekStart,
    CalendarViewType? calendarViewType,
    TaskCalendarDisplay? taskCalendarDisplay,
  }) {
    return TaskSettings(
      defaultSort: defaultSort ?? this.defaultSort,
      defaultFilter: defaultFilter ?? this.defaultFilter,
      hideCompletedAfter24Hours:
          hideCompletedAfter24Hours ?? this.hideCompletedAfter24Hours,
      weekStart: weekStart ?? this.weekStart,
      calendarViewType: calendarViewType ?? this.calendarViewType,
      taskCalendarDisplay: taskCalendarDisplay ?? this.taskCalendarDisplay,
    );
  }
}

/// 週の開始日
enum WeekStart {
  sunday('日曜日'),
  monday('月曜日');

  final String label;
  const WeekStart(this.label);
}

/// カレンダーの表示形式
enum CalendarViewType {
  month('月表示'),
  week('週表示'),
  schedule('スケジュール表示');

  final String label;
  const CalendarViewType(this.label);
}

/// タスクのカレンダー表示方法
enum TaskCalendarDisplay {
  dueDate('期限日のみ'),
  duration('期間で表示'),
  all('すべての日付を表示');

  final String label;
  const TaskCalendarDisplay(this.label);
}
