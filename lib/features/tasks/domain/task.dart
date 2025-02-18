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
  }) : id = id ?? const Uuid().v4(),
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
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.index,
    };
  }

  // JSONデシリアライズ
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      isCompleted: json['isCompleted'] as bool,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
      priority: TaskPriority.values[json['priority'] as int],
    );
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
