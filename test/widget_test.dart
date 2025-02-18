import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tasks/core/app.dart';

void main() {
  testWidgets('タスク管理アプリの基本機能テスト', (WidgetTester tester) async {
    // アプリケーションをビルド
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // 初期状態では「タスク」タブが選択されていることを確認
    expect(find.text('タスク'), findsNWidgets(2)); // AppBarとBottomNavigation
    expect(find.text('タスクがありません'), findsOneWidget);

    // カレンダータブに切り替え
    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pumpAndSettle();

    // カレンダービューが表示されることを確認
    expect(find.text('カレンダー'), findsNWidgets(2));

    // 設定タブに切り替え
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // 設定画面が表示されることを確認
    expect(find.text('設定'), findsNWidgets(2));
    expect(find.text('表示設定'), findsOneWidget);
    expect(find.text('タスク設定'), findsOneWidget);
    expect(find.text('このアプリについて'), findsOneWidget);

    // タスクタブに戻る
    await tester.tap(find.byIcon(Icons.task));
    await tester.pumpAndSettle();

    // FABをタップしてタスク作成ダイアログを開く
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // ダイアログが表示されることを確認
    expect(find.text('新しいタスク'), findsOneWidget);

    // タイトルを入力
    await tester.enterText(find.byType(TextFormField).first, 'テストタスク');

    // 作成ボタンをタップ
    await tester.tap(find.text('作成'));
    await tester.pumpAndSettle();

    // タスクが作成されていることを確認
    expect(find.text('テストタスク'), findsOneWidget);

    // チェックボックスをタップしてタスクを完了
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // タスクのテキストに取り消し線が入っていることを確認
    final taskText = tester.widget<Text>(find.text('テストタスク'));
    expect(taskText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('テーマ設定のテスト', (WidgetTester tester) async {
    // アプリケーションをビルド
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // 設定タブに移動
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // テーマ設定を開く
    await tester.tap(find.text('テーマ設定'));
    await tester.pumpAndSettle();

    // デフォルトでシステム設定が選択されていることを確認
    expect(find.text('システム設定に従う'), findsOneWidget);
    expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));

    // ダークモードに切り替え
    await tester.tap(find.text('ダークモード'));
    await tester.pumpAndSettle();

    // 設定が反映されていることを確認
    expect(find.text('ダークモード'), findsOneWidget);

    // ライトモードに切り替え
    await tester.tap(find.text('テーマ設定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ライトモード'));
    await tester.pumpAndSettle();

    // 設定が反映されていることを確認
    expect(find.text('ライトモード'), findsOneWidget);
  });
}
