import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todotask/core/enums/task_priority.dart';
import 'package:todotask/core/theme/app_colors.dart';
import 'package:todotask/core/widgets/app_card.dart';
import 'package:todotask/features/todo/domain/entities/task.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todotask/features/todo/presentation/bloc/todo_event.dart';
import 'package:uuid/uuid.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.task});

  final Task? task;

  bool get isEditing => task != null;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    if (task != null) {
      _priority = task.priority;
      _dueDate = task.dueDate;
      _reminderEnabled = task.reminderEnabled;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'DETAILS',
                    icon: Icons.edit_note_rounded,
                  ),
                  TextFormField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.titleMedium,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'What needs to be done?',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add more details...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'PRIORITY',
                    icon: Icons.flag_rounded,
                  ),
                  Row(
                    children: TaskPriority.values.map((priority) {
                      final selected = _priority == priority;
                      final color = AppColors.priorityColor(priority);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: priority != TaskPriority.high ? 8 : 0,
                          ),
                          child: Material(
                            color: selected
                                ? color.withValues(alpha: 0.15)
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _priority = priority),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? color
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      switch (priority) {
                                        TaskPriority.low =>
                                          Icons.arrow_downward_rounded,
                                        TaskPriority.medium =>
                                          Icons.remove_rounded,
                                        TaskPriority.high =>
                                          Icons.priority_high_rounded,
                                      },
                                      color: color,
                                      size: 20,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      priority.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'SCHEDULE',
                    icon: Icons.event_rounded,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    title: const Text('Due date'),
                    subtitle: Text(
                      _dueDate == null
                          ? 'No due date set'
                          : DateFormat('EEE, MMM d • h:mm a')
                              .format(_dueDate!),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _dueDate = null;
                              _reminderEnabled = false;
                            }),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit_calendar_rounded),
                          onPressed: _pickDueDate,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    title: const Text('Enable reminder'),
                    subtitle: const Text('Get notified when the task is due'),
                    value: _reminderEnabled,
                    onChanged: _dueDate == null
                        ? null
                        : (value) => setState(() => _reminderEnabled = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final earliestDate = _dueDate != null && _dueDate!.isBefore(now)
        ? DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day)
        : DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: earliestDate,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? now),
    );
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.task;
    final task = Task(
      id: existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      isCompleted: existing?.isCompleted ?? false,
      createdAt: existing?.createdAt ?? DateTime.now(),
      completedAt: existing?.completedAt,
      reminderEnabled: _reminderEnabled && _dueDate != null,
    );

    context.read<TodoBloc>().add(TodoTaskSaved(task));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.isEditing ? 'Task updated successfully' : 'Task created',
              ),
            ],
          ),
        ),
      );
    Navigator.of(context).pop();
  }
}
