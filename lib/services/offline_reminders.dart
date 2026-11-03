import 'package:flutter/foundation.dart';

import '../repositories/ot_repository.dart';
import '../repositories/team_repository.dart';
import 'notification_service.dart';

/// Service to ensure daily and Thursday reminders are scheduled from cached data at startup.
class OfflineReminders {
  OfflineReminders._();

  /// Schedules daily and Thursday reminders from cached data at startup.
  static Future<void> scheduleCachedReminders({
    required TeamRepository teamRepo,
    required OtRepository otRepo,
    required NotificationService notificationService,
    String? uid,
    String reminderTime = '07:00',
    String languageCode = 'am',
  }) async {
    try {
      // 1. Thursday reminder from cached team week
      final teamWeek = await teamRepo.getCurrentWeek();
      if (teamWeek != null) {
        await notificationService.scheduleThursdayReminder(teamWeek, languageCode);
      }

      // 2. Daily OT reminders from cached OT plan
      final otWeek = await otRepo.getCurrentWeek();
      if (otWeek != null) {
        final days = otWeek.days.isNotEmpty
            ? otWeek.days
            : await otRepo.getDaysForWeek(otWeek.id);
        final enabled = uid != null
            ? await otRepo.getOtRemindersEnabled(uid)
            : true;
        await notificationService.scheduleOtReminders(
          week: otWeek.copyWith(days: days),
          reminderTime: reminderTime,
          enabled: enabled,
          languageCode: languageCode,
        );
      }

      // 3. Daily Individual Bible Study reminder from cached preferences
      await notificationService.scheduleDailyStudyReminder(
        reminderTime: reminderTime,
        enabled: true,
        languageCode: languageCode,
      );
    } catch (e) {
      debugPrint('[OfflineReminders] Scheduled reminders notice: $e');
    }
  }
}
