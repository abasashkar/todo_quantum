import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todotask/app.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/core/services/settings_service.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';
import 'package:todotask/features/todo/domain/repositories/task_repository.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/injection_container.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockSettingsService extends Mock implements SettingsService {}

final _fallbackTask = Task(
  id: 'fallback',
  title: 'Fallback',
  description: '',
  priority: TaskPriority.medium,
  isCompleted: false,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  late _MockTaskRepository repository;
  late _MockSettingsService settingsService;

  setUpAll(() {
    registerFallbackValue(_fallbackTask);
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GetIt.instance.reset();

    repository = _MockTaskRepository();
    settingsService = _MockSettingsService();

    when(() => settingsService.getThemeMode())
        .thenAnswer((_) async => ThemeMode.light);
    when(() => repository.getTasks()).thenAnswer((_) async => []);

    sl.registerFactory(
      () => TodoBloc(
        repository: repository,
        settingsService: settingsService,
      ),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('shows home page with empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Search tasks...'), findsOneWidget);
  });

  testWidgets('opens new task form from FAB', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('PRIORITY'), findsOneWidget);
  });

  testWidgets('opens edit form and saves changes', (WidgetTester tester) async {
    final task = Task(
      id: '1',
      title: 'Buy groceries',
      description: 'Milk and eggs',
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: DateTime(2026, 6, 24),
    );
    var tasks = [task];

    when(() => repository.getTasks()).thenAnswer((_) async => tasks);
    when(() => repository.saveTask(any())).thenAnswer((invocation) async {
      tasks = [invocation.positionalArguments[0] as Task];
    });

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Buy groceries'),
      'Buy organic groceries',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => repository.saveTask(
        task.copyWith(title: 'Buy organic groceries'),
      ),
    ).called(1);
    expect(find.text('Task updated successfully'), findsOneWidget);
    expect(find.text('Edit Task'), findsNothing);
    expect(find.text('Buy organic groceries'), findsOneWidget);
  });
}
