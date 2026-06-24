import 'package:equatable/equatable.dart';
import 'package:todotask/core/enums/task_priority.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.reminderEnabled = false,
  });

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool reminderEnabled;

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.isBefore(today);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? reminderEnabled,
    bool clearDueDate = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        dueDate,
        isCompleted,
        createdAt,
        completedAt,
        reminderEnabled,
      ];
}
