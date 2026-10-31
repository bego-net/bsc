# Team BS Progress Checklist

## 1. Role-based access
- [x] DONE: Read the signed-in user's role from Firestore and expose it in auth state (`AuthState.isAdmin`, `AuthState.userRole`).
- [x] DONE: Members get read-only Team BS screen; Admins get Admin tools button in app bar (`TeamScreen`).
- [x] DONE: Admin tools unreachable for members in UI and Firestore rules.
- [x] DONE: App never changes roles from client; sign-up restricted to member role; rules enforce immutability.

## 2. Admin tools (admin only)
- [x] DONE: This week's study: Searchable book list (reusing `BibleBooks`), chapter stepper, verse range steppers, session day/time, place, reminder time, publish button with confirmation.
- [x] DONE: Questions management: Add, edit, delete, reorder questions with published toggle (`QuestionsScreen` using non-deprecated `onReorderItem`).
- [x] DONE: Materials management: Add, edit, delete study materials with title, plain multiline body, optional URL, and published toggle (`MaterialsScreen`).
- [x] DONE: Member overview: Read-only member list showing name, last reading date, prepared status, and total prepared count ("X of Y prepared") (`OverviewScreen`).

## 3. Member Team BS screen
- [x] DONE: "This week's study" card with book, chapter, verse range, session day, time, place, and friendly empty state.
- [x] DONE: Questions section showing only published questions with sequential numbering.
- [x] DONE: Materials section showing only published materials; tapping URL launches browser via `url_launcher`.
- [x] DONE: "Mark as prepared" toggle button per user per week without collecting answers.
- [x] DONE: New week document creation when passage changes or admin specifies new week; previous weeks preserved as history.

## 4. Data model (Firestore)
- [x] DONE: `config/currentWeek` with `weekId`.
- [x] DONE: `weeks/{weekId}` schema: book, chapter, verseFrom, verseTo, sessionDay, sessionTime, place, thursdayReminderTime, publishedAt, updatedBy.
- [x] DONE: `weeks/{weekId}/questions/{id}`: text, order, published.
- [x] DONE: `weeks/{weekId}/materials/{id}`: title, body, url, published.
- [x] DONE: `weeks/{weekId}/prepared/{uid}`: prepared (bool), updatedAt.
- [x] DONE: `firestore.rules` updated with correct permissions for members and admins.

## 5. Notifications (Thursday reminder)
- [x] DONE: `flutter_local_notifications` + `timezone`: LocalNotificationService updated to named parameters matching v22 API; weekly repeating scheduled using `DateTimeComponents.dayOfWeekAndTime`.
- [x] DONE: Notification tap navigation: Exposes `selectedPayload` ValueNotifier; `AppShell` listens to payload `'team_bs'` and switches to Team BS tab.
- [x] DONE: Reschedule on app launch/login/config change (`TeamState.loadData`, `publishWeek`); cancel on logout in proxy provider.
- [x] DONE: Android 13+ permission request and inexact alarm scheduling.
- [x] DONE: Web (Chrome) check with comments and hidden test notification button in Admin tools.

## 6. Technical rules
- [x] DONE: Repository and service interfaces with fake and Firebase implementations (`TeamRepository`, `NotificationService`).
- [x] DONE: New files placed under required paths (`lib/models`, `lib/repositories`, `lib/services`, `lib/state`, `lib/screens/admin`).
- [x] DONE: Code hygiene: All deprecations and lints resolved; zero analyze warnings. Light theme preserved.

## 7. Verification
- [x] DONE: `flutter analyze` passing with no issues (0 issues found).
- [x] DONE: Unit and widget tests in `test/team_bs_test.dart` for passage formatting, published items filtering, role-based admin button visibility, and next Thursday calculation.
- [x] DONE: All 21 tests in `flutter test` pass cleanly.
