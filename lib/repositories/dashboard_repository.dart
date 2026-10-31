import '../models/member_summary.dart';
import '../models/reading_entry.dart';
import '../models/study_week.dart';

/// Abstract repository for all admin dashboard data.
abstract class DashboardRepository {
  /// Fetches all member profiles (admin only).
  Future<List<MemberSummary>> getMembers({
    required String currentTeamWeekId,
    required List<String> currentOtWeekDates,
  });

  /// Loads the last 30 days of IBS readings for [uid].
  Future<List<ReadingEntry>> getMemberIbsHistory(String uid);

  /// Loads OT reading dates (completed) for [uid] in the last 30 days.
  Future<List<String>> getMemberOtHistory(String uid);

  /// Loads Team BS prepared status per week for [uid] (last ~8 weeks).
  Future<Map<String, bool>> getMemberTeamHistory(String uid);

  /// Returns the current Team BS study week.
  Future<StudyWeek?> getCurrentTeamWeek();
}
