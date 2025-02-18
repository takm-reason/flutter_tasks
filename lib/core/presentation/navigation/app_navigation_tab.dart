import 'package:flutter/material.dart';

/// アプリケーションのナビゲーションタブを表すインターフェース
abstract class AppNavigationTab {
  Widget get page;
  String get title;
  NavigationDestination get destination;
  List<Widget> get actions => const []; // デフォルトは空のリスト
}

/// タスクタブの実装
class TasksTab implements AppNavigationTab {
  final Widget _page;
  final List<Widget> _actions;

  TasksTab(this._page, {List<Widget> actions = const []}) : _actions = actions;

  @override
  Widget get page => _page;

  @override
  String get title => 'タスク';

  @override
  NavigationDestination get destination =>
      const NavigationDestination(icon: Icon(Icons.task), label: 'タスク');

  @override
  List<Widget> get actions => _actions;
}

/// カレンダータブの実装
class CalendarTab implements AppNavigationTab {
  final Widget _page;

  CalendarTab(this._page);

  @override
  Widget get page => _page;

  @override
  String get title => 'カレンダー';

  @override
  NavigationDestination get destination => const NavigationDestination(
    icon: Icon(Icons.calendar_month),
    label: 'カレンダー',
  );

  @override
  List<Widget> get actions => const [];
}

/// 設定タブの実装
class SettingsTab implements AppNavigationTab {
  final Widget _page;

  SettingsTab(this._page);

  @override
  Widget get page => _page;

  @override
  String get title => '設定';

  @override
  NavigationDestination get destination =>
      const NavigationDestination(icon: Icon(Icons.settings), label: '設定');

  @override
  List<Widget> get actions => const [];
}
