import 'package:flutter_test/flutter_test.dart';
import 'package:bible_study/models/member_summary.dart';
import 'package:bible_study/models/study_week.dart';
import 'package:bible_study/repositories/fake_dashboard_repository.dart';
import 'package:bible_study/repositories/fake_ot_repository.dart';
import 'package:bible_study/services/points.dart';
import 'package:bible_study/services/weekly_summary.dart';
import 'package:bible_study/state/dashboard_state.dart';

void main() {
  group('Points Logic', () {
    test('calculates weekly points: 10 per IBS, 10 per OT, 20 if prepared', () {
      final now = DateTime.now();
      final m1 = MemberSummary(
        uid: 'u1',
        name: 'Alice',
        email: 'alice@test.com',
        joinDate: now,
        ibsDaysThisWeek: 4, // 40
        otDaysThisWeek: 3,  // 30
        preparedThisWeek: true, // 20
      );

      expect(weeklyPoints(m1), 90);
      expect(pointsForCategory(m1, LeaderboardCategory.overall), 90);
      expect(pointsForCategory(m1, LeaderboardCategory.individual), 40);
      expect(pointsForCategory(m1, LeaderboardCategory.oldTestament), 30);
      expect(pointsForCategory(m1, LeaderboardCategory.team), 20);
    });

    test('calculates zero points when no activities completed', () {
      final now = DateTime.now();
      final m2 = MemberSummary(
        uid: 'u2',
        name: 'Bob',
        email: 'bob@test.com',
        joinDate: now,
        ibsDaysThisWeek: 0,
        otDaysThisWeek: 0,
        preparedThisWeek: false,
      );

      expect(weeklyPoints(m2), 0);
      expect(pointsForCategory(m2, LeaderboardCategory.overall), 0);
    });
  });

  group('Needs Encouragement Logic', () {
    test('returns true when lastReadDate is null or invalid', () {
      final now = DateTime.now();
      final mNull = MemberSummary(
        uid: 'u1',
        name: 'No date',
        email: 'null@test.com',
        joinDate: now,
        lastReadDate: null,
      );
      expect(mNull.needsEncouragement, isTrue);

      final mInvalid = MemberSummary(
        uid: 'u2',
        name: 'Invalid date',
        email: 'invalid@test.com',
        joinDate: now,
        lastReadDate: 'not-a-date',
      );
      expect(mInvalid.needsEncouragement, isTrue);
    });

    test('returns true when last reading was 3 or more days ago', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      final fmt3 = '${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}';

      final m3 = MemberSummary(
        uid: 'u3',
        name: 'Three Days',
        email: 'three@test.com',
        joinDate: now,
        lastReadDate: fmt3,
      );
      expect(m3.needsEncouragement, isTrue);
    });

    test('returns false when last reading was today or 1-2 days ago', () {
      final now = DateTime.now();
      final fmtToday = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final mToday = MemberSummary(
        uid: 'u4',
        name: 'Today',
        email: 'today@test.com',
        joinDate: now,
        lastReadDate: fmtToday,
      );
      expect(mToday.needsEncouragement, isFalse);

      final oneDayAgo = now.subtract(const Duration(days: 1));
      final fmt1 = '${oneDayAgo.year}-${oneDayAgo.month.toString().padLeft(2, '0')}-${oneDayAgo.day.toString().padLeft(2, '0')}';
      final m1 = MemberSummary(
        uid: 'u5',
        name: 'Yesterday',
        email: 'yesterday@test.com',
        joinDate: now,
        lastReadDate: fmt1,
      );
      expect(m1.needsEncouragement, isFalse);
    });
  });

  group('Sorting & Filtering Logic', () {
    final now = DateTime.now();
    final mAlice = MemberSummary(
      uid: 'u1',
      name: 'Alice',
      email: 'alice@test.com',
      joinDate: now,
      ibsDaysThisWeek: 5,
      otDaysThisWeek: 2,
      preparedThisWeek: true,
      lastReadDate: '2026-10-30',
    );
    final mCharlie = MemberSummary(
      uid: 'u2',
      name: 'Charlie',
      email: 'charlie@test.com',
      joinDate: now,
      ibsDaysThisWeek: 1,
      otDaysThisWeek: 1,
      preparedThisWeek: false,
      lastReadDate: '2026-10-25',
    );
    final mBob = MemberSummary(
      uid: 'u3',
      name: 'Bob',
      email: 'bob@test.com',
      joinDate: now,
      ibsDaysThisWeek: 3,
      otDaysThisWeek: 3,
      preparedThisWeek: true,
      lastReadDate: '2026-10-29',
    );

    test('rankedMembers sorts descending by points in category', () {
      final list = [mCharlie, mAlice, mBob];
      final ranked = rankedMembers(list, category: LeaderboardCategory.overall);

      // Alice: 50+20+20 = 90
      // Bob: 30+30+20 = 80
      // Charlie: 10+10 = 20
      expect(ranked.map((m) => m.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('rankedMembers handles tie by alphabetical name', () {
      final zoe = MemberSummary(
        uid: 'u4',
        name: 'Zoe',
        email: 'zoe@test.com',
        joinDate: now,
        ibsDaysThisWeek: 2,
      );
      final adam = MemberSummary(
        uid: 'u5',
        name: 'Adam',
        email: 'adam@test.com',
        joinDate: now,
        ibsDaysThisWeek: 2,
      );

      final ranked = rankedMembers([zoe, adam], category: LeaderboardCategory.individual);
      expect(ranked.map((m) => m.name).toList(), ['Adam', 'Zoe']);
    });

    test('DashboardState sorts by name, lastActive, and mostActive', () async {
      final fakeRepo = FakeDashboardRepository(members: [mCharlie, mAlice, mBob]);
      final fakeOtRepo = FakeOtRepository();
      final state = DashboardState(repository: fakeRepo, otRepository: fakeOtRepo);

      await state.load(forceRefresh: true);

      // Default: sort by name
      state.setSort(MemberSort.name);
      expect(state.filteredMembers.map((m) => m.name).toList(), ['Alice', 'Bob', 'Charlie']);

      // Sort by last active (newest date first)
      state.setSort(MemberSort.lastActive);
      expect(state.filteredMembers.map((m) => m.name).toList(), ['Alice', 'Bob', 'Charlie']);

      // Sort by most active (ibsDaysThisWeek + otDaysThisWeek)
      // Alice: 7, Bob: 6, Charlie: 2
      state.setSort(MemberSort.mostActive);
      expect(state.filteredMembers.map((m) => m.name).toList(), ['Alice', 'Bob', 'Charlie']);

      // Filter needs encouragement
      state.toggleNeedsEncouragementFilter();
      // Only Charlie (2026-10-25 is >= 3 days)
      expect(state.filteredMembers.map((m) => m.name).toList(), ['Charlie']);
    });
  });

  group('Weekly Summary', () {
    test('builds text summary correctly', () {
      final now = DateTime.now();
      final teamWeek = StudyWeek(
        id: 'w1',
        book: 'Mark',
        chapter: 4,
        verseFrom: 1,
        verseTo: 20,
        sessionDay: 'Friday',
        sessionTime: '19:00',
        place: 'Room 201',
        publishedAt: now,
      );
      final m1 = MemberSummary(
        uid: 'u1',
        name: 'Alice',
        email: 'alice@test.com',
        joinDate: now,
        ibsDaysThisWeek: 5,
        otDaysThisWeek: 3,
        preparedThisWeek: true,
        lastReadDate: '2026-10-30',
      );
      final m2 = MemberSummary(
        uid: 'u2',
        name: 'Bob',
        email: 'bob@test.com',
        joinDate: now,
        ibsDaysThisWeek: 0,
        otDaysThisWeek: 0,
        preparedThisWeek: false,
        lastReadDate: '2026-10-20',
      );

      final summary = buildWeeklySummary(
        teamWeek: teamWeek,
        members: [m1, m2],
        otTopic: 'Genesis Creation',
      );

      expect(summary, contains('Weekly Bible Study Summary'));
      expect(summary, contains('Team BS passage: Mark 4:1-20'));
      expect(summary, contains('Prepared: 1 of 2'));
      expect(summary, contains('OT topic: Genesis Creation'));
      expect(summary, contains('Active members this week: 1 of 2'));
      expect(summary, contains('Bob'));
    });
  });
}
