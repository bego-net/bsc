import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bible_study/app.dart';
import 'package:bible_study/data/bible_books.dart';
import 'package:bible_study/models/app_user.dart';
import 'package:bible_study/models/reading_entry.dart';
import 'package:bible_study/repositories/auth_repository.dart';
import 'package:bible_study/repositories/fake_auth_repository.dart';
import 'package:bible_study/repositories/fake_study_repository.dart';
import 'package:bible_study/repositories/study_repository.dart';
import 'package:bible_study/screens/individual_screen.dart';
import 'package:bible_study/screens/login_screen.dart';
import 'package:bible_study/state/auth_state.dart';
import 'package:bible_study/state/study_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Chapter Limits Per Book Tests', () {
    test('All 66 books are present and have positive chapter counts', () {
      expect(BibleBooks.all.length, equals(66));
      expect(BibleBooks.getChapterCount('Genesis'), equals(50));
      expect(BibleBooks.getChapterCount('Psalms'), equals(150));
      expect(BibleBooks.getChapterCount('Obadiah'), equals(1));
      expect(BibleBooks.getChapterCount('John'), equals(21));
      expect(BibleBooks.getChapterCount('Revelation'), equals(22));
    });

    test('StudyState enforces chapter bounds and clamps on book change', () async {
      final studyRepo = FakeStudyRepository();
      final user = AppUser(
        uid: 'test_user',
        name: 'Tester',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        currentBook: 'Genesis',
        currentChapter: 45,
        currentVerse: 1,
      );

      final state = StudyState(
        repository: studyRepo,
        initialUser: user,
      );

      expect(state.currentBook, equals('Genesis'));
      expect(state.currentChapter, equals(45));
      expect(state.maxChapters, equals(50));

      // Attempt to advance beyond max chapter
      await state.setChapter(60);
      expect(state.currentChapter, equals(50));

      // Attempt to set chapter below 1
      await state.setChapter(0);
      expect(state.currentChapter, equals(1));

      // Switch to a book with fewer chapters (John has 21 chapters)
      await state.setChapter(40);
      expect(state.currentChapter, equals(40));

      await state.setBook('John');
      expect(state.currentBook, equals('John'));
      expect(state.maxChapters, equals(21));
      // Must clamp from 40 to 21
      expect(state.currentChapter, equals(21));

      // Switch to single-chapter book (Obadiah)
      await state.setBook('Obadiah');
      expect(state.currentBook, equals('Obadiah'));
      expect(state.maxChapters, equals(1));
      expect(state.currentChapter, equals(1));

      // Next chapter on single-chapter book should not change
      await state.nextChapter();
      expect(state.currentChapter, equals(1));
    });

    test('Verse bounds are clamped between 1 and 176', () async {
      final studyRepo = FakeStudyRepository();
      final user = AppUser(
        uid: 'test_user',
        name: 'Tester',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final state = StudyState(
        repository: studyRepo,
        initialUser: user,
      );

      expect(state.currentVerse, equals(1));

      await state.setVerse(176);
      expect(state.currentVerse, equals(176));

      await state.incrementVerse();
      expect(state.currentVerse, equals(176));

      await state.setVerse(200);
      expect(state.currentVerse, equals(176));

      await state.setVerse(-10);
      expect(state.currentVerse, equals(1));
    });
  });

  group('Marking and Undoing Today Tests', () {
    test('Toggling mark today updates status, persists, and offers next chapter', () async {
      final studyRepo = FakeStudyRepository();
      final today = DateTime(2026, 10, 29);
      final user = AppUser(
        uid: 'user_1',
        name: 'Tester',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        currentBook: 'John',
        currentChapter: 3,
        currentVerse: 16,
      );

      final state = StudyState(
        repository: studyRepo,
        initialUser: user,
        now: () => today,
      );

      expect(state.isReadToday, isFalse);
      expect(state.streak, equals(0));

      // Mark as read today
      await state.toggleMarkToday();

      expect(state.isReadToday, isTrue);
      expect(state.todayReading?.book, equals('John'));
      expect(state.todayReading?.chapter, equals(3));
      expect(state.todayReading?.verse, equals(16));
      expect(state.todayReading?.completed, isTrue);
      expect(state.streak, equals(1));

      // Verify in repository
      final savedInRepo = await studyRepo.getReadingForDate(
        uid: 'user_1',
        date: '2026-10-29',
      );
      expect(savedInRepo?.completed, isTrue);

      // Undo reading today
      await state.toggleMarkToday();

      expect(state.isReadToday, isFalse);
      expect(state.todayReading?.completed, isFalse);
      expect(state.streak, equals(0));

      final undoneInRepo = await studyRepo.getReadingForDate(
        uid: 'user_1',
        date: '2026-10-29',
      );
      expect(undoneInRepo?.completed, isFalse);

      // Advance to next chapter
      await state.nextChapter();
      expect(state.currentChapter, equals(4));
    });
  });

  group('History Ordering Tests', () {
    test('Reading history is ordered newest date first', () async {
      final studyRepo = FakeStudyRepository();
      const uid = 'user_hist';

      // Insert unsorted entries
      await studyRepo.saveReading(
        uid: uid,
        entry: ReadingEntry(
          date: '2026-10-25',
          book: 'Genesis',
          chapter: 1,
          verse: 1,
          completed: true,
          updatedAt: DateTime(2026, 10, 25),
        ),
      );
      await studyRepo.saveReading(
        uid: uid,
        entry: ReadingEntry(
          date: '2026-10-28',
          book: 'Genesis',
          chapter: 2,
          verse: 1,
          completed: true,
          updatedAt: DateTime(2026, 10, 28),
        ),
      );
      await studyRepo.saveReading(
        uid: uid,
        entry: ReadingEntry(
          date: '2026-10-26',
          book: 'Genesis',
          chapter: 3,
          verse: 1,
          completed: true,
          updatedAt: DateTime(2026, 10, 26),
        ),
      );

      final historyFromRepo = await studyRepo.getReadingHistory(uid: uid);

      expect(historyFromRepo.length, equals(3));
      expect(historyFromRepo[0].date, equals('2026-10-28'));
      expect(historyFromRepo[1].date, equals('2026-10-26'));
      expect(historyFromRepo[2].date, equals('2026-10-25'));

      // StudyState should maintain this order
      final user = AppUser(
        uid: uid,
        name: 'HistUser',
        email: 'hist@test.com',
        createdAt: DateTime.now(),
      );
      final state = StudyState(
        repository: studyRepo,
        initialUser: user,
        now: () => DateTime(2026, 10, 29),
      );
      await state.loadUserData();

      expect(state.history.length, equals(3));
      expect(state.history[0].date, equals('2026-10-28'));
      expect(state.history[1].date, equals('2026-10-26'));
      expect(state.history[2].date, equals('2026-10-25'));
    });
  });

  group('Streak Calculation Tests', () {
    test('Calculates streak correctly with today, yesterday, and gaps', () async {
      final studyRepo = FakeStudyRepository();
      const uid = 'user_streak';
      final today = DateTime(2026, 10, 29);

      final user = AppUser(
        uid: uid,
        name: 'StreakUser',
        email: 'streak@test.com',
        createdAt: DateTime.now(),
      );

      final state = StudyState(
        repository: studyRepo,
        initialUser: user,
        now: () => today,
      );

      // 0 days initially
      expect(state.streak, equals(0));

      // Case 1: Checked yesterday (2026-10-28) but not yet today -> streak = 1
      await studyRepo.saveReading(
        uid: uid,
        entry: ReadingEntry(
          date: '2026-10-28',
          book: 'John',
          chapter: 1,
          verse: 1,
          completed: true,
          updatedAt: DateTime.now(),
        ),
      );
      await state.loadUserData();
      expect(state.streak, equals(1));

      // Case 2: Also check today -> streak = 2
      await state.toggleMarkToday();
      expect(state.streak, equals(2));

      // Case 3: Also checked day before yesterday (2026-10-27) -> streak = 3
      await studyRepo.saveReading(
        uid: uid,
        entry: ReadingEntry(
          date: '2026-10-27',
          book: 'John',
          chapter: 2,
          verse: 1,
          completed: true,
          updatedAt: DateTime.now(),
        ),
      );
      await state.loadUserData();
      expect(state.streak, equals(3));

      // Case 4: Gap test - Skip 2026-10-28 (yesterday)
      await studyRepo.saveReading(
        uid: uid,
        entry: ReadingEntry(
          date: '2026-10-28',
          book: 'John',
          chapter: 1,
          verse: 1,
          completed: false, // undone / missed
          updatedAt: DateTime.now(),
        ),
      );
      await state.loadUserData();
      // Since today is checked, but yesterday was missed, streak is 1
      expect(state.streak, equals(1));
    });
  });

  group('Auth & UI Widget Tests', () {
    testWidgets('Unauthenticated user is greeted with LoginScreen', (
      WidgetTester tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      final fakeStudy = FakeStudyRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: fakeAuth),
            Provider<StudyRepository>.value(value: fakeStudy),
            ChangeNotifierProvider<AuthState>(
              create: (_) => AuthState(authRepository: fakeAuth),
            ),
          ],
          child: const BibleStudyApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('IndividualScreen displays Currently Studying card, controls, and mark read', (
      WidgetTester tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      final fakeStudy = FakeStudyRepository();
      final today = DateTime(2026, 10, 29);

      final user = await fakeAuth.signUp(
        name: 'Bego Tester',
        email: 'bego@example.com',
        password: 'password123',
      );

      final authState = AuthState(authRepository: fakeAuth);
      final studyState = StudyState(
        repository: fakeStudy,
        initialUser: user,
        now: () => today,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: fakeAuth),
            Provider<StudyRepository>.value(value: fakeStudy),
            ChangeNotifierProvider<AuthState>.value(value: authState),
            ChangeNotifierProvider<StudyState>.value(value: studyState),
          ],
          child: const MaterialApp(
            home: IndividualScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top card displays "Currently studying", "John 1", "Verse 1"
      expect(find.text('Currently studying'), findsOneWidget);
      expect(find.text('John 1'), findsOneWidget);
      expect(find.text('Verse 1'), findsOneWidget);

      // Buttons
      expect(find.text('Mark as read today'), findsOneWidget);
      expect(find.text('Daily Reminder'), findsOneWidget);
      expect(find.text('Reading History'), findsOneWidget);
      expect(find.text('No reading history yet'), findsOneWidget);

      // Tap Mark as read today
      await tester.tap(find.text('Mark as read today'));
      await tester.pumpAndSettle();

      // Toggles to Read ✓ (tap to undo) and shows Next chapter
      expect(find.text('Read ✓ (tap to undo)'), findsOneWidget);
      expect(find.text('Next chapter: John 2'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('1 day'), findsOneWidget);

      // Tap Next chapter
      await tester.tap(find.text('Next chapter: John 2'));
      await tester.pumpAndSettle();
      expect(find.text('John 2'), findsOneWidget);
    });
  });
}
