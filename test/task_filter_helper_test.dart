import 'package:flutter_test/flutter_test.dart';
import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/core/utils/task_filter_helper.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

void main() {
  final now = DateTime(2026, 6, 24, 10);

  Task buildTask({
    required String id,
    required String title,
    String description = '',
    bool isCompleted = false,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isCompleted: isCompleted,
      createdAt: now,
    );
  }

  group('TaskFilterHelper', () {
    test('filters by search query on title and description', () {
      final tasks = [
        buildTask(id: '1', title: 'Buy milk', description: 'Grocery'),
        buildTask(id: '2', title: 'Workout', description: 'Gym session'),
      ];

      final result = TaskFilterHelper.apply(
        tasks: tasks,
        searchQuery: 'gym',
        filter: TaskFilter.all,
      );

      expect(result.length, 1);
      expect(result.first.title, 'Workout');
    });

    test('filters active and completed tasks', () {
      final tasks = [
        buildTask(id: '1', title: 'Open task'),
        buildTask(id: '2', title: 'Done task', isCompleted: true),
      ];

      final active = TaskFilterHelper.apply(
        tasks: tasks,
        searchQuery: '',
        filter: TaskFilter.active,
      );
      final completed = TaskFilterHelper.apply(
        tasks: tasks,
        searchQuery: '',
        filter: TaskFilter.completed,
      );

      expect(active.length, 1);
      expect(completed.length, 1);
      expect(active.first.title, 'Open task');
      expect(completed.first.title, 'Done task');
    });

    test('filters high priority and overdue tasks', () {
      final tasks = [
        buildTask(
          id: '1',
          title: 'Urgent',
          priority: TaskPriority.high,
        ),
        buildTask(
          id: '2',
          title: 'Late',
          dueDate: DateTime(2026, 6, 20),
        ),
      ];

      final highPriority = TaskFilterHelper.apply(
        tasks: tasks,
        searchQuery: '',
        filter: TaskFilter.highPriority,
      );
      final overdue = TaskFilterHelper.apply(
        tasks: tasks,
        searchQuery: '',
        filter: TaskFilter.overdue,
      );

      expect(highPriority.length, 1);
      expect(highPriority.first.title, 'Urgent');
      expect(overdue.length, 1);
      expect(overdue.first.title, 'Late');
    });
  });
}
