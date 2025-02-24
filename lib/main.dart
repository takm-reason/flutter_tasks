import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tasks/core/app.dart';
import 'package:flutter_tasks/core/config/api_config.dart';
import 'package:flutter_tasks/features/tasks/providers.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ja');

  // 環境変数やコマンドライン引数などから環境を判定する場合はここで設定
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  final env = switch (environment) {
    'production' => Environment.production,
    'staging' => Environment.staging,
    _ => Environment.development,
  };

  // デバッグ情報の出力
  debugPrint('Environment: $environment');
  debugPrint('Platform: ${defaultTargetPlatform.name}');
  debugPrint('Is Web: ${kIsWeb}');

  // APIの設定を初期化
  ApiConfig.setEnvironment(env);

  runApp(
    ProviderScope(
      overrides: [
        // 環境設定の初期値を設定
        environmentProvider.overrideWith((ref) => env),
      ],
      child: const App(),
    ),
  );
}
