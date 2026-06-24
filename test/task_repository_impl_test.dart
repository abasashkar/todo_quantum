import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/core/services/notification_service.dart';
import 'package:todotask/features/todo/data/datasources/task_local_datasource.dart';
import 'package:todotask/features/todo/data/repositories/task_repository_impl.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';

class _MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  late _MockTaskLocalDataSource dataSource;
  late _MockNotificationService notificationService;
  late TaskRepositoryImpl repository;

  final task = Task(
    id: 'task-1',
    title: 'Daily standup',
    description: 'Team sync',
    priority: TaskPriority.medium,
    dueDate: DateTime(2026, 6, 24, 9),
    isCompleted: false,
    createdAt: DateTime(2026, 6, 24),
    reminderEnabled: true,
  );

  setUpAll(() {
    registerFallbackValue(
      Task(
        id: 'fallback',
        title: 'Fallback',
        description: '',
        priority: TaskPriority.low,
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    dataSource = _MockTaskLocalDataSource();
    notificationService = _MockNotificationService();
    repository = TaskRepositoryImpl(dataSource, notificationService);

    when(() => notificationService.scheduleTaskReminder(any()))
        .thenAnswer((_) async {});
    when(() => notificationService.cancelTaskReminder(any()))
        .thenAnswer((_) async {});
  });

  test('completing a task marks it completed', () async {
    when(() => dataSource.getTaskById('task-1'))
        .thenAnswer((_) async => task);
    when(() => dataSource.saveTask(any())).thenAnswer((_) async {});

    final result = await repository.toggleTaskCompletion('task-1');

    expect(result.isCompleted, isTrue);
    expect(result.id, 'task-1');
    verify(() => dataSource.saveTask(any())).called(1);
  });

  test('reopening a completed task marks it active', () async {
    final completedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime(2026, 6, 24, 10),
    );

    when(() => dataSource.getTaskById('task-1'))
        .thenAnswer((_) async => completedTask);
    when(() => dataSource.saveTask(any())).thenAnswer((_) async {});

    final result = await repository.toggleTaskCompletion('task-1');

    expect(result.isCompleted, isFalse);
    expect(result.completedAt, isNull);
    verify(() => dataSource.saveTask(any())).called(1);
  });
}
