import '../models/ot_day.dart';
import '../models/ot_member_overview_item.dart';
import '../models/ot_week.dart';

/// Abstract repository defining data operations for Old Testament weekly plans.
abstract class OtRepository {
  /// Fetches the current published Old Testament week, or null if none.
  Future<OtWeek?> getCurrentWeek();

  /// Fetches all assigned days for [weekId], sorted by date.
  Future<List<OtDay>> getDaysForWeek(String weekId);

  /// Returns a map of date string -> isCompleted for the user across [dates].
  Future<Map<String, bool>> getUserReadingsForWeek({
    required String uid,
    required String weekId,
    required List<String> dates,
  });

  /// Marks or unmarks a reading for [date] (yyyy-MM-dd).
  Future<void> setDayCompleted({
    required String uid,
    required String weekId,
    required String date,
    required bool completed,
  });

  /// Calculates the user's consecutive day Old Testament reading streak.
  Future<int> getUserStreak(String uid);

  /// Returns past weeks newest first.
  Future<List<OtWeek>> getWeekHistory();

  /// Publishes a new week document with days subcollection and updates config/currentOtWeek.
  Future<OtWeek> publishWeek({
    required String topic,
    required String startDate,
    required List<OtDay> days,
    required String updatedBy,
  });

  /// Fetches completion overview for all members for [weekId].
  Future<List<OtMemberOverviewItem>> getMemberOverview(
    String weekId,
    List<String> weekDates,
  );

  /// Gets the user's preference for Old Testament reminders (default true).
  Future<bool> getOtRemindersEnabled(String uid);

  /// Saves the user's preference for Old Testament reminders.
  Future<void> setOtRemindersEnabled({
    required String uid,
    required bool enabled,
  });
}
