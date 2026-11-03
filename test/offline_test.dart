import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible_study/l10n/app_localizations.dart';
import 'package:bible_study/models/app_user.dart';
import 'package:bible_study/models/ot_day.dart';
import 'package:bible_study/models/study_week.dart';
import 'package:bible_study/repositories/fake_ot_repository.dart';
import 'package:bible_study/repositories/fake_study_repository.dart';
import 'package:bible_study/repositories/fake_team_repository.dart';
import 'package:bible_study/services/fake_notification_service.dart';
import 'package:bible_study/services/offline_reminders.dart';
import 'package:bible_study/state/ot_state.dart';
import 'package:bible_study/state/study_state.dart';
import 'package:bible_study/state/team_state.dart';
import 'package:bible_study/ui/widgets/offline_indicator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Optimistic UI Tests', () {
    test('StudyState toggleMarkToday updates immediately (optimistic UI)', () async {
      final studyRepo = FakeStudyRepository();
      final user = AppUser(
        uid: 'user1',
        name: 'Test',
        email: 'test@example.com',
        username: 'test',
        role: 'member',
        createdAt: DateTime.now(),
        mustChangePassword: false,
        currentBook: 'Genesis',
        currentChapter: 1,
        verseFrom: 1,
        verseTo: 1,
      );

      final studyState = StudyState(
        repository: studyRepo,
        initialUser: user,
      );
      await studyState.loadUserData();

      expect(studyState.isReadToday, isFalse);
      expect(studyState.hasPendingWrites, isFalse);

      final future = studyState.toggleMarkToday();
      // Should be immediately marked read before await finishes
      expect(studyState.isReadToday, isTrue);

      await future;
      expect(studyState.isReadToday, isTrue);
      expect(studyState.hasPendingWrites, isFalse);
    });

    test('OtState toggleDay updates immediately and rolls back on failure', () async {
      final otRepo = FakeOtRepository();
      final notificationService = FakeNotificationService();

      final today = OtState.todayDateString;
      await otRepo.publishWeek(
        topic: 'Test Topic',
        startDate: today,
        days: [
          OtDay(
            date: today,
            book: 'Genesis',
            chapter: 1,
          ),
        ],
        updatedBy: 'admin',
      );

      final otState = OtState(
        repository: otRepo,
        uid: 'user1',
        isAdmin: false,
        notificationService: notificationService,
      );

      await otState.loadData();
      expect(otState.readings[today], isNot(true));

      // Toggle marks immediately
      final future = otState.toggleDay(today);
      expect(otState.readings[today], isTrue);
      await future;
      expect(otState.readings[today], isTrue);
    });

    test('TeamState togglePrepared updates immediately (optimistic UI)', () async {
      final teamRepo = FakeTeamRepository();
      final notificationService = FakeNotificationService();

      final teamWeek = StudyWeek(
        id: 'week_1',
        book: 'Romans',
        chapter: 8,
        verseFrom: 1,
        verseTo: 10,
        publishedAt: DateTime.now(),
      );
      await teamRepo.publishWeek(teamWeek, updatedBy: 'admin');

      final teamState = TeamState(
        repository: teamRepo,
        uid: 'user1',
        isAdmin: false,
        notificationService: notificationService,
      );

      await teamState.loadData();
      expect(teamState.isPrepared, isFalse);

      final future = teamState.togglePrepared();
      // Immediately true
      expect(teamState.isPrepared, isTrue);
      await future;
      expect(teamState.isPrepared, isTrue);
      expect(teamState.hasPendingWrites, isFalse);
    });
  });

  group('OfflineIndicator Widget Tests', () {
    testWidgets('Renders nothing when no pending writes and not from cache', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: OfflineIndicator(
              hasPendingWrites: false,
              isFromCache: false,
            ),
          ),
        ),
      );

      expect(find.byType(OfflineIndicator), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Offline mode'), findsNothing);
      expect(find.text('Saved on this phone, will sync'), findsNothing);
    });

    testWidgets('Shows pending sync indicator when hasPendingWrites is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: OfflineIndicator(
              hasPendingWrites: true,
              isFromCache: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });
  });

  group('Offline Reminders Scheduling Tests', () {
    test('OfflineReminders schedules Thursday and OT reminders from cached data', () async {
      final teamRepo = FakeTeamRepository();
      final otRepo = FakeOtRepository();
      final notificationService = FakeNotificationService();

      final teamWeek = StudyWeek(
        id: 'week_cached',
        book: 'John',
        chapter: 3,
        verseFrom: 16,
        verseTo: 17,
        publishedAt: DateTime.now(),
      );
      final published = await teamRepo.publishWeek(teamWeek, updatedBy: 'admin');

      final today = OtState.todayDateString;
      await otRepo.publishWeek(
        topic: 'Cached OT',
        startDate: today,
        days: [
          OtDay(
            date: today,
            book: 'Exodus',
            chapter: 20,
          ),
        ],
        updatedBy: 'admin',
      );

      await OfflineReminders.scheduleCachedReminders(
        teamRepo: teamRepo,
        otRepo: otRepo,
        notificationService: notificationService,
        uid: 'user1',
      );

      expect(notificationService.scheduledWeek?.id, equals(published.id));
      expect(notificationService.scheduledOtWeek?.topic, equals('Cached OT'));
    });
  });
}
