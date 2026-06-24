import 'package:todotask/core/services/notification_service.dart';
import 'package:todotask/features/todo/data/datasources/task_local_datasource.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';
import 'package:todotask/features/todo/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(
    this._localDataSource,
    this._notificationService,
  );

  final TaskLocalDataSource _localDataSource;
  final NotificationService _notificationService;

  @override
  Future<List<Task>> getTasks() => _localDataSource.getTasks();

  @override
  Future<Task?> getTaskById(String id) => _localDataSource.getTaskById(id);

  @override
  Future<void> saveTask(Task task) async {
    await _localDataSource.saveTask(task);
    if (task.reminderEnabled && !task.isCompleted) {
      await _notificationService.scheduleTaskReminder(task);
    } else {
      await _notificationService.cancelTaskReminder(task.id);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
    await _notificationService.cancelTaskReminder(id);
  }

  @override
  Future<Task> toggleTaskCompletion(String id) async {
    final task = await _localDataSource.getTaskById(id);
    if (task == null) {
      throw StateError('Task not found');
    }

    if (task.isCompleted) {
      final reopened = task.copyWith(
        isCompleted: false,
        clearCompletedAt: true,
      );
      await saveTask(reopened);
      return reopened;
    }

    final completedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    await saveTask(completedTask);
    return completedTask;
  }
}
