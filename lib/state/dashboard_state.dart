import 'package:flutter/foundation.dart';

import '../models/member_summary.dart';
import '../models/study_week.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/ot_repository.dart';

/// Sort options for the members list.
enum MemberSort { name, lastActive, mostActive }

/// Manages dashboard data: members list, home stats, and member details.
/// Admin only — never instantiated for members.
class DashboardState extends ChangeNotifier {
  final DashboardRepository _repo;
  final OtRepository _otRepo;

  List<MemberSummary> _members = [];
  StudyWeek? _currentTeamWeek;
  String _otTopic = '';
  List<String> _currentOtWeekDates = [];

  bool _isLoading = false;
  String? _error;

  // Cache invalidation: refresh only if stale (> 2 minutes since last fetch)
  DateTime? _lastFetched;
  static const _cacheDuration = Duration(minutes: 2);

  // Detail-screen per-member data (loaded on demand)
  final Map<String, MemberSummary> _detailCache = {};

  // Members list state
  String _searchQuery = '';
  MemberSort _sort = MemberSort.name;
  bool _filterNeedsEncouragement = false;

  DashboardState({
    required DashboardRepository repository,
    required OtRepository otRepository,
  })  : _repo = repository,
        _otRepo = otRepository;

  // ─── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  StudyWeek? get currentTeamWeek => _currentTeamWeek;
  String get otTopic => _otTopic;

  String get searchQuery => _searchQuery;
  MemberSort get sort => _sort;
  bool get filterNeedsEncouragement => _filterNeedsEncouragement;

  List<MemberSummary> get allMembers => _members;

  /// Filtered + sorted member list for the members-list screen.
  List<MemberSummary> get filteredMembers {
    var list = _members.where((m) {
      if (_filterNeedsEncouragement && !m.needsEncouragement) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case MemberSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case MemberSort.lastActive:
        list.sort((a, b) {
          final aDate = a.lastReadDate ?? '';
          final bDate = b.lastReadDate ?? '';
          return bDate.compareTo(aDate);
        });
      case MemberSort.mostActive:
        list.sort((a, b) =>
            (b.ibsDaysThisWeek + b.otDaysThisWeek)
                .compareTo(a.ibsDaysThisWeek + a.otDaysThisWeek));
    }
    return list;
  }

  // ─── Home card stats ────────────────────────────────────────────────────────

  int get totalMembers => _members.length;

  int get activeThisWeek => _members
      .where((m) => m.ibsDaysThisWeek > 0 || m.otDaysThisWeek > 0)
      .length;

  double get avgIbsDaysThisWeek {
    if (_members.isEmpty) return 0;
    final total = _members.fold<int>(0, (s, m) => s + m.ibsDaysThisWeek);
    return total / _members.length;
  }

  int get readTodayCount {
    final today =
        DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    return _members.where((m) => m.lastReadDate == today).length;
  }

  int get preparedCount => _members.where((m) => m.preparedThisWeek).length;

  double get avgOtDaysThisWeek {
    if (_members.isEmpty) return 0;
    final total = _members.fold<int>(0, (s, m) => s + m.otDaysThisWeek);
    return total / _members.length;
  }

  List<MemberSummary> get needsEncouragementList =>
      _members.where((m) => m.needsEncouragement).toList();

  // ─── Actions ────────────────────────────────────────────────────────────────

  /// Loads members, team week, and OT week. Respects 2-min cache.
  Future<void> load({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastFetched != null &&
        now.difference(_lastFetched!) < _cacheDuration) {
      return; // still fresh
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load OT and team weeks
      final otWeek = await _otRepo.getCurrentWeek();
      _currentTeamWeek = await _repo.getCurrentTeamWeek();

      if (otWeek != null) {
        _otTopic = otWeek.topic;
        _currentOtWeekDates = otWeek.days.map((d) => d.date).toList();
      }

      final teamWeekId = _currentTeamWeek?.id ?? '';
      _members = await _repo.getMembers(
        currentTeamWeekId: teamWeekId,
        currentOtWeekDates: _currentOtWeekDates,
      );

      _lastFetched = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads full 30-day detail for one member. Cached.
  Future<MemberSummary> loadMemberDetail(String uid) async {
    // Return cached if available
    if (_detailCache.containsKey(uid)) {
      return _detailCache[uid]!;
    }

    final base = _members.firstWhere(
      (m) => m.uid == uid,
      orElse: () => MemberSummary(
        uid: uid,
        name: '',
        email: '',
        joinDate: DateTime.now(),
      ),
    );

    try {
      final ibsHistory = await _repo.getMemberIbsHistory(uid);
      final otHistory = await _repo.getMemberOtHistory(uid);
      final teamHistory = await _repo.getMemberTeamHistory(uid);

      final detail = base.copyWith(
        ibsHistory: ibsHistory,
        otReadingDates: otHistory,
        teamPrepHistory: teamHistory,
      );
      _detailCache[uid] = detail;
      notifyListeners();
      return detail;
    } catch (_) {
      return base;
    }
  }

  /// Updates search query.
  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  /// Updates sort.
  void setSort(MemberSort s) {
    _sort = s;
    notifyListeners();
  }

  /// Toggles "Needs encouragement" filter.
  void toggleNeedsEncouragementFilter() {
    _filterNeedsEncouragement = !_filterNeedsEncouragement;
    notifyListeners();
  }

  /// Pull-to-refresh: force reload.
  Future<void> refresh() => load(forceRefresh: true);

  /// Clears cached detail for a member (unused but available for future use).
  void clearDetailCache(String uid) {
    _detailCache.remove(uid);
  }
}
