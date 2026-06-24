import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todotask/core/theme/app_colors.dart';
import 'package:todotask/core/widgets/app_card.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:todotask/features/todo/presentation/utils/task_form_navigation.dart';
import 'package:todotask/features/todo/presentation/widgets/priority_badge.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d • h:mm a');
    final priorityColor = AppColors.priorityColor(task.priority);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      accentColor: task.isCompleted ? colorScheme.outline : priorityColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      onTap: () => openTaskForm(context, task: task),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompletionToggle(task: task),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? colorScheme.outline
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconActionButton(
                icon: Icons.edit_rounded,
                tooltip: 'Edit',
                onPressed: () => openTaskForm(context, task: task),
              ),
              const SizedBox(width: 6),
              IconActionButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Delete',
                color: colorScheme.error,
                backgroundColor:
                    colorScheme.errorContainer.withValues(alpha: 0.35),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PriorityBadge(priority: task.priority),
              if (task.dueDate != null)
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: dateFormat.format(task.dueDate!),
                  color: task.isOverdue
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              if (task.reminderEnabled)
                _InfoChip(
                  icon: Icons.notifications_active_rounded,
                  label: 'Reminder',
                  color: colorScheme.tertiary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.delete_forever_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete task?'),
        content: Text(
          'Delete "${task.title}" permanently? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TodoBloc>().add(TodoTaskDeleted(task.id));
    }
  }
}

class _CompletionToggle extends StatelessWidget {
  const _CompletionToggle({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = AppColors.priorityColor(task.priority);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<TodoBloc>().add(TodoTaskToggled(task.id));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: task.isCompleted
              ? colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted ? colorScheme.primary : priorityColor,
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? Icon(Icons.check_rounded, size: 18, color: colorScheme.onPrimary)
            : null,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
