import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotask/core/theme/app_theme.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_state.dart';
import 'package:todotask/features/todo/presentation/pages/home_page.dart';
import 'package:todotask/injection_container.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoBloc>()..add(const TodoStarted()),
      child: BlocBuilder<TodoBloc, TodoState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode,
        builder: (context, state) {
          return MaterialApp(
            title: 'Todo Task',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            builder: (context, child) {
              final brightness = Theme.of(context).brightness;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppTheme.systemUiOverlayStyle(brightness),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
