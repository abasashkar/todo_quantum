import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todotask/core/enums/task_filter.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/core/services/settings_service.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';
import 'package:todotask/features/todo/domain/repositories/task_repository.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_state.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockSettingsService extends Mock implements SettingsService {}

void main() {
  late _MockTaskRepository repository;
  late _MockSettingsService settingsService;
  late TodoBloc bloc;

  final sampleTask = Task(
    id: '1',
    title: 'Sample',
    description: 'Details',
    priority: TaskPriority.high,
    dueDate: DateTime(2026, 6, 25, 9),
    isCompleted: false,
    createdAt: DateTime(2026, 6, 24),
    reminderEnabled: true,
  );

  setUp(() {
    repository = _MockTaskRepository();
    settingsService = _MockSettingsService();
    bloc = TodoBloc(
      repository: repository,
      settingsService: settingsService,
    );
  });

  tearDown(() => bloc.close());

  blocTest<TodoBloc, TodoState>(
    'emits loaded tasks on TodoStarted',
    build: () {
      when(() => settingsService.getThemeMode())
          .thenAnswer((_) async => ThemeMode.light);
      when(() => repository.getTasks()).thenAnswer((_) async => [sampleTask]);
      return bloc;
    },
    act: (bloc) => bloc.add(const TodoStarted()),
    expect: () => [
      const TodoState(status: TodoStatus.loading),
      TodoState(
        status: TodoStatus.success,
        tasks: [sampleTask],
        filteredTasks: [sampleTask],
        themeMode: ThemeMode.light,
      ),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'updates search query and filtered tasks',
    build: () => bloc,
    seed: () => TodoState(
      status: TodoStatus.success,
      tasks: [sampleTask],
      filteredTasks: [sampleTask],
    ),
    act: (bloc) => bloc.add(const TodoSearchChanged('missing')),
    expect: () => [
      TodoState(
        status: TodoStatus.success,
        tasks: [sampleTask],
        filteredTasks: const [],
        searchQuery: 'missing',
      ),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'saves task and reloads list',
    build: () {
      when(() => repository.saveTask(sampleTask)).thenAnswer((_) async {});
      when(() => repository.getTasks()).thenAnswer((_) async => [sampleTask]);
      return bloc;
    },
    seed: () => const TodoState(status: TodoStatus.success),
    act: (bloc) => bloc.add(TodoTaskSaved(sampleTask)),
    expect: () => [
      TodoState(
        status: TodoStatus.success,
        tasks: [sampleTask],
        filteredTasks: [sampleTask],
      ),
    ],
    verify: (_) {
      verify(() => repository.saveTask(sampleTask)).called(1);
      verify(() => repository.getTasks()).called(1);
    },
  );

  blocTest<TodoBloc, TodoState>(
    'changes theme mode',
    build: () {
      when(() => settingsService.setThemeMode(ThemeMode.dark))
          .thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(const TodoThemeChanged(ThemeMode.dark)),
    expect: () => [
      const TodoState(themeMode: ThemeMode.dark),
    ],
    verify: (_) {
      verify(() => settingsService.setThemeMode(ThemeMode.dark)).called(1);
    },
  );

  blocTest<TodoBloc, TodoState>(
    'applies selected filter',
    build: () => bloc,
    seed: () => TodoState(
      status: TodoStatus.success,
      tasks: [
        sampleTask,
        sampleTask.copyWith(id: '2', isCompleted: true),
      ],
      filteredTasks: [
        sampleTask,
        sampleTask.copyWith(id: '2', isCompleted: true),
      ],
    ),
    act: (bloc) => bloc.add(const TodoFilterChanged(TaskFilter.completed)),
    expect: () => [
      TodoState(
        status: TodoStatus.success,
        tasks: [
          sampleTask,
          sampleTask.copyWith(id: '2', isCompleted: true),
        ],
        filteredTasks: [sampleTask.copyWith(id: '2', isCompleted: true)],
        filter: TaskFilter.completed,
      ),
    ],
  );
}
