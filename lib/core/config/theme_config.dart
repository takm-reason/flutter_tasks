import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// テーマモードを管理するプロバイダー
final themeConfigProvider =
    StateNotifierProvider<ThemeConfigNotifier, ThemeMode>((ref) {
      return ThemeConfigNotifier();
    });

class ThemeConfigNotifier extends StateNotifier<ThemeMode> {
  ThemeConfigNotifier() : super(ThemeMode.system);

  // テーマモードの切り替え
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  // ダークモード切り替え
  void toggleTheme() {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
  }
}
