import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bible_study/data/bible_books.dart';
import 'package:bible_study/models/app_user.dart';
import 'package:bible_study/models/ot_day.dart';
import 'package:bible_study/models/ot_week.dart';
import 'package:bible_study/repositories/auth_repository.dart';
import 'package:bible_study/repositories/fake_auth_repository.dart';
import 'package:bible_study/repositories/fake_ot_repository.dart';
import 'package:bible_study/repositories/ot_repository.dart';
import 'package:bible_study/screens/old_testament_screen.dart';
import 'package:bible_study/services/fake_notification_service.dart';
import 'package:bible_study/services/notification_service.dart';
import 'package:bible_study/state/auth_state.dart';
import 'package:bible_study/state/ot_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OT Passage Formatting Tests', () {
    test('Whole chapter formatted without colon or verse', () {
      const day = OtDay(
        date: '2026-10-26',
        book: 'Genesis',
        chapter: 12,
        verseFrom: null,
        verseTo: null,
      );
      expect(day.passageText, equals('Genesis 12'));
    });

    test('Single verse formatted with chapter and single verse', () {
      const day = OtDay(
        date: '2026-10-27',
        book: 'Psalms',
        chapter: 23,
        verseFrom: 1,
        verseTo: 1,
      );
      expect(day.passageText, equals('Psalms 23:1'));
    });

    test('Verse range formatted with hyphen', () {
      const day = OtDay(
        date: '2026-10-28',
        book: 'Psalms',
        chapter: 23,
        verseFrom: 1,
        verseTo: 6,
      );
      expect(day.passageText, equals('Psalms 23:1-6'));
    });
  });

  group('OT Progress Count & Streak Tests', () {
    test('Calculates progress count, fraction, and formatted text', () async {
      final repo = FakeOtRepository(seedInitialData: false);
      final notifService = FakeNotificationService();

      final state = OtState(
        repository: repo,
        uid: 'user_test',
        isAdmin: false,
        notificationService: notifService,
      );

      final days = [
        const OtDay(date: '2026-10-26', book: 'Genesis', chapter: 1),
        const OtDay(date: '2026-10-27', book: 'Genesis', chapter: 2),
        const OtDay(date: '2026-10-28', book: 'Genesis', chapter: 3),
        const OtDay(date: '2026-10-29', book: 'Genesis', chapter: 4),
        const OtDay(date: '2026-10-30', book: 'Genesis', chapter: 5),
      ];

      final week = await repo.publishWeek(
        topic: 'Creation',
        startDate: '2026-10-26',
        days: days,
        updatedBy: 'admin',
      );

      await repo.setDayCompleted(
        uid: 'user_test',
        weekId: week.id,
        date: '2026-10-26',
        completed: true,
      );
      await repo.setDayCompleted(
        uid: 'user_test',
        weekId: week.id,
        date: '2026-10-27',
        completed: true,
      );
      await repo.setDayCompleted(
        uid: 'user_test',
        weekId: week.id,
        date: '2026-10-28',
        completed: true,
      );

      await state.loadData();

      expect(state.totalDaysCount, equals(5));
      expect(state.completedDaysCount, equals(3));
      expect(state.progressFraction, closeTo(0.6, 0.001));
      expect(state.progressText, equals('3 of 5 readings done'));
    });

    test('Calculates streak accurately with today and yesterday readings', () async {
      final repo = FakeOtRepository(seedInitialData: false);
      final now = DateTime.now();
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final todayStr = fmt(now);
      final yesterdayStr = fmt(now.subtract(const Duration(days: 1)));
      final twoDaysAgoStr = fmt(now.subtract(const Duration(days: 2)));

      await repo.setDayCompleted(
        uid: 'streak_user',
        weekId: 'w1',
        date: twoDaysAgoStr,
        completed: true,
      );
      await repo.setDayCompleted(
        uid: 'streak_user',
        weekId: 'w1',
        date: yesterdayStr,
        completed: true,
      );
      await repo.setDayCompleted(
        uid: 'streak_user',
        weekId: 'w1',
        date: todayStr,
        completed: true,
      );

      final streak = await repo.getUserStreak('streak_user');
      expect(streak, equals(3));
    });
  });

  group('Future Days vs Past Days Rules Tests', () {
    test('Future days cannot be marked, past and today can', () async {
      final repo = FakeOtRepository(seedInitialData: false);
      final notifService = FakeNotificationService();

      final now = DateTime.now();
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final yesterday = fmt(now.subtract(const Duration(days: 1)));
      final today = fmt(now);
      final tomorrow = fmt(now.add(const Duration(days: 1)));

      final days = [
        OtDay(date: yesterday, book: 'Genesis', chapter: 1),
        OtDay(date: today, book: 'Genesis', chapter: 2),
        OtDay(date: tomorrow, book: 'Genesis', chapter: 3),
      ];

      await repo.publishWeek(
        topic: 'Test Week',
        startDate: yesterday,
        days: days,
        updatedBy: 'admin',
      );

      final state = OtState(
        repository: repo,
        uid: 'test_user',
        isAdmin: false,
        notificationService: notifService,
      );

      await state.loadData();

      // Past day can be marked
      expect(state.canMarkDate(yesterday), isTrue);
      expect(state.isFutureDay(yesterday), isFalse);

      // Today can be marked
      expect(state.canMarkDate(today), isTrue);
      expect(state.isFutureDay(today), isFalse);

      // Tomorrow cannot be marked (is locked)
      expect(state.canMarkDate(tomorrow), isFalse);
      expect(state.isFutureDay(tomorrow), isTrue);

      // Attempting to toggle tomorrow does not mark it completed
      await state.toggleDay(tomorrow);
      expect(state.readings[tomorrow], isNot(true));

      // Toggling yesterday succeeds (catch-up)
      await state.toggleDay(yesterday);
      expect(state.readings[yesterday], isTrue);
    });
  });

  group('Old Testament Book Picker Tests', () {
    test('Only 39 Old Testament books appear in oldTestament catalog', () {
      final otBooks = BibleBooks.oldTestament;
      expect(otBooks.length, equals(39));
      expect(otBooks.every((b) => b.testament == 'OT'), isTrue);
      expect(otBooks.any((b) => b.testament == 'NT'), isFalse);

      // Contains first and last OT books
      expect(otBooks.any((b) => b.name == 'Genesis'), isTrue);
      expect(otBooks.any((b) => b.name == 'Malachi'), isTrue);

      // Does not contain any NT books
      expect(otBooks.any((b) => b.name == 'Matthew'), isFalse);
      expect(otBooks.any((b) => b.name == 'Revelation'), isFalse);
    });
  });

  group('Role-based Admin Button Visibility Tests', () {
    Widget buildTestHarness({
      required AppUser user,
      required FakeOtRepository otRepo,
    }) {
      final fakeAuth = FakeAuthRepository(initialUser: user);
      final notifService = FakeNotificationService();

      return MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: fakeAuth),
          Provider<OtRepository>.value(value: otRepo),
          Provider<NotificationService>.value(value: notifService),
          ChangeNotifierProvider<AuthState>(
            create: (_) => AuthState(authRepository: fakeAuth),
          ),
          ChangeNotifierProvider<OtState>(
            create: (_) => OtState(
              repository: otRepo,
              uid: user.uid,
              isAdmin: user.isAdmin,
              notificationService: notifService,
            ),
          ),
        ],
        child: const MaterialApp(
          home: OldTestamentScreen(),
        ),
      );
    }

    testWidgets('Admin user sees Admin Tools button on OT tab', (tester) async {
      final admin = AppUser(
        uid: 'admin_ot',
        name: 'Admin OT',
        email: 'admin_ot@example.com',
        role: 'admin',
        createdAt: DateTime(2026, 1, 1),
      );
      final otRepo = FakeOtRepository(seedInitialData: true);

      await tester.pumpWidget(buildTestHarness(user: admin, otRepo: otRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
    });

    testWidgets('Member user does NOT see Admin Tools button on OT tab',
        (tester) async {
      final member = AppUser(
        uid: 'member_ot',
        name: 'Member OT',
        email: 'member_ot@example.com',
        role: 'member',
        createdAt: DateTime(2026, 1, 1),
      );
      final otRepo = FakeOtRepository(seedInitialData: true);

      await tester.pumpWidget(buildTestHarness(user: member, otRepo: otRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.admin_panel_settings_outlined), findsNothing);
    });
  });

  group('Daily Notification Schedule Tests', () {
    test('Schedules reminders only on days with an assigned passage', () async {
      final notifService = FakeNotificationService();

      final week = OtWeek(
        id: 'ot_notif_week',
        topic: 'Faith',
        startDate: '2026-10-26',
        publishedAt: DateTime(2026, 10, 25),
        days: const [
          OtDay(date: '2026-10-26', book: 'Genesis', chapter: 12),
          OtDay(date: '2026-10-27', book: 'Genesis', chapter: 13),
          OtDay(date: '2026-10-28', book: 'Genesis', chapter: 14),
          OtDay(date: '2026-10-29', book: 'Genesis', chapter: 15),
          OtDay(date: '2026-10-30', book: 'Genesis', chapter: 16),
        ],
      );

      await notifService.scheduleOtReminders(
        week: week,
        reminderTime: '07:00',
        enabled: true,
      );

      expect(notifService.otRemindersEnabled, isTrue);
      expect(notifService.scheduledOtDates.length, equals(5));
      expect(notifService.scheduledOtDates, contains('2026-10-26'));
      expect(notifService.scheduledOtDates, contains('2026-10-30'));

      // If reminders are disabled, no reminders are scheduled
      await notifService.scheduleOtReminders(
        week: week,
        reminderTime: '07:00',
        enabled: false,
      );

      expect(notifService.otRemindersEnabled, isFalse);
      expect(notifService.scheduledOtDates.isEmpty, isTrue);

      // Cancel clears scheduled dates
      await notifService.cancelOtReminders();
      expect(notifService.otRemindersCancelled, isTrue);
      expect(notifService.scheduledOtDates.isEmpty, isTrue);
    });
  });

  group('One Chapter Per Day & Shared Function Tests', () {
    test('chapter for a date: computes correct chapter automatically from date', () {
      // Genesis starting at chapter 1
      const book = 'Genesis';
      const startDate = '2026-10-26';

      final day1 = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-10-26',
      );
      expect(day1, isNotNull);
      expect(day1!.book, equals('Genesis'));
      expect(day1.chapter, equals(1));
      expect(day1.passageText, equals('Genesis 1'));

      final day2 = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-10-27',
      );
      expect(day2, isNotNull);
      expect(day2!.chapter, equals(2));
      expect(day2.passageText, equals('Genesis 2'));

      final day10 = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-11-04',
      );
      expect(day10, isNotNull);
      expect(day10!.chapter, equals(10));
      expect(day10.passageText, equals('Genesis 10'));

      // Custom startChapter: Exodus starting at chapter 5
      final ex5 = getOtChapterForDate(
        book: 'Exodus',
        startChapter: 5,
        startDate: '2026-11-01',
        date: '2026-11-01',
      );
      expect(ex5, isNotNull);
      expect(ex5!.chapter, equals(5));
      expect(ex5.passageText, equals('Exodus 5'));

      final ex7 = getOtChapterForDate(
        book: 'Exodus',
        startChapter: 5,
        startDate: '2026-11-01',
        date: '2026-11-03',
      );
      expect(ex7, isNotNull);
      expect(ex7!.chapter, equals(7));

      // Date before startDate returns null
      final before = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-10-25',
      );
      expect(before, isNull);
    });

    test('book end: detects book finished when date exceeds total chapters', () {
      // Ruth has only 4 chapters
      const book = 'Ruth';
      const startDate = '2026-10-01';

      expect(BibleBooks.getChapterCount('Ruth'), equals(4));

      // Day 1 to 4 are valid chapters
      final day1 = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-10-01',
      );
      expect(day1?.chapter, equals(1));

      final day4 = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-10-04',
      );
      expect(day4?.chapter, equals(4));
      expect(day4?.passageText, equals('Ruth 4'));

      // Day 5: Book has ended!
      final day5 = getOtChapterForDate(
        book: book,
        startChapter: 1,
        startDate: startDate,
        date: '2026-10-05',
      );
      expect(day5, isNull);

      // isOtBookFinished returns true for dates after end of book
      expect(
        isOtBookFinished(
          book: book,
          startChapter: 1,
          startDate: startDate,
          date: '2026-10-04',
        ),
        isFalse,
      );
      expect(
        isOtBookFinished(
          book: book,
          startChapter: 1,
          startDate: startDate,
          date: '2026-10-05',
        ),
        isTrue,
      );

      // OtWeek plan model methods reflect book end
      final plan = OtWeek(
        id: 'ruth_plan',
        book: 'Ruth',
        startChapter: 1,
        startDate: '2026-10-01',
        publishedAt: DateTime(2026, 10, 1),
      );

      expect(plan.isBookFinished('2026-10-04'), isFalse);
      expect(plan.isBookFinished('2026-10-05'), isTrue);
      expect(plan.getDayForDate('2026-10-05'), isNull);
    });

    test('old data still works: legacy plan with explicit days and without book', () async {
      final repo = FakeOtRepository(seedInitialData: false);

      final legacyDays = [
        const OtDay(
          date: '2026-10-26',
          book: 'Genesis',
          chapter: 12,
          verseFrom: 1,
          verseTo: 9,
        ),
        const OtDay(
          date: '2026-10-27',
          book: 'Psalms',
          chapter: 23,
          verseFrom: null,
          verseTo: null,
        ),
      ];

      // Publish using legacy parameters (explicit days, no book)
      final legacyWeek = await repo.publishWeek(
        topic: 'Abraham Calling',
        startDate: '2026-10-26',
        days: legacyDays,
        updatedBy: 'admin',
      );

      expect(legacyWeek.isChapterPerDay, isFalse);
      expect(legacyWeek.isBookFinished(), isFalse);

      // Retrieves legacy OtDay using getDayForDate
      final day1 = legacyWeek.getDayForDate('2026-10-26');
      expect(day1, isNotNull);
      expect(day1!.passageText, equals('Genesis 12:1-9'));

      final day2 = legacyWeek.getDayForDate('2026-10-27');
      expect(day2, isNotNull);
      expect(day2!.passageText, equals('Psalms 23'));

      // User readings on legacy days work as before
      await repo.setDayCompleted(
        uid: 'legacy_user',
        weekId: legacyWeek.id,
        date: '2026-10-26',
        completed: true,
      );

      final readings = await repo.getUserReadingsForWeek(
        uid: 'legacy_user',
        weekId: legacyWeek.id,
        dates: ['2026-10-26', '2026-10-27'],
      );
      expect(readings['2026-10-26'], isTrue);
      expect(readings['2026-10-27'], isFalse);
    });
  });
}
