import 'package:todotask/features/todo/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();

  Future<Task?> getTaskById(String id);

  Future<void> saveTask(Task task);

  Future<void> deleteTask(String id);

  Future<Task> toggleTaskCompletion(String id);
}
