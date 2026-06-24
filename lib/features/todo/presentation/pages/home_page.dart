import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/core/theme/app_colors.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_state.dart';
import 'package:todotask/features/todo/presentation/utils/task_form_navigation.dart';
import 'package:todotask/features/todo/presentation/widgets/empty_state.dart';
import 'package:todotask/features/todo/presentation/widgets/search_filter_bar.dart';
import 'package:todotask/features/todo/presentation/widgets/task_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: BlocConsumer<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state.status == TodoStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            if (state.status == TodoStatus.loading && state.tasks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
      
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ColoredBox(
                    color: scaffoldColor,
                    child: SizedBox(height: topPadding),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    activeCount: state.activeCount,
                    completedCount: state.completedCount,
                    themeMode: state.themeMode,
                  ),
                ),
                const SliverToBoxAdapter(child: SearchFilterBar()),
                if (state.filteredTasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: state.searchQuery.isNotEmpty ||
                              state.filter != TaskFilter.all
                          ? 'No matching tasks'
                          : 'No tasks yet',
                      subtitle: state.searchQuery.isNotEmpty ||
                              state.filter != TaskFilter.all
                          ? 'Try a different search or filter.'
                          : 'Tap the button below to create your first task.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: state.filteredTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        return TaskTile(task: state.filteredTasks[index]);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => openTaskForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Task'),
          ),
        ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.activeCount,
    required this.completedCount,
    required this.themeMode,
  });

  final int activeCount;
  final int completedCount;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, MMM d').format(now);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient(brightness),
        borderRadius: BorderRadius.circular(28),
        boxShadow: brightness == Brightness.light
            ? [
                BoxShadow(
                  color: AppColors.seed.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'My Tasks',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
                    context.read<TodoBloc>().add(TodoThemeChanged(nextMode));
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  count: activeCount,
                  icon: Icons.pending_actions_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Completed',
                  count: completedCount,
                  icon: Icons.verified_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
