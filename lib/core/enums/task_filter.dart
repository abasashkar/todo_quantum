enum TaskFilter {
  all,
  active,
  completed,
  highPriority,
  dueToday,
  overdue;

  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.highPriority:
        return 'High Priority';
      case TaskFilter.dueToday:
        return 'Due Today';
      case TaskFilter.overdue:
        return 'Overdue';
    }
  }
}
