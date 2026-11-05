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
import 'package:provider/provider.dart';
import 'package:bible_study/repositories/auth_repository.dart';
import 'package:bible_study/repositories/dashboard_repository.dart';
import 'package:bible_study/repositories/fake_auth_repository.dart';
import 'package:bible_study/repositories/fake_dashboard_repository.dart';
import 'package:bible_study/repositories/ot_repository.dart';
import 'package:bible_study/repositories/study_repository.dart';
import 'package:bible_study/repositories/team_repository.dart';
import 'package:bible_study/screens/admin/admin_home_screen.dart';
import 'package:bible_study/screens/admin/dashboard_screen.dart';
import 'package:bible_study/screens/admin/member_detail_screen.dart';
import 'package:bible_study/screens/admin/members_list_screen.dart';
import 'package:bible_study/screens/leaderboard_screen.dart';
import 'package:bible_study/screens/old_testament_screen.dart';
import 'package:bible_study/screens/profile_screen.dart';
import 'package:bible_study/screens/team_screen.dart';
import 'package:bible_study/state/auth_state.dart';
import 'package:bible_study/state/dashboard_state.dart';
import 'package:bible_study/state/locale_state.dart';
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

  group('Fake-offline repository screen tests', () {
    late FakeAuthRepository fakeAuth;
    late FakeStudyRepository fakeStudy;
    late FakeTeamRepository fakeTeam;
    late FakeOtRepository fakeOt;
    late FakeDashboardRepository fakeDash;
    late FakeNotificationService fakeNotifications;
    late AppUser testAdmin;

    setUp(() {
      testAdmin = AppUser(
        uid: 'admin_1',
        name: 'Admin User',
        email: 'admin@test.com',
        username: 'admin',
        role: 'admin',
        createdAt: DateTime(2026, 1, 1),
      );
      fakeAuth = FakeAuthRepository(initialUser: testAdmin);
      fakeStudy = FakeStudyRepository();
      fakeTeam = FakeTeamRepository(seedInitialData: true);
      fakeOt = FakeOtRepository(seedInitialData: true);
      fakeDash = FakeDashboardRepository();
      fakeNotifications = FakeNotificationService();
    });

    Widget buildTestApp(Widget child, {DashboardState? customDashState}) {
      final authState = AuthState(authRepository: fakeAuth);
      final studyState = StudyState(
        repository: fakeStudy,
        initialUser: testAdmin,
        notificationService: fakeNotifications,
      );
      final teamState = TeamState(
        repository: fakeTeam,
        uid: testAdmin.uid,
        isAdmin: true,
        notificationService: fakeNotifications,
      );
      final otState = OtState(
        repository: fakeOt,
        uid: testAdmin.uid,
        isAdmin: true,
        notificationService: fakeNotifications,
      );
      final dashState = customDashState ??
          DashboardState(
            repository: fakeDash,
            otRepository: fakeOt,
          );
      final localeState = LocaleState();

      return MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: fakeAuth),
          Provider<StudyRepository>.value(value: fakeStudy),
          Provider<TeamRepository>.value(value: fakeTeam),
          Provider<OtRepository>.value(value: fakeOt),
          Provider<DashboardRepository>.value(value: fakeDash),
          ChangeNotifierProvider<AuthState>.value(value: authState),
          ChangeNotifierProvider<StudyState>.value(value: studyState),
          ChangeNotifierProvider<TeamState>.value(value: teamState),
          ChangeNotifierProvider<OtState>.value(value: otState),
          ChangeNotifierProvider<DashboardState>.value(value: dashState),
          ChangeNotifierProvider<LocaleState>.value(value: localeState),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: child,
        ),
      );
    }

    testWidgets('TeamScreen renders cached data offline immediately', (tester) async {
      await tester.pumpWidget(buildTestApp(const TeamScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TeamScreen), findsOneWidget);
      expect(find.text("This Week's Passage"), findsOneWidget);
    });

    testWidgets('OldTestamentScreen renders cached data offline immediately', (tester) async {
      await tester.pumpWidget(buildTestApp(const OldTestamentScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(OldTestamentScreen), findsOneWidget);
      expect(find.text('Reading Plan'), findsWidgets);
    });

    testWidgets('ProfileScreen renders user profile offline', (tester) async {
      await tester.pumpWidget(buildTestApp(const ProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Admin User'), findsOneWidget);
    });

    testWidgets('LeaderboardScreen renders cached leaderboard offline', (tester) async {
      await tester.pumpWidget(buildTestApp(const LeaderboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LeaderboardScreen), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('DashboardScreen renders cached dashboard metrics offline', (tester) async {
      await tester.pumpWidget(buildTestApp(const DashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('MembersListScreen renders members offline', (tester) async {
      await tester.pumpWidget(buildTestApp(const MembersListScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(MembersListScreen), findsOneWidget);
    });

    testWidgets('MemberDetailScreen renders cached member detail offline', (tester) async {
      final dashState = DashboardState(
        repository: fakeDash,
        otRepository: fakeOt,
      );
      await dashState.load();
      await tester.pumpWidget(buildTestApp(
        const MemberDetailScreen(uid: 'user_sarah'),
        customDashState: dashState,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(MemberDetailScreen), findsOneWidget);
      expect(find.text('Sarah Chen'), findsOneWidget);
    });

    testWidgets('AdminHomeScreen renders admin tools offline', (tester) async {
      await tester.pumpWidget(buildTestApp(const AdminHomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AdminHomeScreen), findsOneWidget);
      expect(find.text('Admin Tools'), findsOneWidget);
    });
  });
}