import 'package:flutter/foundation.dart';

import '../models/ot_week.dart';
import '../models/study_week.dart';
import 'notification_service.dart';

/// Fake implementation of [NotificationService] for unit/widget tests and offline mode.
class FakeNotificationService implements NotificationService {
  @override
  final ValueNotifier<String?> selectedPayload = ValueNotifier<String?>(null);

  bool isInitialized = false;
  StudyWeek? scheduledWeek;
  DateTime? scheduledDateTime;
  OtWeek? scheduledOtWeek;
  List<String> scheduledOtDates = [];
  bool otRemindersEnabled = true;
  bool otRemindersCancelled = false;
  String? lastNotificationTitle;
  String? lastNotificationBody;

  @override
  Future<void> initialize() async {
    isInitialized = true;
  }

  @override
  Future<void> scheduleThursdayReminder(StudyWeek week) async {
    scheduledWeek = week;
    final (hour, minute) = parseReminderHourMinute(week.thursdayReminderTime);
    scheduledDateTime = calculateNextThursday(DateTime.now(), hour, minute);
  }

  @override
  Future<void> cancelThursdayReminder() async {
    scheduledWeek = null;
    scheduledDateTime = null;
  }

  @override
  Future<void> scheduleOtReminders({
    required OtWeek week,
    required String reminderTime,
    required bool enabled,
  }) async {
    scheduledOtWeek = week;
    otRemindersEnabled = enabled;
    scheduledOtDates.clear();
    otRemindersCancelled = false;

    if (!enabled) return;

    for (final day in week.days) {
      if (day.book.isNotEmpty) {
        scheduledOtDates.add(day.date);
      }
    }
  }

  @override
  Future<void> cancelOtReminders() async {
    scheduledOtWeek = null;
    scheduledOtDates.clear();
    otRemindersCancelled = true;
  }

  @override
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    lastNotificationTitle = title;
    lastNotificationBody = body;
  }
}
