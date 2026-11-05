import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/ot_repository.dart';
import '../repositories/study_repository.dart';
import '../repositories/team_repository.dart';

/// Service that preloads and caches core app data after login for offline access.
class OfflinePreloader {
  OfflinePreloader._();

  /// Preloads:
  /// - User profile.
  /// - Last 60 days of readings and Old Testament readings.
  /// - Current Old Testament plan.
  /// - Current Team BS week, questions and materials.
  /// - Leaderboard and dashboard data.
  static Future<void> preload({
    required String uid,
    required AuthRepository authRepo,
    required StudyRepository studyRepo,
    required OtRepository otRepo,
    required TeamRepository teamRepo,
    DashboardRepository? dashboardRepo,
  }) async {
    try {
      // 1. User profile
      await authRepo.getCurrentUser();

      // 2. Last 60 days of individual readings
      await studyRepo.getReadingHistory(uid: uid);

      // 3. Current Old Testament plan & readings
      final otWeek = await otRepo.getCurrentWeek();
      List<String> dates = [];
      if (otWeek != null) {
        final days = otWeek.days.isNotEmpty
            ? otWeek.days
            : await otRepo.getDaysForWeek(otWeek.id);
        dates = days.map((d) => d.date).toList();
        await otRepo.getUserReadingsForWeek(
          uid: uid,
          weekId: otWeek.id,
          dates: dates,
        );
        await otRepo.getUserStreak(uid);
      }
      // Also cache OT past weeks history
      await otRepo.getWeekHistory();

      // 4. Current Team BS week, questions and materials
      final teamWeek = await teamRepo.getCurrentWeek();
      if (teamWeek != null) {
        await teamRepo.getQuestions(teamWeek.id, onlyPublished: false);
        await teamRepo.getMaterials(teamWeek.id, onlyPublished: false);
        await teamRepo.isUserPrepared(weekId: teamWeek.id, uid: uid);
      }

      // 5. Leaderboard and dashboard data
      if (dashboardRepo != null) {
        final currentTeam = await dashboardRepo.getCurrentTeamWeek();
        final teamId = currentTeam?.id ?? teamWeek?.id ?? '';
        await dashboardRepo.getMembers(
          currentTeamWeekId: teamId,
          currentOtWeekDates: dates,
        );
      }

      debugPrint('[OfflinePreloader] Preload & cache completed for uid: $uid');
    } catch (e) {
      debugPrint('[OfflinePreloader] Preload finished with notice: $e');
    }
  }
}