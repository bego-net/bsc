import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/study_week.dart';
import 'notification_service.dart';

/// Notification channel ID used for Thursday reminders.
const _kThursdayChannelId = 'thursday_reminder';
const _kThursdayChannelName = 'Thursday Study Reminder';
const _kThursdayNotificationId = 1001;
const _kTestNotificationId = 1002;

/// Concrete [NotificationService] using flutter_local_notifications and timezone.
///
/// NOTE: flutter_local_notifications does NOT work on the web (Chrome).
/// All scheduling calls are silently skipped when [kIsWeb] is true.
/// To test on device, use the hidden "Send test notification" button in Admin tools.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

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

    await _plugin.initialize(initSettings);

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
      _kThursdayNotificationId,
      title,
      body,
      tzTime,
      notificationDetails,
      payload: 'team_bs',
      // Use inexact scheduling — no SCHEDULE_EXACT_ALARM permission needed.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint(
      '[NotificationService] Scheduled Thursday reminder at $tzTime for ${week.passageText}',
    );
  }

  @override
  Future<void> cancelThursdayReminder() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(_kThursdayNotificationId);
    debugPrint('[NotificationService] Thursday reminder cancelled.');
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
      _kTestNotificationId,
      title,
      body,
      notificationDetails,
      payload: 'team_bs',
    );
    debugPrint('[NotificationService] Sent test notification.');
  }
}
