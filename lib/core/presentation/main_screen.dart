import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/core/presentation/navigation/app_navigation_tab.dart';
import 'package:flutter_tasks/features/tasks/presentation/calendar_view_page.dart';
import 'package:flutter_tasks/features/tasks/presentation/settings_page.dart';
import 'package:flutter_tasks/features/tasks/presentation/task_form_dialog.dart';
import 'package:flutter_tasks/features/tasks/presentation/tasks_tab.dart';

/// メインスクリーンのタブを提供するプロバイダー
final mainScreenTabsProvider = Provider<List<AppNavigationTab>>((ref) {
  return [
    ref.watch(tasksTabProvider),
    CalendarTab(const CalendarViewPage()),
    SettingsTab(const SettingsPage()),
  ];
});

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(mainScreenTabsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[_currentIndex].title),
        actions: tabs[_currentIndex].actions,
      ),
      body: tabs[_currentIndex].page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: tabs.map((tab) => tab.destination).toList(),
      ),
      // タスクタブが選択されている場合のみFABを表示
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TaskFormDialog(),
                  );
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
