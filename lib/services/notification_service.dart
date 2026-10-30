import 'package:flutter/foundation.dart';

import '../models/study_week.dart';

/// Abstract service for local reminders and notifications.
abstract class NotificationService {
  /// Stream/notifier triggered when user taps a notification with a payload.
  ValueNotifier<String?> get selectedPayload;

  /// Initializes notification plugins, time zones, and permissions.
  Future<void> initialize();

  /// Schedules the weekly Thursday reminder for [week].
  Future<void> scheduleThursdayReminder(StudyWeek week);

  /// Cancels any scheduled Thursday reminder.
  Future<void> cancelThursdayReminder();

  /// Sends an immediate test notification (used in Admin Tools to verify on phone/emulator).
  Future<void> sendTestNotification({
    required String title,
    required String body,
  });
}

/// Pure helper to calculate the next Thursday occurrence for a given [hour] and [minute].
/// If today is Thursday before [hour]:[minute], returns today.
/// If today is Thursday after [hour]:[minute], returns next Thursday (+7 days).
DateTime calculateNextThursday(DateTime from, int hour, int minute) {
  final todayTarget = DateTime(from.year, from.month, from.day, hour, minute);

  if (from.weekday == DateTime.thursday) {
    if (from.isBefore(todayTarget)) {
      return todayTarget;
    } else {
      return todayTarget.add(const Duration(days: 7));
    }
  } else if (from.weekday < DateTime.thursday) {
    final daysUntil = DateTime.thursday - from.weekday;
    return DateTime(from.year, from.month, from.day + daysUntil, hour, minute);
  } else {
    final daysUntil = (7 - from.weekday) + DateTime.thursday;
    return DateTime(from.year, from.month, from.day + daysUntil, hour, minute);
  }
}

/// Parses a reminder time string like "18:00" or "6:00 PM" into (hour, minute).
(int, int) parseReminderHourMinute(String timeString) {
  try {
    final trimmed = timeString.trim();
    final isPm = trimmed.toLowerCase().contains('pm');
    final isAm = trimmed.toLowerCase().contains('am');
    final clean = trimmed.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
    final parts = clean.split(':');

    int hour = int.parse(parts[0]);
    int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    return (hour.clamp(0, 23), minute.clamp(0, 59));
  } catch (_) {
    return (18, 0); // Default 6:00 PM
  }
}
