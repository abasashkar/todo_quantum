import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/pages/task_form_page.dart';

Future<void> openTaskForm(BuildContext context, {Task? task}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: context.read<TodoBloc>(),
        child: TaskFormPage(task: task),
      ),
    ),
  );
}
