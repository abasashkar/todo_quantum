import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

class TaskFilterHelper {
  static List<Task> apply({
    required List<Task> tasks,
    required String searchQuery,
    required TaskFilter filter,
  }) {
    final query = searchQuery.trim().toLowerCase();

    var filtered = tasks.where((task) {
      if (query.isEmpty) return true;
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();

    filtered = switch (filter) {
      TaskFilter.all => filtered,
      TaskFilter.active =>
        filtered.where((task) => !task.isCompleted).toList(),
      TaskFilter.completed =>
        filtered.where((task) => task.isCompleted).toList(),
      TaskFilter.highPriority => filtered
          .where((task) => task.priority == TaskPriority.high)
          .toList(),
      TaskFilter.dueToday =>
        filtered.where((task) => task.isDueToday).toList(),
      TaskFilter.overdue =>
        filtered.where((task) => task.isOverdue).toList(),
    };

    filtered.sort(_compareTasks);
    return filtered;
  }

  static int _compareTasks(Task a, Task b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }

    final aDue = a.dueDate;
    final bDue = b.dueDate;
    if (aDue != null && bDue != null) {
      return aDue.compareTo(bDue);
    }
    if (aDue != null) return -1;
    if (bDue != null) return 1;

    return b.priority.index.compareTo(a.priority.index);
  }
}
