import '../models/member_summary.dart';
import '../models/reading_entry.dart';
import '../models/study_week.dart';
import 'dashboard_repository.dart';

/// In-memory implementation of [DashboardRepository] for testing and offline development.
class FakeDashboardRepository implements DashboardRepository {
  // Seeded members for offline/test use.
  final List<MemberSummary> _members;
  final Map<String, List<ReadingEntry>> _ibsHistories;
  final Map<String, List<String>> _otHistories;
  final Map<String, Map<String, bool>> _teamHistories;
  final StudyWeek? _currentTeamWeek;

  FakeDashboardRepository({
    List<MemberSummary>? members,
    Map<String, List<ReadingEntry>>? ibsHistories,
    Map<String, List<String>>? otHistories,
    Map<String, Map<String, bool>>? teamHistories,
    StudyWeek? currentTeamWeek,
  })  : _members = members ?? _defaultMembers(),
        _ibsHistories = ibsHistories ?? {},
        _otHistories = otHistories ?? {},
        _teamHistories = teamHistories ?? {},
        _currentTeamWeek = currentTeamWeek ?? _defaultTeamWeek();

  static List<MemberSummary> _defaultMembers() {
    final now = DateTime.now();
    final today = _fmt(now);
    final yesterday = _fmt(now.subtract(const Duration(days: 1)));
    final twoDaysAgo = _fmt(now.subtract(const Duration(days: 2)));
    final fourDaysAgo = _fmt(now.subtract(const Duration(days: 4)));

    return [
      MemberSummary(
        uid: 'user_sarah',
        name: 'Sarah Chen',
        email: 'sarah@example.com',
        joinDate: now.subtract(const Duration(days: 60)),
        currentBook: 'Matthew',
        currentChapter: 7,
        ibsDaysThisWeek: 5,
        otDaysThisWeek: 3,
        otTotalDaysThisWeek: 5,
        preparedThisWeek: true,
        lastReadDate: today,
        ibsStreak: 5,
        otStreak: 3,
      ),
      MemberSummary(
        uid: 'user_michael',
        name: 'Michael Davis',
        email: 'michael@example.com',
        joinDate: now.subtract(const Duration(days: 45)),
        currentBook: 'John',
        currentChapter: 3,
        ibsDaysThisWeek: 3,
        otDaysThisWeek: 2,
        otTotalDaysThisWeek: 5,
        preparedThisWeek: true,
        lastReadDate: yesterday,
        ibsStreak: 2,
        otStreak: 1,
      ),
      MemberSummary(
        uid: 'user_grace',
        name: 'Grace Kim',
        email: 'grace@example.com',
        joinDate: now.subtract(const Duration(days: 30)),
        currentBook: 'Luke',
        currentChapter: 1,
        ibsDaysThisWeek: 1,
        otDaysThisWeek: 0,
        otTotalDaysThisWeek: 5,
        preparedThisWeek: false,
        lastReadDate: fourDaysAgo, // needs encouragement
        ibsStreak: 0,
        otStreak: 0,
      ),
      MemberSummary(
        uid: 'user_daniel',
        name: 'Daniel Tadesse',
        email: 'daniel@example.com',
        joinDate: now.subtract(const Duration(days: 20)),
        currentBook: 'Genesis',
        currentChapter: 12,
        ibsDaysThisWeek: 4,
        otDaysThisWeek: 4,
        otTotalDaysThisWeek: 5,
        preparedThisWeek: false,
        lastReadDate: twoDaysAgo,
        ibsStreak: 4,
        otStreak: 4,
      ),
      MemberSummary(
        uid: 'user_miriam',
        name: 'Miriam Alemu',
        email: 'miriam@example.com',
        joinDate: now.subtract(const Duration(days: 90)),
        currentBook: 'Psalms',
        currentChapter: 23,
        ibsDaysThisWeek: 0,
        otDaysThisWeek: 0,
        otTotalDaysThisWeek: 5,
        preparedThisWeek: false,
        lastReadDate: null, // needs encouragement
        ibsStreak: 0,
        otStreak: 0,
      ),
    ];
  }

  static StudyWeek _defaultTeamWeek() {
    return StudyWeek(
      id: 'week_seed',
      book: 'Matthew',
      chapter: 5,
      verseFrom: 1,
      verseTo: 8,
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    );
  }

  static String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Future<List<MemberSummary>> getMembers({
    required String currentTeamWeekId,
    required List<String> currentOtWeekDates,
  }) async {
    return List.unmodifiable(_members);
  }

  @override
  Future<List<ReadingEntry>> getMemberIbsHistory(String uid) async {
    // Return seeded or an empty list
    return _ibsHistories[uid] ?? [];
  }

  @override
  Future<List<String>> getMemberOtHistory(String uid) async {
    return _otHistories[uid] ?? [];
  }

  @override
  Future<Map<String, bool>> getMemberTeamHistory(String uid) async {
    return _teamHistories[uid] ?? {};
  }

  @override
  Future<StudyWeek?> getCurrentTeamWeek() async {
    return _currentTeamWeek;
  }

  /// Exposed for test seeding.
  void seedMemberHistory({
    required String uid,
    List<ReadingEntry>? ibsHistory,
    List<String>? otDates,
    Map<String, bool>? teamPrep,
  }) {
    if (ibsHistory != null) _ibsHistories[uid] = ibsHistory;
    if (otDates != null) _otHistories[uid] = otDates;
    if (teamPrep != null) _teamHistories[uid] = teamPrep;
  }
}
