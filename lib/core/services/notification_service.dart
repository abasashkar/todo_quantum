import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:todotask/features/todo/domain/entities/task.dart';

abstract class NotificationService {
  Future<void> init();

  Future<void> requestPermissions();

  Future<void> scheduleTaskReminder(Task task);

  Future<void> cancelTaskReminder(String taskId);
}

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  Future<void> scheduleTaskReminder(Task task) async {
    if (!task.reminderEnabled || task.dueDate == null || task.isCompleted) {
      await cancelTaskReminder(task.id);
      return;
    }

    final scheduledDate = task.dueDate!;
    if (scheduledDate.isBefore(DateTime.now())) {
      await cancelTaskReminder(task.id);
      return;
    }

    final notificationId = _notificationId(task.id);
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task due dates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      notificationId,
      'Task Reminder',
      task.title,
      tzScheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  @override
  Future<void> cancelTaskReminder(String taskId) async {
    await _plugin.cancel(_notificationId(taskId));
  }

  int _notificationId(String taskId) => taskId.hashCode & 0x7FFFFFFF;
}
