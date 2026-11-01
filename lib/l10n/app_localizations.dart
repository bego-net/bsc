import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Study'**
  String get appTitle;

  /// No description provided for @individualBs.
  ///
  /// In en, this message translates to:
  /// **'Individual BS'**
  String get individualBs;

  /// No description provided for @teamBs.
  ///
  /// In en, this message translates to:
  /// **'Team BS'**
  String get teamBs;

  /// No description provided for @oldTestament.
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get oldTestament;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get amharic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your daily Bible study'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinBibleStudy.
  ///
  /// In en, this message translates to:
  /// **'Join Bible Study'**
  String get joinBibleStudy;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a study member to begin your daily journey'**
  String get signupSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username (3–20 chars, a–z, 0–9, _)'**
  String get usernameHint;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Please choose a username'**
  String get chooseUsername;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Use 3–20 lowercase letters, digits, or underscores'**
  String get invalidUsername;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6 characters)'**
  String get passwordHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @forgotPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Password resets are handled by your Bible Study leader. Send them a message using the button below and they will give you a temporary password.'**
  String get forgotPasswordHelp;

  /// No description provided for @yourUsername.
  ///
  /// In en, this message translates to:
  /// **'Your username'**
  String get yourUsername;

  /// No description provided for @copyRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy request message'**
  String get copyRequestMessage;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @requestMessagePreview.
  ///
  /// In en, this message translates to:
  /// **'The message will be: \"Please reset my Bible Study password. My username is <your username>.\"'**
  String get requestMessagePreview;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a New Password'**
  String get setNewPassword;

  /// No description provided for @forceChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your leader has set a temporary password.\nPlease choose a new one before continuing.'**
  String get forceChangeSubtitle;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password (min 6 characters)'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @memberBadge.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberBadge;

  /// No description provided for @adminBadge.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminBadge;

  /// No description provided for @usernameReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Username (cannot be changed)'**
  String get usernameReadOnly;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @saveName.
  ///
  /// In en, this message translates to:
  /// **'Save Name'**
  String get saveName;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated ✓'**
  String get nameUpdated;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @ibsStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Individual BS streak'**
  String get ibsStreakLabel;

  /// No description provided for @ibsReadingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Individual reading days'**
  String get ibsReadingDaysLabel;

  /// No description provided for @otStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'OT streak'**
  String get otStreakLabel;

  /// No description provided for @otReadingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'OT reading days'**
  String get otReadingDaysLabel;

  /// No description provided for @teamBsPreparedLabel.
  ///
  /// In en, this message translates to:
  /// **'Team BS prepared'**
  String get teamBsPreparedLabel;

  /// No description provided for @yesCheck.
  ///
  /// In en, this message translates to:
  /// **'Yes ✓'**
  String get yesCheck;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @otReminders.
  ///
  /// In en, this message translates to:
  /// **'Old Testament Reminders'**
  String get otReminders;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully ✓'**
  String get passwordUpdatedSuccess;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get logoutConfirmMessage;

  /// No description provided for @individualBsTitle.
  ///
  /// In en, this message translates to:
  /// **'Individual BS'**
  String get individualBsTitle;

  /// No description provided for @currentlyStudying.
  ///
  /// In en, this message translates to:
  /// **'Currently studying'**
  String get currentlyStudying;

  /// No description provided for @markAsReadToday.
  ///
  /// In en, this message translates to:
  /// **'Mark as read today'**
  String get markAsReadToday;

  /// No description provided for @readTodayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Read ✓'**
  String get readTodayCompleted;

  /// No description provided for @undoRead.
  ///
  /// In en, this message translates to:
  /// **'tap to undo'**
  String get undoRead;

  /// No description provided for @nextChapterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Great job! Advance to next chapter?'**
  String get nextChapterPrompt;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get advance;

  /// No description provided for @readingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading History'**
  String get readingHistory;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No reading history yet'**
  String get noHistoryYet;

  /// No description provided for @firstStudyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete your first study today to build your streak!'**
  String get firstStudyPrompt;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @selectBook.
  ///
  /// In en, this message translates to:
  /// **'Select Book'**
  String get selectBook;

  /// No description provided for @selectChapter.
  ///
  /// In en, this message translates to:
  /// **'Select Chapter'**
  String get selectChapter;

  /// No description provided for @selectChapterForBook.
  ///
  /// In en, this message translates to:
  /// **'Select Chapter for {book}'**
  String selectChapterForBook(String book);

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @verse.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get verse;

  /// No description provided for @verses.
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get verses;

  /// No description provided for @fromVerse.
  ///
  /// In en, this message translates to:
  /// **'From verse'**
  String get fromVerse;

  /// No description provided for @toVerse.
  ///
  /// In en, this message translates to:
  /// **'To verse'**
  String get toVerse;

  /// No description provided for @wholeChapter.
  ///
  /// In en, this message translates to:
  /// **'Whole Chapter'**
  String get wholeChapter;

  /// No description provided for @streakDay.
  ///
  /// In en, this message translates to:
  /// **'{count} day'**
  String streakDay(int count);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @portionDetails.
  ///
  /// In en, this message translates to:
  /// **'Reading Details'**
  String get portionDetails;

  /// No description provided for @portion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get portion;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get completedStatus;

  /// No description provided for @undoneStatus.
  ///
  /// In en, this message translates to:
  /// **'Undone'**
  String get undoneStatus;

  /// No description provided for @recordedTime.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recordedTime;

  /// No description provided for @searchBooks.
  ///
  /// In en, this message translates to:
  /// **'Search books...'**
  String get searchBooks;

  /// No description provided for @oldTestamentHeader.
  ///
  /// In en, this message translates to:
  /// **'Old Testament (39 Books)'**
  String get oldTestamentHeader;

  /// No description provided for @newTestamentHeader.
  ///
  /// In en, this message translates to:
  /// **'New Testament (27 Books)'**
  String get newTestamentHeader;

  /// No description provided for @noBooksFound.
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get noBooksFound;

  /// No description provided for @chaptersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chapters'**
  String chaptersCount(int count);

  /// No description provided for @teamBsTitle.
  ///
  /// In en, this message translates to:
  /// **'Team BS'**
  String get teamBsTitle;

  /// No description provided for @thisWeeksPassage.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Passage'**
  String get thisWeeksPassage;

  /// No description provided for @studyTimeAndPlace.
  ///
  /// In en, this message translates to:
  /// **'Study Time & Place'**
  String get studyTimeAndPlace;

  /// No description provided for @discussionQuestions.
  ///
  /// In en, this message translates to:
  /// **'Discussion Questions'**
  String get discussionQuestions;

  /// No description provided for @studyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Study Materials'**
  String get studyMaterials;

  /// No description provided for @iAmPrepared.
  ///
  /// In en, this message translates to:
  /// **'I am prepared for this week'**
  String get iAmPrepared;

  /// No description provided for @preparedBadge.
  ///
  /// In en, this message translates to:
  /// **'Prepared ✓'**
  String get preparedBadge;

  /// No description provided for @markAsPrepared.
  ///
  /// In en, this message translates to:
  /// **'Mark as prepared'**
  String get markAsPrepared;

  /// No description provided for @adminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get adminTools;

  /// No description provided for @noActiveWeek.
  ///
  /// In en, this message translates to:
  /// **'No study scheduled for this week'**
  String get noActiveWeek;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later or contact your study leader.'**
  String get checkBackLater;

  /// No description provided for @otTitle.
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get otTitle;

  /// No description provided for @otPlan.
  ///
  /// In en, this message translates to:
  /// **'Reading Plan'**
  String get otPlan;

  /// No description provided for @todayReading.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reading'**
  String get todayReading;

  /// No description provided for @completedDaysProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} readings done'**
  String completedDaysProgress(int completed, int total);

  /// No description provided for @bookFinished.
  ///
  /// In en, this message translates to:
  /// **'Book finished'**
  String get bookFinished;

  /// No description provided for @bookFinishedNotice.
  ///
  /// In en, this message translates to:
  /// **'The reading of this book is finished. Admin can select a new book.'**
  String get bookFinishedNotice;

  /// No description provided for @pastWeeks.
  ///
  /// In en, this message translates to:
  /// **'Past Weeks'**
  String get pastWeeks;

  /// No description provided for @noOtWeek.
  ///
  /// In en, this message translates to:
  /// **'No Old Testament plan active'**
  String get noOtWeek;

  /// No description provided for @contactAdminPlan.
  ///
  /// In en, this message translates to:
  /// **'Ask your leader to publish a plan.'**
  String get contactAdminPlan;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @individualCategory.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualCategory;

  /// No description provided for @teamCategory.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamCategory;

  /// No description provided for @otCategory.
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get otCategory;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String points(int points);

  /// No description provided for @streakFormatted.
  ///
  /// In en, this message translates to:
  /// **'{streak} streak'**
  String streakFormatted(int streak);

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @noLeaderboardData.
  ///
  /// In en, this message translates to:
  /// **'No members to display yet'**
  String get noLeaderboardData;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @membersList.
  ///
  /// In en, this message translates to:
  /// **'Members list'**
  String get membersList;

  /// No description provided for @copySummary.
  ///
  /// In en, this message translates to:
  /// **'Copy weekly summary'**
  String get copySummary;

  /// No description provided for @summaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary copied to clipboard'**
  String get summaryCopied;

  /// No description provided for @totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get totalMembers;

  /// No description provided for @preparedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Prepared this week'**
  String get preparedThisWeek;

  /// No description provided for @activeReaders.
  ///
  /// In en, this message translates to:
  /// **'Active readers'**
  String get activeReaders;

  /// No description provided for @needsEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Needs Encouragement'**
  String get needsEncouragement;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active: {date}'**
  String lastActive(String date);

  /// No description provided for @noMembersNeedsEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Everyone is actively reading! 🎉'**
  String get noMembersNeedsEncouragement;

  /// No description provided for @thursdayReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Friday study tomorrow: {passage}'**
  String thursdayReminderTitle(String passage);

  /// No description provided for @thursdayReminderBody.
  ///
  /// In en, this message translates to:
  /// **'{time}, {place}. Have you read the questions?'**
  String thursdayReminderBody(String time, String place);

  /// No description provided for @otReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Old Testament today: {passage}'**
  String otReminderTitle(String passage);

  /// No description provided for @otReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Daily reading'**
  String get otReminderBody;

  /// No description provided for @adminHome.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get adminHome;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @unpublish.
  ///
  /// In en, this message translates to:
  /// **'Unpublish'**
  String get unpublish;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startChapter.
  ///
  /// In en, this message translates to:
  /// **'Start Chapter'**
  String get startChapter;

  /// No description provided for @topic.
  ///
  /// In en, this message translates to:
  /// **'Topic (Optional)'**
  String get topic;

  /// No description provided for @pickBook.
  ///
  /// In en, this message translates to:
  /// **'Pick Book'**
  String get pickBook;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @enterFromVerse.
  ///
  /// In en, this message translates to:
  /// **'Enter \"From\" Verse'**
  String get enterFromVerse;

  /// No description provided for @enterToVerse.
  ///
  /// In en, this message translates to:
  /// **'Enter \"To\" Verse'**
  String get enterToVerse;

  /// No description provided for @cannotBeLowerThanFrom.
  ///
  /// In en, this message translates to:
  /// **'Cannot be lower than \"From\" verse ({from})'**
  String cannotBeLowerThanFrom(Object from);

  /// No description provided for @editThisWeeksStudy.
  ///
  /// In en, this message translates to:
  /// **'Edit This Week\'s Study'**
  String get editThisWeeksStudy;

  /// No description provided for @noWeekPublished.
  ///
  /// In en, this message translates to:
  /// **'No week published'**
  String get noWeekPublished;

  /// No description provided for @manageQuestions.
  ///
  /// In en, this message translates to:
  /// **'Manage Questions'**
  String get manageQuestions;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} question(s)'**
  String questionsCount(int count);

  /// No description provided for @manageMaterials.
  ///
  /// In en, this message translates to:
  /// **'Manage Materials'**
  String get manageMaterials;

  /// No description provided for @materialsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} material(s)'**
  String materialsCount(int count);

  /// No description provided for @memberOverview.
  ///
  /// In en, this message translates to:
  /// **'Member Overview'**
  String get memberOverview;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stats, rankings, and weekly summary'**
  String get adminDashboardSubtitle;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'🔔 Test notification'**
  String get testNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent for {passage}'**
  String testNotificationSent(String passage);

  /// No description provided for @noWeekToTest.
  ///
  /// In en, this message translates to:
  /// **'No week published — nothing to test.'**
  String get noWeekToTest;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @chapterRange.
  ///
  /// In en, this message translates to:
  /// **'Chapter  (1 – {max})'**
  String chapterRange(int max);

  /// No description provided for @verseFrom.
  ///
  /// In en, this message translates to:
  /// **'Verse From'**
  String get verseFrom;

  /// No description provided for @verseTo.
  ///
  /// In en, this message translates to:
  /// **'Verse To'**
  String get verseTo;

  /// No description provided for @sessionDay.
  ///
  /// In en, this message translates to:
  /// **'Session Day'**
  String get sessionDay;

  /// No description provided for @sessionTime.
  ///
  /// In en, this message translates to:
  /// **'Session Time'**
  String get sessionTime;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @placeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Church hall, Room 2'**
  String get placeHint;

  /// No description provided for @placeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a place'**
  String get placeRequired;

  /// No description provided for @thursdayReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Thursday Reminder Time'**
  String get thursdayReminderTimeLabel;

  /// No description provided for @startAsNewWeek.
  ///
  /// In en, this message translates to:
  /// **'Start as a new week document'**
  String get startAsNewWeek;

  /// No description provided for @startAsNewWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on if the passage has changed and you want a clean history entry.'**
  String get startAsNewWeekSubtitle;

  /// No description provided for @publishedFor.
  ///
  /// In en, this message translates to:
  /// **'Published: {passage}'**
  String publishedFor(String passage);

  /// No description provided for @couldNotPublish.
  ///
  /// In en, this message translates to:
  /// **'Could not publish. Please try again.'**
  String get couldNotPublish;

  /// No description provided for @searchBookHint.
  ///
  /// In en, this message translates to:
  /// **'Search book…'**
  String get searchBookHint;

  /// No description provided for @addMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get addMaterial;

  /// No description provided for @editMaterial.
  ///
  /// In en, this message translates to:
  /// **'Edit Material'**
  String get editMaterial;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @bodyDescription.
  ///
  /// In en, this message translates to:
  /// **'Body / description (optional)'**
  String get bodyDescription;

  /// No description provided for @urlOptional.
  ///
  /// In en, this message translates to:
  /// **'URL (optional)'**
  String get urlOptional;

  /// No description provided for @deleteMaterial.
  ///
  /// In en, this message translates to:
  /// **'Delete Material?'**
  String get deleteMaterial;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestion;

  /// No description provided for @editQuestion.
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get editQuestion;

  /// No description provided for @questionText.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get questionText;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Question?'**
  String get deleteQuestion;

  /// No description provided for @publishWeekFirst.
  ///
  /// In en, this message translates to:
  /// **'Publish a week first.'**
  String get publishWeekFirst;

  /// No description provided for @noMaterialsYet.
  ///
  /// In en, this message translates to:
  /// **'No materials yet. Tap + to add.'**
  String get noMaterialsYet;

  /// No description provided for @noQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions yet. Tap + to add.'**
  String get noQuestionsYet;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @searchByNameOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Search by name or username…'**
  String get searchByNameOrUsername;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get sortByLastActive;

  /// No description provided for @sortByMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active'**
  String get sortByMostActive;

  /// No description provided for @needsEncouragementFilter.
  ///
  /// In en, this message translates to:
  /// **'Needs encouragement'**
  String get needsEncouragementFilter;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get noMembersFound;

  /// No description provided for @lastReadDate.
  ///
  /// In en, this message translates to:
  /// **'Last read: {date}'**
  String lastReadDate(String date);

  /// No description provided for @noReadingRecorded.
  ///
  /// In en, this message translates to:
  /// **'No reading recorded'**
  String get noReadingRecorded;

  /// No description provided for @memberDetail.
  ///
  /// In en, this message translates to:
  /// **'Member Detail'**
  String get memberDetail;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @currentStudy.
  ///
  /// In en, this message translates to:
  /// **'Current Study'**
  String get currentStudy;

  /// No description provided for @streaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// No description provided for @ibsHistory30.
  ///
  /// In en, this message translates to:
  /// **'Individual BS – last 30 days'**
  String get ibsHistory30;

  /// No description provided for @otHistory30.
  ///
  /// In en, this message translates to:
  /// **'Old Testament – last 30 days'**
  String get otHistory30;

  /// No description provided for @teamBsHistory.
  ///
  /// In en, this message translates to:
  /// **'Team BS – prepared per week'**
  String get teamBsHistory;

  /// No description provided for @noReadingsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No readings recorded.'**
  String get noReadingsRecorded;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// No description provided for @completedCheck.
  ///
  /// In en, this message translates to:
  /// **'✓ Completed'**
  String get completedCheck;

  /// No description provided for @preparedCheck.
  ///
  /// In en, this message translates to:
  /// **'✓ Prepared'**
  String get preparedCheck;

  /// No description provided for @notPrepared.
  ///
  /// In en, this message translates to:
  /// **'– Not prepared'**
  String get notPrepared;

  /// No description provided for @otAdminTools.
  ///
  /// In en, this message translates to:
  /// **'OT Admin Tools'**
  String get otAdminTools;

  /// No description provided for @editWeekTopicPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit This Week\'s Topic & Plan'**
  String get editWeekTopicPlan;

  /// No description provided for @noActiveWeekPublished.
  ///
  /// In en, this message translates to:
  /// **'No active week published'**
  String get noActiveWeekPublished;

  /// No description provided for @otMemberOverview.
  ///
  /// In en, this message translates to:
  /// **'OT Member Overview'**
  String get otMemberOverview;

  /// No description provided for @viewCompletionStats.
  ///
  /// In en, this message translates to:
  /// **'View completion stats for this week'**
  String get viewCompletionStats;

  /// No description provided for @weekStartingTotal.
  ///
  /// In en, this message translates to:
  /// **'Week starting {date} • Total members: {count}'**
  String weekStartingTotal(String date, int count);

  /// No description provided for @noMembersRegistered.
  ///
  /// In en, this message translates to:
  /// **'No members registered.'**
  String get noMembersRegistered;

  /// No description provided for @noActiveWeekPublishedDot.
  ///
  /// In en, this message translates to:
  /// **'No active week published.'**
  String get noActiveWeekPublishedDot;

  /// No description provided for @preparedOf.
  ///
  /// In en, this message translates to:
  /// **'{prepared} of {total} prepared'**
  String preparedOf(int prepared, int total);

  /// No description provided for @lastReadingDate.
  ///
  /// In en, this message translates to:
  /// **'Last reading: {date}'**
  String lastReadingDate(String date);

  /// No description provided for @couldNotLoadMemberOverview.
  ///
  /// In en, this message translates to:
  /// **'Could not load member overview.'**
  String get couldNotLoadMemberOverview;

  /// No description provided for @bookFinishedStatus.
  ///
  /// In en, this message translates to:
  /// **'Book finished'**
  String get bookFinishedStatus;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
