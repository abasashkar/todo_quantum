import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodoStarted extends TodoEvent {
  const TodoStarted();
}

class TodoTaskSaved extends TodoEvent {
  const TodoTaskSaved(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class TodoTaskDeleted extends TodoEvent {
  const TodoTaskDeleted(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class TodoTaskToggled extends TodoEvent {
  const TodoTaskToggled(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class TodoSearchChanged extends TodoEvent {
  const TodoSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class TodoFilterChanged extends TodoEvent {
  const TodoFilterChanged(this.filter);

  final TaskFilter filter;

  @override
  List<Object?> get props => [filter];
}

class TodoThemeChanged extends TodoEvent {
  const TodoThemeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}
