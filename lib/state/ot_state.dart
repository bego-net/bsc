import 'package:flutter/foundation.dart';

import '../models/ot_day.dart';
import '../models/ot_member_overview_item.dart';
import '../models/ot_week.dart';
import '../repositories/ot_repository.dart';
import '../services/notification_service.dart';

/// State management for the Old Testament tab.
class OtState extends ChangeNotifier {
  final OtRepository _repo;
  final String? _uid;
  final bool _isAdmin;
  final String _reminderTime;
  final NotificationService _notificationService;

  OtWeek? _currentWeek;
  List<OtDay> _days = [];
  Map<String, bool> _readings = {};
  int _streak = 0;
  bool _remindersEnabled = true;
  bool _isLoading = false;
  String? _errorMessage;

  List<OtWeek> _history = [];
  List<OtMemberOverviewItem> _overview = [];
  bool _historyLoading = false;
  bool _overviewLoading = false;

  bool _disposed = false;

  OtState({
    required OtRepository repository,
    required this._uid,
    required this._isAdmin,
    this._reminderTime = '07:00',
    required this._notificationService,
  }) : _repo = repository;

  // ── Getters ─────────────────────────────────────────────────────────────────

  OtWeek? get currentWeek => _currentWeek;
  List<OtDay> get days => List.unmodifiable(_days);
  Map<String, bool> get readings => Map.unmodifiable(_readings);
  int get streak => _streak;
  bool get remindersEnabled => _remindersEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _isAdmin;
  String? get uid => _uid;

  List<OtWeek> get history => List.unmodifiable(_history);
  List<OtMemberOverviewItem> get overview => List.unmodifiable(_overview);
  bool get historyLoading => _historyLoading;
  bool get overviewLoading => _overviewLoading;

  int get completedDaysCount {
    int count = 0;
    for (final day in _days) {
      if (_readings[day.date] == true) {
        count++;
      }
    }
    return count;
  }

  int get totalDaysCount => _days.length;

  double get progressFraction =>
      totalDaysCount > 0 ? (completedDaysCount / totalDaysCount).clamp(0.0, 1.0) : 0.0;

  String get progressText => '$completedDaysCount of $totalDaysCount readings done';

  /// Today's date formatted as yyyy-MM-dd.
  static String get todayDateString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Today's assigned [OtDay] computed by the shared function.
  OtDay? get todayDay {
    if (_currentWeek == null) return null;
    return _currentWeek!.getDayForDate(todayDateString);
  }

  /// Whether the current book reading plan has ended.
  bool get isBookFinished => _currentWeek?.isBookFinished() ?? false;

  bool get isTodayCompleted {
    return _readings[todayDateString] == true;
  }

  /// Members can mark today and earlier days of the current week (catch-up),
  /// but NOT future days (future days are locked).
  bool canMarkDate(String dateStr) {
    final today = todayDateString;
    // Cannot mark dates in the future
    if (dateStr.compareTo(today) > 0) {
      return false;
    }
    if (_currentWeek == null) return false;
    // Must be a day with assigned reading from the shared function (or legacy days)
    return _currentWeek!.getDayForDate(dateStr) != null;
  }

  bool isFutureDay(String dateStr) {
    final today = todayDateString;
    return dateStr.compareTo(today) > 0;
  }

  // ── Data Loading ─────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    if (_disposed) return;
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      _currentWeek = await _repo.getCurrentWeek();

      final week = _currentWeek;
      if (week != null) {
        _days = week.days.isNotEmpty
            ? week.days
            : await _repo.getDaysForWeek(week.id);

        if (_uid != null) {
          final dates = _days.map((d) => d.date).toList();
          _readings = await _repo.getUserReadingsForWeek(
            uid: _uid,
            weekId: week.id,
            dates: dates,
          );
          _streak = await _repo.getUserStreak(_uid);
          _remindersEnabled = await _repo.getOtRemindersEnabled(_uid);
        }

        // Schedule daily reminders on days with assigned reading
        await _notificationService.scheduleOtReminders(
          week: week.copyWith(days: _days),
          reminderTime: _reminderTime,
          enabled: _remindersEnabled,
        );
      } else {
        _days = [];
        _readings = {};
        _streak = 0;
      }
    } catch (e) {
      _errorMessage = 'Could not load Old Testament data.';
      debugPrint('[OtState] loadData error: $e');
    }

    if (_disposed) return;
    _isLoading = false;
    _safeNotify();
  }

  // ── Reading Toggle (Catch-up / Mark read) ────────────────────────────────────

  Future<void> toggleDay(String dateStr) async {
    if (_currentWeek == null || _uid == null) return;
    if (!canMarkDate(dateStr)) return;

    final current = _readings[dateStr] ?? false;
    final next = !current;

    _readings = {..._readings, dateStr: next};
    _safeNotify();

    try {
      await _repo.setDayCompleted(
        uid: _uid,
        weekId: _currentWeek!.id,
        date: dateStr,
        completed: next,
      );
      // Refresh streak
      _streak = await _repo.getUserStreak(_uid);
      _safeNotify();
    } catch (e) {
      // Revert on error
      _readings = {..._readings, dateStr: current};
      _errorMessage = 'Could not update reading status.';
      _safeNotify();
      debugPrint('[OtState] toggleDay error: $e');
    }
  }

  // ── Reminders Toggle ────────────────────────────────────────────────────────

  Future<void> setRemindersEnabled(bool enabled) async {
    _remindersEnabled = enabled;
    _safeNotify();

    if (_uid != null) {
      try {
        await _repo.setOtRemindersEnabled(uid: _uid, enabled: enabled);
      } catch (e) {
        debugPrint('[OtState] setRemindersEnabled error: $e');
      }
    }

    if (_currentWeek != null) {
      await _notificationService.scheduleOtReminders(
        week: _currentWeek!.copyWith(days: _days),
        reminderTime: _reminderTime,
        enabled: enabled,
      );
    }
  }

  // ── History & Overview ──────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    if (_disposed) return;
    _historyLoading = true;
    _safeNotify();

    try {
      _history = await _repo.getWeekHistory();
    } catch (e) {
      debugPrint('[OtState] loadHistory error: $e');
    }

    if (_disposed) return;
    _historyLoading = false;
    _safeNotify();
  }

  Future<void> loadOverview() async {
    if (_disposed || !_isAdmin || _currentWeek == null) return;
    _overviewLoading = true;
    _safeNotify();

    try {
      final dates = _days.map((d) => d.date).toList();
      _overview = await _repo.getMemberOverview(_currentWeek!.id, dates);
    } catch (e) {
      debugPrint('[OtState] loadOverview error: $e');
    }

    if (_disposed) return;
    _overviewLoading = false;
    _safeNotify();
  }

  // ── Admin Actions ─────────────────────────────────────────────────────────────

  Future<OtWeek?> publishWeek({
    String topic = '',
    required String startDate,
    List<OtDay> days = const [],
    String? book,
    int? startChapter,
  }) async {
    if (!_isAdmin || _uid == null) return null;

    try {
      final published = await _repo.publishWeek(
        topic: topic,
        startDate: startDate,
        days: days,
        updatedBy: _uid,
        book: book,
        startChapter: startChapter,
      );

      _currentWeek = published;
      _days = published.days;
      _readings = {for (final d in _days) d.date: false};

      await _notificationService.scheduleOtReminders(
        week: published,
        reminderTime: _reminderTime,
        enabled: _remindersEnabled,
      );

      _safeNotify();
      return published;
    } catch (e) {
      _errorMessage = 'Could not publish Old Testament week.';
      _safeNotify();
      debugPrint('[OtState] publishWeek error: $e');
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
