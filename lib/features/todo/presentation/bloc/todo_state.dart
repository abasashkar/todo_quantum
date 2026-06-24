import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  const TodoState({
    this.status = TodoStatus.initial,
    this.tasks = const [],
    this.filteredTasks = const [],
    this.searchQuery = '',
    this.filter = TaskFilter.all,
    this.themeMode = ThemeMode.system,
    this.errorMessage,
  });

  final TodoStatus status;
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final String searchQuery;
  final TaskFilter filter;
  final ThemeMode themeMode;
  final String? errorMessage;

  int get activeCount => tasks.where((task) => !task.isCompleted).length;

  int get completedCount => tasks.where((task) => task.isCompleted).length;

  TodoState copyWith({
    TodoStatus? status,
    List<Task>? tasks,
    List<Task>? filteredTasks,
    String? searchQuery,
    TaskFilter? filter,
    ThemeMode? themeMode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      themeMode: themeMode ?? this.themeMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        filteredTasks,
        searchQuery,
        filter,
        themeMode,
        errorMessage,
      ];
}
