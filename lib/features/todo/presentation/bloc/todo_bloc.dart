import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotask/core/services/settings_service.dart';
import 'package:todotask/core/utils/task_filter_helper.dart';
import 'package:todotask/features/todo/domain/repositories/task_repository.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc({
    required TaskRepository repository,
    required SettingsService settingsService,
  })  : _repository = repository,
        _settingsService = settingsService,
        super(const TodoState()) {
    on<TodoStarted>(_onStarted);
    on<TodoTaskSaved>(_onTaskSaved);
    on<TodoTaskDeleted>(_onTaskDeleted);
    on<TodoTaskToggled>(_onTaskToggled);
    on<TodoSearchChanged>(_onSearchChanged);
    on<TodoFilterChanged>(_onFilterChanged);
    on<TodoThemeChanged>(_onThemeChanged);
  }

  final TaskRepository _repository;
  final SettingsService _settingsService;

  Future<void> _onStarted(TodoStarted event, Emitter<TodoState> emit) async {
    emit(state.copyWith(status: TodoStatus.loading, clearError: true));
    try {
      final themeMode = await _settingsService.getThemeMode();
      final tasks = await _repository.getTasks();
      emit(
        _withFilteredTasks(
          state.copyWith(
            status: TodoStatus.success,
            tasks: tasks,
            themeMode: themeMode,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'Failed to load tasks.',
        ),
      );
    }
  }

  Future<void> _onTaskSaved(
    TodoTaskSaved event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _repository.saveTask(event.task);
      await _reloadTasks(emit);
    } catch (_) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'Failed to save task.',
        ),
      );
    }
  }

  Future<void> _onTaskDeleted(
    TodoTaskDeleted event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _repository.deleteTask(event.taskId);
      await _reloadTasks(emit);
    } catch (_) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'Failed to delete task.',
        ),
      );
    }
  }

  Future<void> _onTaskToggled(
    TodoTaskToggled event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _repository.toggleTaskCompletion(event.taskId);
      await _reloadTasks(emit);
    } catch (_) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'Failed to update task.',
        ),
      );
    }
  }

  void _onSearchChanged(TodoSearchChanged event, Emitter<TodoState> emit) {
    emit(
      _withFilteredTasks(
        state.copyWith(searchQuery: event.query),
      ),
    );
  }

  void _onFilterChanged(TodoFilterChanged event, Emitter<TodoState> emit) {
    emit(
      _withFilteredTasks(
        state.copyWith(filter: event.filter),
      ),
    );
  }

  Future<void> _onThemeChanged(
    TodoThemeChanged event,
    Emitter<TodoState> emit,
  ) async {
    await _settingsService.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _reloadTasks(Emitter<TodoState> emit) async {
    final tasks = await _repository.getTasks();
    emit(
      _withFilteredTasks(
        state.copyWith(status: TodoStatus.success, tasks: tasks),
      ),
    );
  }

  TodoState _withFilteredTasks(TodoState current) {
    final filtered = TaskFilterHelper.apply(
      tasks: current.tasks,
      searchQuery: current.searchQuery,
      filter: current.filter,
    );
    return current.copyWith(filteredTasks: filtered);
  }
}
