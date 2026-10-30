import 'package:flutter/foundation.dart';

import '../models/study_week.dart';
import 'notification_service.dart';

/// Fake implementation of [NotificationService] for unit/widget tests and offline mode.
class FakeNotificationService implements NotificationService {
  @override
  final ValueNotifier<String?> selectedPayload = ValueNotifier<String?>(null);

  bool isInitialized = false;
  StudyWeek? scheduledWeek;
  DateTime? scheduledDateTime;
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
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    lastNotificationTitle = title;
    lastNotificationBody = body;
  }
}
