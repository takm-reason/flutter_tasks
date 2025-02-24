import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class ApiConfig {
  static Environment _environment = Environment.development;

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        debugPrint('Using development environment: http://localhost:3000/api');
        return 'http://localhost:3000/api';
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
