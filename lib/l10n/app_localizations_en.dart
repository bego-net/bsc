// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bible Study';

  @override
  String get individualBs => 'Individual BS';

  @override
  String get teamBs => 'Team BS';

  @override
  String get oldTestament => 'Old Testament';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get change => 'Change';

  @override
  String get refresh => 'Refresh';

  @override
  String get logIn => 'Log in';

  @override
  String get logOut => 'Log out';

  @override
  String get signUp => 'Sign up';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get language => 'Language';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get english => 'English';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue your daily Bible study';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get enterUsername => 'Please enter your username';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinBibleStudy => 'Join Bible Study';

  @override
  String get signupSubtitle =>
      'Sign up as a study member to begin your daily journey';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get usernameHint => 'Username (3–20 chars, a–z, 0–9, _)';

  @override
  String get chooseUsername => 'Please choose a username';

  @override
  String get invalidUsername =>
      'Use 3–20 lowercase letters, digits, or underscores';

  @override
  String get passwordHint => 'Password (min 6 characters)';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get needHelp => 'Need help?';

  @override
  String get forgotPasswordHelp =>
      'Password resets are handled by your Bible Study leader. Send them a message using the button below and they will give you a temporary password.';

  @override
  String get yourUsername => 'Your username';

  @override
  String get copyRequestMessage => 'Copy request message';

  @override
  String get copied => 'Copied!';

  @override
  String get requestMessagePreview =>
      'The message will be: \"Please reset my Bible Study password. My username is <your username>.\"';

  @override
  String get setNewPassword => 'Set a New Password';

  @override
  String get forceChangeSubtitle =>
      'Your leader has set a temporary password.\nPlease choose a new one before continuing.';

  @override
  String get newPasswordHint => 'New password (min 6 characters)';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get setPassword => 'Set Password';

  @override
  String get profile => 'Profile';

  @override
  String get memberBadge => 'Member';

  @override
  String get adminBadge => 'Admin';

  @override
  String get usernameReadOnly => 'Username (cannot be changed)';

  @override
  String get memberSince => 'Member since';

  @override
  String get displayName => 'Display Name';

  @override
  String get saveName => 'Save Name';

  @override
  String get nameUpdated => 'Name updated ✓';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get stats => 'Stats';

  @override
  String get ibsStreakLabel => 'Individual BS streak';

  @override
  String get ibsReadingDaysLabel => 'Individual reading days';

  @override
  String get otStreakLabel => 'OT streak';

  @override
  String get otReadingDaysLabel => 'OT reading days';

  @override
  String get teamBsPreparedLabel => 'Team BS prepared';

  @override
  String get yesCheck => 'Yes ✓';

  @override
  String get notYet => 'Not yet';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get settings => 'Settings';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get otReminders => 'Old Testament Reminders';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully ✓';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to sign out of your account?';

  @override
  String get individualBsTitle => 'Individual BS';

  @override
  String get currentlyStudying => 'Currently studying';

  @override
  String get markAsReadToday => 'Mark as read today';

  @override
  String get readTodayCompleted => 'Read ✓';

  @override
  String get undoRead => 'tap to undo';

  @override
  String get nextChapterPrompt => 'Great job! Advance to next chapter?';

  @override
  String get advance => 'Next chapter';

  @override
  String get readingHistory => 'Reading History';

  @override
  String get noHistoryYet => 'No reading history yet';

  @override
  String get firstStudyPrompt =>
      'Complete your first study today to build your streak!';

  @override
  String get today => 'Today';

  @override
  String get selectBook => 'Select Book';

  @override
  String get selectChapter => 'Select Chapter';

  @override
  String selectChapterForBook(String book) {
    return 'Select Chapter for $book';
  }

  @override
  String get chapter => 'Chapter';

  @override
  String get verse => 'Verse';

  @override
  String get verses => 'Verses';

  @override
  String get fromVerse => 'From verse';

  @override
  String get toVerse => 'To verse';

  @override
  String get wholeChapter => 'Whole Chapter';

  @override
  String streakDay(int count) {
    return '$count day';
  }

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get portionDetails => 'Reading Details';

  @override
  String get portion => 'Portion';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get completedStatus => 'Completed ✓';

  @override
  String get undoneStatus => 'Undone';

  @override
  String get recordedTime => 'Recorded';

  @override
  String get searchBooks => 'Search books...';

  @override
  String get oldTestamentHeader => 'Old Testament (39 Books)';

  @override
  String get newTestamentHeader => 'New Testament (27 Books)';

  @override
  String get noBooksFound => 'No books found';

  @override
  String chaptersCount(int count) {
    return '$count chapters';
  }

  @override
  String get teamBsTitle => 'Team BS';

  @override
  String get thisWeeksPassage => 'This Week\'s Passage';

  @override
  String get studyTimeAndPlace => 'Study Time & Place';

  @override
  String get discussionQuestions => 'Discussion Questions';

  @override
  String get studyMaterials => 'Study Materials';

  @override
  String get iAmPrepared => 'I am prepared for this week';

  @override
  String get preparedBadge => 'Prepared ✓';

  @override
  String get markAsPrepared => 'Mark as prepared';

  @override
  String get adminTools => 'Admin Tools';

  @override
  String get noActiveWeek => 'No study scheduled for this week';

  @override
  String get checkBackLater => 'Check back later or contact your study leader.';

  @override
  String get otTitle => 'Old Testament';

  @override
  String get otPlan => 'Reading Plan';

  @override
  String get todayReading => 'Today\'s Reading';

  @override
  String completedDaysProgress(int completed, int total) {
    return '$completed of $total readings done';
  }

  @override
  String get bookFinished => 'Book finished';

  @override
  String get bookFinishedNotice =>
      'The reading of this book is finished. Admin can select a new book.';

  @override
  String get pastWeeks => 'Past Weeks';

  @override
  String get noOtWeek => 'No Old Testament plan active';

  @override
  String get contactAdminPlan => 'Ask your leader to publish a plan.';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get overall => 'Overall';

  @override
  String get thisWeek => 'This Week';

  @override
  String get individualCategory => 'Individual';

  @override
  String get teamCategory => 'Team';

  @override
  String get otCategory => 'Old Testament';

  @override
  String points(int points) {
    return '$points pts';
  }

  @override
  String streakFormatted(int streak) {
    return '$streak streak';
  }

  @override
  String get rank => 'Rank';

  @override
  String get noLeaderboardData => 'No members to display yet';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get membersList => 'Members list';

  @override
  String get copySummary => 'Copy weekly summary';

  @override
  String get summaryCopied => 'Weekly summary copied to clipboard';

  @override
  String get totalMembers => 'Total Members';

  @override
  String get preparedThisWeek => 'Prepared this week';

  @override
  String get activeReaders => 'Active readers';

  @override
  String get needsEncouragement => 'Needs Encouragement';

  @override
  String lastActive(String date) {
    return 'Last active: $date';
  }

  @override
  String get noMembersNeedsEncouragement => 'Everyone is actively reading! 🎉';

  @override
  String thursdayReminderTitle(String passage) {
    return 'Friday study tomorrow: $passage';
  }

  @override
  String thursdayReminderBody(String time, String place) {
    return '$time, $place. Have you read the questions?';
  }

  @override
  String otReminderTitle(String passage) {
    return 'Old Testament today: $passage';
  }

  @override
  String get otReminderBody => 'Daily reading';

  @override
  String get adminHome => 'Admin Tools';

  @override
  String get publish => 'Publish';

  @override
  String get unpublish => 'Unpublish';

  @override
  String get published => 'Published';

  @override
  String get draft => 'Draft';

  @override
  String get questions => 'Questions';

  @override
  String get materials => 'Materials';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get startDate => 'Start Date';

  @override
  String get startChapter => 'Start Chapter';

  @override
  String get topic => 'Topic (Optional)';

  @override
  String get pickBook => 'Pick Book';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get enterFromVerse => 'Enter \"From\" Verse';

  @override
  String get enterToVerse => 'Enter \"To\" Verse';

  @override
  String cannotBeLowerThanFrom(Object from) {
    return 'Cannot be lower than \"From\" verse ($from)';
  }

  @override
  String get editThisWeeksStudy => 'Edit This Week\'s Study';

  @override
  String get noWeekPublished => 'No week published';

  @override
  String get manageQuestions => 'Manage Questions';

  @override
  String questionsCount(int count) {
    return '$count question(s)';
  }

  @override
  String get manageMaterials => 'Manage Materials';

  @override
  String materialsCount(int count) {
    return '$count material(s)';
  }

  @override
  String get memberOverview => 'Member Overview';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminDashboardSubtitle => 'Stats, rankings, and weekly summary';

  @override
  String get testNotification => '🔔 Test notification';

  @override
  String testNotificationSent(String passage) {
    return 'Test notification sent for $passage';
  }

  @override
  String get noWeekToTest => 'No week published — nothing to test.';

  @override
  String get book => 'Book';

  @override
  String chapterRange(int max) {
    return 'Chapter  (1 – $max)';
  }

  @override
  String get verseFrom => 'Verse From';

  @override
  String get verseTo => 'Verse To';

  @override
  String get sessionDay => 'Session Day';

  @override
  String get sessionTime => 'Session Time';

  @override
  String get place => 'Place';

  @override
  String get placeHint => 'e.g. Church hall, Room 2';

  @override
  String get placeRequired => 'Enter a place';

  @override
  String get thursdayReminderTimeLabel => 'Thursday Reminder Time';

  @override
  String get startAsNewWeek => 'Start as a new week document';

  @override
  String get startAsNewWeekSubtitle =>
      'Turn on if the passage has changed and you want a clean history entry.';

  @override
  String publishedFor(String passage) {
    return 'Published: $passage';
  }

  @override
  String get couldNotPublish => 'Could not publish. Please try again.';

  @override
  String get searchBookHint => 'Search book…';

  @override
  String get addMaterial => 'Add Material';

  @override
  String get editMaterial => 'Edit Material';

  @override
  String get title => 'Title';

  @override
  String get bodyDescription => 'Body / description (optional)';

  @override
  String get urlOptional => 'URL (optional)';

  @override
  String get deleteMaterial => 'Delete Material?';

  @override
  String get addQuestion => 'Add Question';

  @override
  String get editQuestion => 'Edit Question';

  @override
  String get questionText => 'Question text';

  @override
  String get deleteQuestion => 'Delete Question?';

  @override
  String get publishWeekFirst => 'Publish a week first.';

  @override
  String get noMaterialsYet => 'No materials yet. Tap + to add.';

  @override
  String get noQuestionsYet => 'No questions yet. Tap + to add.';

  @override
  String get members => 'Members';

  @override
  String get searchByNameOrUsername => 'Search by name or username…';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByLastActive => 'Last active';

  @override
  String get sortByMostActive => 'Most active';

  @override
  String get needsEncouragementFilter => 'Needs encouragement';

  @override
  String get noMembersFound => 'No members found.';

  @override
  String lastReadDate(String date) {
    return 'Last read: $date';
  }

  @override
  String get noReadingRecorded => 'No reading recorded';

  @override
  String get memberDetail => 'Member Detail';

  @override
  String get role => 'Role';

  @override
  String get joined => 'Joined';

  @override
  String get currentStudy => 'Current Study';

  @override
  String get streaks => 'Streaks';

  @override
  String get ibsHistory30 => 'Individual BS – last 30 days';

  @override
  String get otHistory30 => 'Old Testament – last 30 days';

  @override
  String get teamBsHistory => 'Team BS – prepared per week';

  @override
  String get noReadingsRecorded => 'No readings recorded.';

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String get completedCheck => '✓ Completed';

  @override
  String get preparedCheck => '✓ Prepared';

  @override
  String get notPrepared => '– Not prepared';

  @override
  String get otAdminTools => 'OT Admin Tools';

  @override
  String get editWeekTopicPlan => 'Edit This Week\'s Topic & Plan';

  @override
  String get noActiveWeekPublished => 'No active week published';

  @override
  String get otMemberOverview => 'OT Member Overview';

  @override
  String get viewCompletionStats => 'View completion stats for this week';

  @override
  String weekStartingTotal(String date, int count) {
    return 'Week starting $date • Total members: $count';
  }

  @override
  String get noMembersRegistered => 'No members registered.';

  @override
  String get noActiveWeekPublishedDot => 'No active week published.';

  @override
  String preparedOf(int prepared, int total) {
    return '$prepared of $total prepared';
  }

  @override
  String lastReadingDate(String date) {
    return 'Last reading: $date';
  }

  @override
  String get couldNotLoadMemberOverview => 'Could not load member overview.';

  @override
  String get bookFinishedStatus => 'Book finished';

  @override
  String get comingSoon => 'Coming soon';
}
