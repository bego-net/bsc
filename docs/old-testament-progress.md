# Old Testament Progress Checklist

## 1. Idea & Data Models
- [x] DONE: `lib/models/ot_week.dart` (id, topic, startDate, publishedAt, updatedBy, days).
- [x] DONE: `lib/models/ot_day.dart` (date, book, chapter, verseFrom, verseTo, passage formatting for whole chapter vs single verse vs verse range).
- [x] DONE: `lib/models/ot_member_overview_item.dart` (uid, name, email, completedDays, totalDays).
- [x] DONE: Helper in `lib/data/bible_books.dart` (`oldTestament`) for filtering the 39 Old Testament books.

## 2. Repositories
- [x] DONE: `lib/repositories/ot_repository.dart` (abstract interface).
- [x] DONE: `lib/repositories/fake_ot_repository.dart` (in-memory implementation for tests & offline mode with seed data).
- [x] DONE: `lib/repositories/firebase_ot_repository.dart` (Firestore implementation with batch operations).

## 3. Firestore Rules
- [x] DONE: Updated `firestore.rules` for `config/currentOtWeek`, `otWeeks/{weekId}`, `days/{date}`, and `users/{uid}/otReadings/{date}` with role restrictions.

## 4. Notifications & Settings
- [x] DONE: Extended `NotificationService` with daily Old Testament reminder scheduling and cancellation on days with a passage.
- [x] DONE: User reminder switch ("Old Testament reminders", default on), reschedule on launch/login/publish/toggle, cancel on logout.
- [x] DONE: Payload `'old_testament'` wired in `AppShell` to switch to Old Testament tab.

## 5. State Management
- [x] DONE: `lib/state/ot_state.dart` with current week, day readings, catch-up logic, progress count, streak calculation, history, and member overview.
- [x] DONE: Registered `OtRepository` and `OtState` in `lib/main.dart` with `MultiProvider` & `ChangeNotifierProxyProvider`.

## 6. Member Screen & History
- [x] DONE: `lib/screens/old_testament_screen.dart` replacing the placeholder in `lib/app.dart`.
- [x] DONE: Topic card with progress bar ("3 of 5 readings done").
- [x] DONE: Today's reading highlighted with "Mark as read" button.
- [x] DONE: Week list with past days catch-up and locked future days.
- [x] DONE: Old Testament streak display with fire icon.
- [x] DONE: `lib/screens/ot_history_screen.dart` showing previous weeks and daily breakdown.
- [x] DONE: Reminder toggle switch in Old Testament tab.
- [x] DONE: Friendly empty state when no week published.

## 7. Admin Tools (Admin Only)
- [x] DONE: Admin button in AppBar (hidden for regular members).
- [x] DONE: `lib/screens/admin/ot_admin_home_screen.dart` navigation hub.
- [x] DONE: `lib/screens/admin/ot_edit_week_screen.dart`: topic, start date (coming Monday default), Mon-Fri + Sat/Sun toggle, searchable 39 OT books picker, chapter & verse range (optional), publish confirmation.
- [x] DONE: `lib/screens/admin/ot_overview_screen.dart`: read-only list showing members' completed days ("4 of 5").

## 8. Verification & Tests
- [x] DONE: Tests in `test/ot_test.dart` for passage formatting, progress and streak, future days locked vs past days catch-up, only OT books in picker, admin button visibility, and daily notification schedule.
- [x] DONE: `flutter analyze` passing with 0 issues.
- [x] DONE: `flutter test` passing all 31 tests cleanly.
