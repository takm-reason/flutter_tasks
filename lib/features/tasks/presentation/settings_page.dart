import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/core/config/theme_config.dart';
import 'package:flutter_tasks/features/tasks/application/task_state.dart';
import 'package:flutter_tasks/features/tasks/providers.dart'; // Added import

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeConfigProvider);
    final settings = ref.watch(settingsProvider);

    return ListView(
      children: [
        _SettingsSection(
          title: 'タスク設定',
          children: [
            _SettingsTile(
              title: 'デフォルトのソート順',
              subtitle: settings.defaultSort.label,
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) =>
                          _DefaultSortDialog(currentSort: settings.defaultSort),
                );
              },
            ),
            _SettingsTile(
              title: 'デフォルトのフィルター',
              subtitle: settings.defaultFilter.label,
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => _DefaultFilterDialog(
                        currentFilter: settings.defaultFilter,
                      ),
                );
              },
            ),
            _SettingsTile(
              title: '完了済みタスクの表示',
              subtitle: '完了から24時間経過したタスクを非表示にする',
              trailing: Switch(
                value: settings.hideCompletedAfter24Hours,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setHideCompletedAfter24Hours(value);
                },
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: 'アプリの設定',
          children: [
            ListTile(
              title: const Text('テーマ設定'),
              subtitle: Text(switch (themeMode) {
                ThemeMode.system => 'システム設定に従う',
                ThemeMode.light => 'ライトモード',
                ThemeMode.dark => 'ダークモード',
              }),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => _ThemeModeDialog(currentMode: themeMode),
                );
              },
            ),
          ],
        ),
        _SettingsSection(
          title: 'このアプリについて',
          children: [_SettingsTile(title: 'バージョン', subtitle: '1.0.0')],
        ),
      ],
    );
  }
}

class _DefaultSortDialog extends ConsumerWidget {
  final TaskSort currentSort;

  const _DefaultSortDialog({required this.currentSort});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('デフォルトのソート順'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TaskSort.values
            .map((sort) {
              return RadioListTile<TaskSort>(
                title: Text(sort.label),
                value: sort,
                groupValue: currentSort,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setDefaultSort(value);
                    Navigator.pop(context);
                  }
                },
              );
            })
            .toList(growable: true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

class _DefaultFilterDialog extends ConsumerWidget {
  final TaskFilter currentFilter;

  const _DefaultFilterDialog({required this.currentFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('デフォルトのフィルター'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TaskFilter.values
            .map((filter) {
              return RadioListTile<TaskFilter>(
                title: Text(filter.label),
                value: filter,
                groupValue: currentFilter,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setDefaultFilter(value);
                    Navigator.pop(context);
                  }
                },
              );
            })
            .toList(growable: true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

class _ThemeModeDialog extends ConsumerWidget {
  final ThemeMode currentMode;

  const _ThemeModeDialog({required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('テーマ設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('システム設定に従う'),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeConfigProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ライトモード'),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeConfigProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ダークモード'),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeConfigProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
