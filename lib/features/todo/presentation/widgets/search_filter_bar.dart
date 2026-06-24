import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/core/theme/app_colors.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_state.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  static IconData _filterIcon(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.all => Icons.grid_view_rounded,
      TaskFilter.active => Icons.radio_button_unchecked,
      TaskFilter.completed => Icons.check_circle_outline,
      TaskFilter.highPriority => Icons.flag_rounded,
      TaskFilter.dueToday => Icons.today_rounded,
      TaskFilter.overdue => Icons.warning_amber_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.softShadow(brightness),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                filled: true,
                fillColor: brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {
                context.read<TodoBloc>().add(TodoSearchChanged(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: TaskFilter.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = TaskFilter.values[index];
              return BlocBuilder<TodoBloc, TodoState>(
                buildWhen: (previous, current) =>
                    previous.filter != current.filter,
                builder: (context, state) {
                  final selected = state.filter == filter;
                  return FilterChip(
                    avatar: Icon(
                      _filterIcon(filter),
                      size: 16,
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                    ),
                    label: Text(filter.label),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: brightness == Brightness.dark
                        ? colorScheme.surfaceContainerHighest
                        : Colors.white,
                    onSelected: (_) {
                      context
                          .read<TodoBloc>()
                          .add(TodoFilterChanged(filter));
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
