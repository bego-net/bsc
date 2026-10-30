import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/ot_week.dart';
import '../models/study_week.dart';
import 'notification_service.dart';

/// Notification channel ID used for Thursday reminders.
const _kThursdayChannelId = 'thursday_reminder';
const _kThursdayChannelName = 'Thursday Study Reminder';
const _kThursdayNotificationId = 1001;
const _kTestNotificationId = 1002;

/// Notification channel ID used for Old Testament daily reminders.
const _kOtChannelId = 'ot_reminder';
const _kOtChannelName = 'Old Testament Daily Reminder';
const _kOtBaseNotificationId = 2000;

/// Concrete [NotificationService] using flutter_local_notifications and timezone.
///
/// NOTE: flutter_local_notifications does NOT work on the web (Chrome).
/// All scheduling calls are silently skipped when [kIsWeb] is true.
/// To test on device, use the hidden "Send test notification" button in Admin tools.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  final ValueNotifier<String?> selectedPayload = ValueNotifier<String?>(null);

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    // flutter_local_notifications does not work on web (Chrome). Skip silently.
    if (kIsWeb) return;

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        selectedPayload.value = response.payload;
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      selectedPayload.value = launchDetails?.notificationResponse?.payload;
    }

    // Request Android 13+ POST_NOTIFICATIONS permission politely.
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  @override
  Future<void> scheduleThursdayReminder(StudyWeek week) async {
    // flutter_local_notifications does not work on web (Chrome). Skip silently.
    if (kIsWeb || !_initialized) return;

    final (hour, minute) = parseReminderHourMinute(week.thursdayReminderTime);
    final nextThursday = calculateNextThursday(DateTime.now(), hour, minute);

    final tzTime = tz.TZDateTime.from(nextThursday, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _kThursdayChannelId,
      _kThursdayChannelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    final title = 'Friday study tomorrow: ${week.passageText}';
    final body =
        '${week.sessionTime}, ${week.place}. Have you read the questions?';

    await _plugin.zonedSchedule(
      id: _kThursdayNotificationId,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: notificationDetails,
      payload: 'team_bs',
      // Use inexact scheduling — no SCHEDULE_EXACT_ALARM permission needed.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint(
      '[NotificationService] Scheduled Thursday reminder at $tzTime for ${week.passageText}',
    );
  }

  @override
  Future<void> cancelThursdayReminder() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(id: _kThursdayNotificationId);
    debugPrint('[NotificationService] Thursday reminder cancelled.');
  }

  @override
  Future<void> scheduleOtReminders({
    required OtWeek week,
    required String reminderTime,
    required bool enabled,
  }) async {
    if (kIsWeb || !_initialized) return;

    // Cancel existing OT reminders first
    await cancelOtReminders();
    if (!enabled) return;

    final (hour, minute) = parseReminderHourMinute(reminderTime);
    final now = DateTime.now();

    const androidDetails = AndroidNotificationDetails(
      _kOtChannelId,
      _kOtChannelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    for (int i = 0; i < week.days.length; i++) {
      final day = week.days[i];
      if (day.book.isEmpty) continue;

      final dt = DateTime.tryParse(day.date);
      if (dt == null) continue;

      final targetDate = DateTime(dt.year, dt.month, dt.day, hour, minute);
      if (targetDate.isAfter(now)) {
        final tzTime = tz.TZDateTime.from(targetDate, tz.local);
        final title = 'Old Testament today: ${day.passageText}';
        final body = week.topic.isNotEmpty ? '(${week.topic})' : 'Daily reading';

        await _plugin.zonedSchedule(
          id: _kOtBaseNotificationId + i,
          title: title,
          body: body,
          scheduledDate: tzTime,
          notificationDetails: notificationDetails,
          payload: 'old_testament',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  @override
  Future<void> cancelOtReminders() async {
    if (kIsWeb || !_initialized) return;
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(id: _kOtBaseNotificationId + i);
    }
    debugPrint('[NotificationService] Old Testament reminders cancelled.');
  }

  @override
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    // flutter_local_notifications does not work on web (Chrome). Skip silently.
    if (kIsWeb || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _kThursdayChannelId,
      _kThursdayChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: _kTestNotificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'team_bs',
    );
    debugPrint('[NotificationService] Sent test notification.');
  }
}
