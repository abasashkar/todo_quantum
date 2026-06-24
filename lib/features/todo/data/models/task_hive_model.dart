import 'package:hive/hive.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

class TaskHiveModel extends HiveObject {
  TaskHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priorityIndex,
    this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    required this.reminderEnabled,
  });

  final String id;
  final String title;
  final String description;
  final int priorityIndex;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool reminderEnabled;

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: TaskPriority.values[priorityIndex],
      dueDate: dueDate,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      reminderEnabled: reminderEnabled,
    );
  }

  factory TaskHiveModel.fromEntity(Task task) {
    return TaskHiveModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priorityIndex: task.priority.index,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      reminderEnabled: task.reminderEnabled,
    );
  }
}

class TaskHiveModelAdapter extends TypeAdapter<TaskHiveModel> {
  @override
  final int typeId = 0;

  @override
  TaskHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return TaskHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      priorityIndex: fields[3] as int,
      dueDate: fields[4] as DateTime?,
      isCompleted: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime?,
      reminderEnabled: numOfFields > 9
          ? fields[9] as bool
          : fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priorityIndex)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.reminderEnabled);
  }
}
