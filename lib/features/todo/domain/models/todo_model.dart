import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final bool? isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reminderDate;
  final DateTime? reminderTime;
  final String? priority;

  const TodoModel({
    this.id,
    this.title,
    this.description,
    this.isCompleted,
    this.createdAt,
    this.updatedAt,
    this.reminderDate,
    this.reminderTime,
    this.priority,
  });

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderDate,
    DateTime? reminderTime,
    String? priority,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted ?? false,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'priority': priority,
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json, String id) {
    return TodoModel(
      id: id,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate'] as String)
          : null,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
      priority: json['priority'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        createdAt,
        updatedAt,
        reminderDate,
        reminderTime,
        priority
      ];
}
