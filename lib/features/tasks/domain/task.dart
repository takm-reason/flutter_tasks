import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final TaskPriority priority;

  Task({
    String? id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.priority = TaskPriority.medium,
  }) : id = id ?? '',
       createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    TaskPriority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: isCompleted == true ? (completedAt ?? DateTime.now()) : null,
      priority: priority ?? this.priority,
    );
  }

  // JSONシリアライズ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priorityToNumber(priority),
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // JSONデシリアライズ
  factory Task.fromJson(Map<String, dynamic> json) {
    final completedAt =
        json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String).toLocal()
            : null;
    final isCompleted = json['is_completed'] as bool? ?? completedAt != null;

    return Task(
      id: (json['id']?.toString()) ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority:
          json['priority'] is int
              ? _priorityFromNumber(json['priority'] as int)
              : priorityFromString(json['priority']?.toString() ?? 'medium'),
      createdAt: DateTime.parse(json['created_at'] as String),
      dueDate:
          json['due_date'] != null
              ? DateTime.parse(json['due_date'] as String).toLocal()
              : null,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  // 優先度を文字列に変換（APIの仕様に合わせる）
  static int priorityToNumber(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
    }
  }

  static String priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  // 文字列から優先度に変換（APIの仕様に合わせる）
  static TaskPriority priorityFromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskPriority _priorityFromNumber(int value) {
    switch (value) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }
}

enum TaskPriority {
  low('低', '🟢'),
  medium('中', '🟡'),
  high('高', '🔴');

  final String label;
  final String emoji;
  const TaskPriority(this.label, this.emoji);
}
