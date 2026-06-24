import 'package:flutter/material.dart';
import 'package:todotask/core/enums/task_priority.dart';

class AppColors {
  static const seed = Color(0xFF6366F1);
  static const seedDark = Color(0xFF818CF8);

  static const priorityLow = Color(0xFF10B981);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityHigh = Color(0xFFEF4444);

  static Color priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => priorityLow,
      TaskPriority.medium => priorityMedium,
      TaskPriority.high => priorityHigh,
    };
  }

  static LinearGradient headerGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    );
  }

  static List<BoxShadow> softShadow(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

extension TaskPriorityStyle on TaskPriority {
  IconData get icon {
    return switch (this) {
      TaskPriority.low => Icons.arrow_downward_rounded,
      TaskPriority.medium => Icons.remove_rounded,
      TaskPriority.high => Icons.priority_high_rounded,
    };
  }
}
