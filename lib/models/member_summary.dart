import 'reading_entry.dart';

/// Aggregated data about one member for the admin dashboard.
class MemberSummary {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime joinDate;

  // Current study position (Individual BS)
  final String currentBook;
  final int currentChapter;
  final int currentVerseFrom;
  final int currentVerseTo;

  // Last 7-day window stats (used in list & home card)
  final int ibsDaysThisWeek;   // Individual BS days read this week (0-7)
  final int otDaysThisWeek;    // OT days completed this week
  final int otTotalDaysThisWeek; // OT total assigned days this week
  final bool preparedThisWeek; // Team BS prepared?
  final String? lastReadDate;  // 'yyyy-MM-dd' or null

  // Streaks
  final int ibsStreak;
  final int otStreak;

  // Full 30-day history (loaded only on detail screen)
  final List<ReadingEntry> ibsHistory;     // sorted newest first
  final List<String> otReadingDates;       // 'yyyy-MM-dd' sorted newest first
  // weekId -> prepared (last 30 days)
  final Map<String, bool> teamPrepHistory;

  const MemberSummary({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'member',
    required this.joinDate,
    this.currentBook = 'John',
    this.currentChapter = 1,
    this.currentVerseFrom = 1,
    this.currentVerseTo = 1,
    this.ibsDaysThisWeek = 0,
    this.otDaysThisWeek = 0,
    this.otTotalDaysThisWeek = 0,
    this.preparedThisWeek = false,
    this.lastReadDate,
    this.ibsStreak = 0,
    this.otStreak = 0,
    this.ibsHistory = const [],
    this.otReadingDates = const [],
    this.teamPrepHistory = const {},
  });

  /// Returns the last 7 days of IBS dates that were completed.
  int get ibsDaysThisWeekCount => ibsDaysThisWeek;

  /// True if no reading in the last 3 days (needs encouragement).
  bool get needsEncouragement {
    if (lastReadDate == null) return true;
    final last = DateTime.tryParse(lastReadDate!);
    if (last == null) return true;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysSince = todayDate.difference(DateTime(last.year, last.month, last.day)).inDays;
    return daysSince >= 3;
  }

  MemberSummary copyWith({
    List<ReadingEntry>? ibsHistory,
    List<String>? otReadingDates,
    Map<String, bool>? teamPrepHistory,
    int? ibsStreak,
    int? otStreak,
  }) {
    return MemberSummary(
      uid: uid,
      name: name,
      email: email,
      role: role,
      joinDate: joinDate,
      currentBook: currentBook,
      currentChapter: currentChapter,
      currentVerseFrom: currentVerseFrom,
      currentVerseTo: currentVerseTo,
      ibsDaysThisWeek: ibsDaysThisWeek,
      otDaysThisWeek: otDaysThisWeek,
      otTotalDaysThisWeek: otTotalDaysThisWeek,
      preparedThisWeek: preparedThisWeek,
      lastReadDate: lastReadDate,
      ibsStreak: ibsStreak ?? this.ibsStreak,
      otStreak: otStreak ?? this.otStreak,
      ibsHistory: ibsHistory ?? this.ibsHistory,
      otReadingDates: otReadingDates ?? this.otReadingDates,
      teamPrepHistory: teamPrepHistory ?? this.teamPrepHistory,
    );
  }
}
