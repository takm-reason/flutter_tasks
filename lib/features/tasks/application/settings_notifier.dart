import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tasks/features/tasks/application/settings_state.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';

class SettingsNotifier extends Notifier<TaskSettings> {
  static const _keyDefaultSort = 'defaultSort';
  static const _keyDefaultFilter = 'defaultFilter';
  static const _keyHideCompleted = 'hideCompletedAfter24Hours';
  static const _keyWeekStart = 'weekStart';
  static const _keyCalendarViewType = 'calendarViewType';
  static const _keyTaskCalendarDisplay = 'taskCalendarDisplay';

  SharedPreferences? _prefs;

  @override
  TaskSettings build() {
    _initPrefs();
    return const TaskSettings();
  }

  Future<void> _initPrefs() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      state = _loadSettings();
    }
  }

  TaskSettings _loadSettings() {
    final prefs = _prefs;
    if (prefs == null) return const TaskSettings();

    return TaskSettings(
      defaultSort: TaskSort.values[prefs.getInt(_keyDefaultSort) ?? 0],
      defaultFilter: TaskFilter.values[prefs.getInt(_keyDefaultFilter) ?? 0],
      hideCompletedAfter24Hours: prefs.getBool(_keyHideCompleted) ?? false,
      weekStart:
          WeekStart.values[prefs.getInt(_keyWeekStart) ?? 1], // デフォルトは月曜日
      calendarViewType:
          CalendarViewType.values[prefs.getInt(_keyCalendarViewType) ?? 0],
      taskCalendarDisplay:
          TaskCalendarDisplay.values[prefs.getInt(_keyTaskCalendarDisplay) ??
              0],
    );
  }

  Future<void> setDefaultSort(TaskSort sort) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_keyDefaultSort, sort.index);
    state = state.copyWith(defaultSort: sort);
  }

  Future<void> setDefaultFilter(TaskFilter filter) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_keyDefaultFilter, filter.index);
    state = state.copyWith(defaultFilter: filter);
  }

  Future<void> setHideCompletedAfter24Hours(bool hide) async {
    if (_prefs == null) return;
    await _prefs!.setBool(_keyHideCompleted, hide);
    state = state.copyWith(hideCompletedAfter24Hours: hide);
  }

  Future<void> setWeekStart(WeekStart weekStart) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_keyWeekStart, weekStart.index);
    state = state.copyWith(weekStart: weekStart);
  }

  Future<void> setCalendarViewType(CalendarViewType viewType) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_keyCalendarViewType, viewType.index);
    state = state.copyWith(calendarViewType: viewType);
  }

  Future<void> setTaskCalendarDisplay(TaskCalendarDisplay display) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_keyTaskCalendarDisplay, display.index);
    state = state.copyWith(taskCalendarDisplay: display);
  }
}
