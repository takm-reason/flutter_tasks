import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../application/task_state.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';

class ApiTaskRepository implements TaskRepository {
  final http.Client _client;

  ApiTaskRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<Task>> findCompleted() async {
    try {
      final url = Uri.parse('${ApiConfig.tasksEndpoint}/completed');
      debugPrint('Fetching completed tasks from: $url');

      final response = await _client.get(url);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      _validateResponse(response);

      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching completed tasks: $e');
      throw Exception('完了済みタスクの取得に失敗しました: $e');
    }
  }

  @override
  Future<List<Task>> findAll({TaskSort? sort}) async {
    try {
      final queryParams = <String, String>{};
      if (sort != null) {
        switch (sort) {
          case TaskSort.priority:
            queryParams['sort'] = 'priority';
            break;
          case TaskSort.dueDate:
            queryParams['sort'] = 'due_date';
            break;
          case TaskSort.createdDesc:
          case TaskSort.createdAsc:
            // APIはデフォルトで作成日時の降順
            break;
        }
      }

      final url = Uri.parse(
        ApiConfig.tasksEndpoint,
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      debugPrint('Fetching tasks from: $url');

      final response = await _client.get(url);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      _validateResponse(response);

      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      throw Exception('タスクの取得に失敗しました: $e');
    }
  }

  @override
  Future<Task?> findById(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksEndpoint}/$id');
      debugPrint('Fetching task from: $url');

      final response = await _client.get(url);
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 404) {
        return null;
      }

      _validateResponse(response);
      final Map<String, dynamic> taskJson = json.decode(response.body);
      return Task.fromJson(taskJson);
    } catch (e) {
      debugPrint('Error fetching task: $e');
      throw Exception('タスクの取得に失敗しました: $e');
    }
  }

  @override
  Future<void> save(Task task) async {
    try {
      // idが空文字の場合は新規作成とみなす
      final isNewTask = task.id.isEmpty;
      final uri =
          isNewTask
              ? Uri.parse(ApiConfig.tasksEndpoint)
              : Uri.parse('${ApiConfig.tasksEndpoint}/${task.id}');

      debugPrint('${isNewTask ? "Creating" : "Updating"} task at: $uri');

      // APIの仕様に合わせてリクエストボディを構築
      final Map<String, dynamic> requestJson =
          isNewTask
              ? {
                'task': {
                  'title': task.title,
                  'description': task.description,
                  'due_date': task.dueDate?.toIso8601String(),
                  'priority': Task.priorityToNumber(task.priority),
                },
              }
              : {
                'title': task.title,
                'description': task.description,
                'due_date': task.dueDate?.toIso8601String(),
                'priority': Task.priorityToNumber(task.priority),
              };
      final requestBody = json.encode(requestJson);
      debugPrint('Request body: $requestBody');

      final response =
          await (isNewTask
              ? _client.post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: requestBody,
              )
              : _client.patch(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: requestBody,
              ));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      _validateResponse(response);
    } catch (e) {
      debugPrint('Error saving task: $e');
      throw Exception('タスクの保存に失敗しました: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksEndpoint}/$id');
      debugPrint('Deleting task at: $url');

      final response = await _client.delete(url);
      debugPrint('Response status: ${response.statusCode}');

      _validateResponse(response);
    } catch (e) {
      debugPrint('Error deleting task: $e');
      throw Exception('タスクの削除に失敗しました: $e');
    }
  }

  @override
  Future<Task> complete(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksEndpoint}/$id/complete');
      debugPrint('Completing task at: $url');

      final response = await _client.patch(url);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      _validateResponse(response);

      if (response.statusCode == 204 || response.body.isEmpty) {
        // レスポンスが空の場合は、タスクを取得して返す
        final task = await findById(id);
        if (task == null) {
          throw Exception('タスクが見つかりません: $id');
        }
        return task;
      }

      final taskJson = json.decode(response.body);
      return Task.fromJson(taskJson);
    } catch (e) {
      debugPrint('Error completing task: $e');
      throw Exception('タスクの完了に失敗しました: $e');
    }
  }

  @override
  Future<Task> uncomplete(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksEndpoint}/$id/uncomplete');
      debugPrint('Uncompleting task at: $url');

      final response = await _client.patch(url);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      _validateResponse(response);

      if (response.statusCode == 204 || response.body.isEmpty) {
        // レスポンスが空の場合は、タスクを取得して返す
        final task = await findById(id);
        if (task == null) {
          throw Exception('タスクが見つかりません: $id');
        }
        return task;
      }

      final taskJson = json.decode(response.body);
      return Task.fromJson(taskJson);
    } catch (e) {
      debugPrint('Error uncompleting task: $e');
      throw Exception('タスクの未完了への変更に失敗しました: $e');
    }
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode == 204) return;

    if (response.statusCode >= 400) {
      Map<String, dynamic>? errorResponse;
      try {
        errorResponse = json.decode(response.body);
      } catch (e) {
        debugPrint('Error parsing error response: $e');
      }

      final message =
          errorResponse?['message'] ??
          'APIリクエストが失敗しました (${response.statusCode})';
      throw Exception(message);
    }

    if (response.statusCode == 201) {
      debugPrint('Resource created successfully');
    }
  }
}
