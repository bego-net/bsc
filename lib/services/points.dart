import '../models/member_summary.dart';

/// Calculates reading points for a member this week.
/// Points: 10 per IBS reading day, 10 per OT reading day, 20 if prepared.
/// Reusable by a future Leaderboard tab.
int weeklyPoints(MemberSummary m) {
  final ibs = m.ibsDaysThisWeek * 10;
  final ot = m.otDaysThisWeek * 10;
  final prep = m.preparedThisWeek ? 20 : 0;
  return ibs + ot + prep;
}

enum LeaderboardCategory { overall, individual, team, oldTestament }

int pointsForCategory(MemberSummary m, LeaderboardCategory category) {
  switch (category) {
    case LeaderboardCategory.overall:
      return weeklyPoints(m);
    case LeaderboardCategory.individual:
      return m.ibsDaysThisWeek * 10;
    case LeaderboardCategory.team:
      return m.preparedThisWeek ? 20 : 0;
    case LeaderboardCategory.oldTestament:
      return m.otDaysThisWeek * 10;
  }
}

/// Returns members sorted by points in the specified category descending.
List<MemberSummary> rankedMembers(
  List<MemberSummary> members, {
  LeaderboardCategory category = LeaderboardCategory.overall,
}) {
  final sorted = [...members]
    ..sort((a, b) {
      final pA = pointsForCategory(a, category);
      final pB = pointsForCategory(b, category);
      if (pB != pA) return pB.compareTo(pA);
      return a.name.compareTo(b.name);
    });
  return sorted;
}

/// Returns the top [topN] members sorted by points descending.
List<MemberSummary> topReaders(List<MemberSummary> members, {int topN = 5}) {
  final sorted = [...members]
    ..sort((a, b) => weeklyPoints(b).compareTo(weeklyPoints(a)));
  return sorted.take(topN).toList();
}
