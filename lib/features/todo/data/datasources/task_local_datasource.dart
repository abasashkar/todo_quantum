import 'package:hive/hive.dart';
import 'package:todotask/core/constants/hive_constants.dart';
import 'package:todotask/features/todo/data/models/task_hive_model.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

abstract class TaskLocalDataSource {
  Future<List<Task>> getTasks();

  Future<Task?> getTaskById(String id);

  Future<void> saveTask(Task task);

  Future<void> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._box);

  final Box<TaskHiveModel> _box;

  @override
  Future<List<Task>> getTasks() async {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveTask(Task task) async {
    await _box.put(task.id, TaskHiveModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}

Future<Box<TaskHiveModel>> openTasksBox() async {
  return Hive.openBox<TaskHiveModel>(HiveConstants.tasksBox);
}
