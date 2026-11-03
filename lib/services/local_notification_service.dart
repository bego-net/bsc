import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/ot_day.dart';
import '../models/ot_week.dart';
import '../models/study_week.dart';
import 'notification_service.dart';

/// Notification channel ID used for Thursday reminders.
const _kThursdayChannelId = 'thursday_reminder';
const _kThursdayChannelName = 'Thursday Study Reminder';
const _kThursdayNotificationId = 1001;
const _kTestNotificationId = 1002;

/// Notification channel ID used for daily individual Bible study reminders.
const _kDailyStudyChannelId = 'daily_study_reminder';
const _kDailyStudyChannelName = 'Daily Bible Study Reminder';
const _kDailyStudyNotificationId = 1003;

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
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('[NotificationService] Timezone initialization fallback: $e');
    }

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

    // Configure channels and request Android 13+ POST_NOTIFICATIONS permission politely.
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kThursdayChannelId,
          _kThursdayChannelName,
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kOtChannelId,
          _kOtChannelName,
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kDailyStudyChannelId,
          _kDailyStudyChannelName,
          importance: Importance.high,
          playSound: true,
        ),
      );
    }

    _initialized = true;
  }

  @override
  Future<void> scheduleDailyStudyReminder({
    required String reminderTime,
    required bool enabled,
    String languageCode = 'am',
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      await cancelDailyStudyReminder();
      if (!enabled) return;

      final (hour, minute) = parseReminderHourMinute(reminderTime);
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        _kDailyStudyChannelId,
        _kDailyStudyChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      final title = languageCode == 'am'
          ? 'የዕለት የመጽሐፍ ቅዱስ ንባብ'
          : 'Daily Bible Study';
      final body = languageCode == 'am'
          ? 'የዛሬውን ጥናትዎን ለማንበብ ጊዜ ይውሰዱ።'
          : 'Take time for your daily Bible study today.';

      await _plugin.zonedSchedule(
        id: _kDailyStudyNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        payload: 'individual_bs',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('[NotificationService] Scheduled daily study reminder at $scheduledDate');
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling daily study reminder: $e');
    }
  }

  @override
  Future<void> cancelDailyStudyReminder() async {
    if (kIsWeb || !_initialized) return;
    try {
      await _plugin.cancel(id: _kDailyStudyNotificationId);
      debugPrint('[NotificationService] Daily study reminder cancelled.');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling daily study reminder: $e');
    }
  }

  @override
  Future<void> scheduleThursdayReminder(StudyWeek week, [String languageCode = 'am']) async {
    // flutter_local_notifications does not work on web (Chrome). Skip silently.
    if (kIsWeb || !_initialized) return;

    try {
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

      final passage = week.localizedPassageText(languageCode);
      final title = languageCode == 'am'
          ? 'የነገ የዓርብ ጥናት፡ $passage'
          : 'Friday study tomorrow: $passage';
      final body = languageCode == 'am'
          ? '${week.sessionTime}፣ ${week.place}። ጥያቄዎቹን አንብበዋል?'
          : '${week.sessionTime}, ${week.place}. Have you read the questions?';

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
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling Thursday reminder: $e');
    }
  }

  @override
  Future<void> cancelThursdayReminder() async {
    if (kIsWeb || !_initialized) return;
    try {
      await _plugin.cancel(id: _kThursdayNotificationId);
      debugPrint('[NotificationService] Thursday reminder cancelled.');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling Thursday reminder: $e');
    }
  }

  @override
  Future<void> scheduleOtReminders({
    required OtWeek week,
    required String reminderTime,
    required bool enabled,
    String languageCode = 'am',
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
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

      final dayList = week.days.isNotEmpty
          ? week.days
          : [
              for (int j = 0; j < 7; j++)
                week.getDayForDate(
                  '${now.add(Duration(days: j)).year}-${now.add(Duration(days: j)).month.toString().padLeft(2, '0')}-${now.add(Duration(days: j)).day.toString().padLeft(2, '0')}',
                ),
            ].whereType<OtDay>().toList();

      for (int i = 0; i < dayList.length; i++) {
        final day = dayList[i];
        if (day.book.isEmpty) continue;

        final dt = DateTime.tryParse(day.date);
        if (dt == null) continue;

        final targetDate = DateTime(dt.year, dt.month, dt.day, hour, minute);
        if (targetDate.isAfter(now)) {
          final tzTime = tz.TZDateTime.from(targetDate, tz.local);
          final passage = day.localizedPassageText(languageCode);
          final title = languageCode == 'am'
              ? 'የዛሬ የብሉይ ኪዳን ንባብ፡ $passage'
              : 'Old Testament today: $passage';
          final body = week.topic.isNotEmpty
              ? '(${week.topic})'
              : (languageCode == 'am' ? 'የዕለት ንባብ' : 'Daily reading');

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
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling OT reminders: $e');
    }
  }

  @override
  Future<void> cancelOtReminders() async {
    if (kIsWeb || !_initialized) return;
    try {
      for (int i = 0; i < 10; i++) {
        await _plugin.cancel(id: _kOtBaseNotificationId + i);
      }
      debugPrint('[NotificationService] Old Testament reminders cancelled.');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling OT reminders: $e');
    }
  }

  @override
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    // flutter_local_notifications does not work on web (Chrome). Skip silently.
    if (kIsWeb || !_initialized) return;

    try {
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
    } catch (e) {
      debugPrint('[NotificationService] Error sending test notification: $e');
    }
  }
}
