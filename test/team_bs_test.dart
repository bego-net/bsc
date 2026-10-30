import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bible_study/models/app_user.dart';
import 'package:bible_study/models/study_week.dart';
import 'package:bible_study/repositories/auth_repository.dart';
import 'package:bible_study/repositories/fake_auth_repository.dart';
import 'package:bible_study/repositories/fake_team_repository.dart';
import 'package:bible_study/repositories/team_repository.dart';
import 'package:bible_study/screens/team_screen.dart';
import 'package:bible_study/services/fake_notification_service.dart';
import 'package:bible_study/services/notification_service.dart';
import 'package:bible_study/state/auth_state.dart';
import 'package:bible_study/state/team_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Passage Formatting Tests', () {
    test('Formats single verse without hyphen', () {
      final week = StudyWeek(
        id: 'single_verse_week',
        book: 'Matthew',
        chapter: 5,
        verseFrom: 3,
        verseTo: 3,
        publishedAt: DateTime(2026, 1, 1),
      );

      expect(week.verseRangeText, equals('3'));
      expect(week.passageText, equals('Matthew 5:3'));
    });

    test('Formats verse range with hyphen', () {
      final week = StudyWeek(
        id: 'range_week',
        book: 'Matthew',
        chapter: 5,
        verseFrom: 1,
        verseTo: 8,
        publishedAt: DateTime(2026, 1, 1),
      );

      expect(week.verseRangeText, equals('1-8'));
      expect(week.passageText, equals('Matthew 5:1-8'));
    });
  });

  group('Published Items Visibility Tests', () {
    test('Members see only published questions and materials', () async {
      final teamRepo = FakeTeamRepository(seedInitialData: true);
      final notifService = FakeNotificationService();

      final memberState = TeamState(
        repository: teamRepo,
        uid: 'member_uid',
        isAdmin: false,
        notificationService: notifService,
      );

      await memberState.loadData();

      // Seed data contains 2 published and 1 draft question
      expect(memberState.questions.length, equals(2));
      expect(memberState.questions.every((q) => q.published), isTrue);

      // Seed data contains 1 published and 1 draft material
      expect(memberState.materials.length, equals(1));
      expect(memberState.materials.every((m) => m.published), isTrue);
    });

    test('Admins see all questions and materials including drafts', () async {
      final teamRepo = FakeTeamRepository(seedInitialData: true);
      final notifService = FakeNotificationService();

      final adminState = TeamState(
        repository: teamRepo,
        uid: 'admin_uid',
        isAdmin: true,
        notificationService: notifService,
      );

      await adminState.loadData();

      // Admins see all 3 questions (2 published + 1 draft)
      expect(adminState.questions.length, equals(3));
      expect(adminState.questions.any((q) => !q.published), isTrue);

      // Admins see all 2 materials (1 published + 1 draft)
      expect(adminState.materials.length, equals(2));
      expect(adminState.materials.any((m) => !m.published), isTrue);
    });
  });

  group('Role-based Admin Button Visibility Tests', () {
    Widget buildTestHarness({
      required AppUser user,
      required FakeTeamRepository teamRepo,
    }) {
      final fakeAuth = FakeAuthRepository(initialUser: user);
      final notifService = FakeNotificationService();

      return MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: fakeAuth),
          Provider<TeamRepository>.value(value: teamRepo),
          Provider<NotificationService>.value(value: notifService),
          ChangeNotifierProvider<AuthState>(
            create: (_) => AuthState(authRepository: fakeAuth),
          ),
          ChangeNotifierProvider<TeamState>(
            create: (_) => TeamState(
              repository: teamRepo,
              uid: user.uid,
              isAdmin: user.isAdmin,
              notificationService: notifService,
            ),
          ),
        ],
        child: const MaterialApp(
          home: TeamScreen(),
        ),
      );
    }

    testWidgets('Admin user sees Admin Tools button in AppBar', (tester) async {
      final adminUser = AppUser(
        uid: 'admin_1',
        name: 'Admin User',
        email: 'admin@example.com',
        role: 'admin',
        createdAt: DateTime(2026, 1, 1),
      );
      final teamRepo = FakeTeamRepository(seedInitialData: true);

      await tester.pumpWidget(
        buildTestHarness(user: adminUser, teamRepo: teamRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
    });

    testWidgets('Member user does NOT see Admin Tools button in AppBar',
        (tester) async {
      final memberUser = AppUser(
        uid: 'member_1',
        name: 'Normal Member',
        email: 'member@example.com',
        role: 'member',
        createdAt: DateTime(2026, 1, 1),
      );
      final teamRepo = FakeTeamRepository(seedInitialData: true);

      await tester.pumpWidget(
        buildTestHarness(user: memberUser, teamRepo: teamRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.admin_panel_settings_outlined), findsNothing);
    });
  });

  group('Thursday Reminder Calculation Tests', () {
    test('Wednesday calculates next day Thursday at reminder time', () {
      // 2026-10-28 is a Wednesday
      final wednesday = DateTime(2026, 10, 28, 10, 0);
      final result = calculateNextThursday(wednesday, 18, 0);

      expect(result.weekday, equals(DateTime.thursday));
      expect(result.year, equals(2026));
      expect(result.month, equals(10));
      expect(result.day, equals(29));
      expect(result.hour, equals(18));
      expect(result.minute, equals(0));
    });

    test('Thursday before reminder time returns today at reminder time', () {
      // 2026-10-29 is a Thursday, 10:00 AM
      final thursdayMorning = DateTime(2026, 10, 29, 10, 0);
      final result = calculateNextThursday(thursdayMorning, 18, 0);

      expect(result.weekday, equals(DateTime.thursday));
      expect(result.year, equals(2026));
      expect(result.month, equals(10));
      expect(result.day, equals(29)); // Same day
      expect(result.hour, equals(18));
      expect(result.minute, equals(0));
    });

    test('Thursday after reminder time returns next Thursday (+7 days)', () {
      // 2026-10-29 is a Thursday, 19:30 PM (after 18:00)
      final thursdayEvening = DateTime(2026, 10, 29, 19, 30);
      final result = calculateNextThursday(thursdayEvening, 18, 0);

      expect(result.weekday, equals(DateTime.thursday));
      expect(result.year, equals(2026));
      expect(result.month, equals(11));
      expect(result.day, equals(5)); // Next week Thursday
      expect(result.hour, equals(18));
      expect(result.minute, equals(0));
    });

    test('Friday calculates next week Thursday', () {
      // 2026-10-30 is a Friday
      final friday = DateTime(2026, 10, 30, 9, 0);
      final result = calculateNextThursday(friday, 18, 0);

      expect(result.weekday, equals(DateTime.thursday));
      expect(result.year, equals(2026));
      expect(result.month, equals(11));
      expect(result.day, equals(5));
      expect(result.hour, equals(18));
      expect(result.minute, equals(0));
    });

    test('Reminder time parser handles 24h and 12h AM/PM strings', () {
      expect(parseReminderHourMinute('18:00'), equals((18, 0)));
      expect(parseReminderHourMinute('6:00 PM'), equals((18, 0)));
      expect(parseReminderHourMinute('07:30 AM'), equals((7, 30)));
      expect(parseReminderHourMinute('12:00 PM'), equals((12, 0)));
      expect(parseReminderHourMinute('12:00 AM'), equals((0, 0)));
      expect(parseReminderHourMinute('invalid string'), equals((18, 0))); // Fallback
    });
  });
}
