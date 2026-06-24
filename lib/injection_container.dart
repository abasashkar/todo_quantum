import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todotask/core/services/notification_service.dart';
import 'package:todotask/core/services/settings_service.dart';
import 'package:todotask/features/todo/data/datasources/task_local_datasource.dart';
import 'package:todotask/features/todo/data/models/task_hive_model.dart';
import 'package:todotask/features/todo/data/repositories/task_repository_impl.dart';
import 'package:todotask/features/todo/domain/repositories/task_repository.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskHiveModelAdapter());

  final tasksBox = await openTasksBox();
  final settingsBox = await openSettingsBox();

  sl.registerLazySingleton<Box<TaskHiveModel>>(() => tasksBox);
  sl.registerLazySingleton<Box<dynamic>>(() => settingsBox);

  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SettingsService>(
    () => SettingsServiceImpl(sl()),
  );

  sl.registerLazySingleton<NotificationService>(
    NotificationServiceImpl.new,
  );

  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl(), sl()),
  );

  sl.registerFactory(
    () => TodoBloc(
      repository: sl(),
      settingsService: sl(),
    ),
  );

  final notificationService = sl<NotificationService>();
  await notificationService.init();
  await notificationService.requestPermissions();
}
