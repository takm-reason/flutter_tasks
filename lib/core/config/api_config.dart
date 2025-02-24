import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

enum Environment { development, staging, production }

class ApiConfig {
  static Environment _environment = Environment.development;

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        if (Platform.isAndroid) {
          // Androidエミュレータの場合、10.0.2.2を使用
          debugPrint(
            'Using development environment (Android): http://10.0.2.2:3000/api',
          );
          return 'http://10.0.2.2:3000/api';
        } else if (Platform.isIOS) {
          // iOS実機/シミュレータの場合、ローカルネットワークのIPを使用
          debugPrint(
            'Using development environment (iOS): http://192.168.11.4:3000/api',
          );
          return 'http://192.168.11.4:3000/api';
        } else {
          // その他の環境の場合（デバッグなど）
          debugPrint(
            'Using development environment: http://localhost:3000/api',
          );
          return 'http://localhost:3000/api';
        }
      case Environment.staging:
        // TODO: ステージング環境のURLを設定
        return 'https://api-staging.example.com/api';
      case Environment.production:
        // TODO: 本番環境のURLを設定
        return 'https://api.example.com/api';
    }
  }

  static void setEnvironment(Environment env) {
    _environment = env;
    debugPrint('Environment set to: $env');
    debugPrint('Base URL: ${ApiConfig.baseUrl}');
  }

  static String get tasksEndpoint => '$baseUrl/tasks';
}
