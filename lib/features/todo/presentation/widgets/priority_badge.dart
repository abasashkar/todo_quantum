import 'package:flutter/material.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/core/theme/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.priorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (priority) {
              TaskPriority.low => Icons.arrow_downward_rounded,
              TaskPriority.medium => Icons.remove_rounded,
              TaskPriority.high => Icons.priority_high_rounded,
            },
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
