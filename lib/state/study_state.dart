import 'package:flutter/material.dart';

import '../data/bible_books.dart';
import '../models/app_user.dart';
import '../models/reading_entry.dart';
import '../repositories/study_repository.dart';

/// Manages Bible study state for the active user, including current portion,
/// today's reading completion, streak counting, reading history, and reminders.
class StudyState extends ChangeNotifier {
  final StudyRepository _repo;
  DateTime Function() _now;

  String? _uid;
  String _currentBook = 'John';
  int _currentChapter = 1;
  int _verseFrom = 1;
  int _verseTo = 1;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  ReadingEntry? _todayReading;
  List<ReadingEntry> _history = [];
  bool _isLoading = false;
  Future<void>? _pendingLoad;

  StudyState({
    required StudyRepository repository,
    String? uid,
    AppUser? initialUser,
    DateTime Function()? now,
  })  : _repo = repository,
        _uid = uid ?? initialUser?.uid,
        _now = now ?? DateTime.now {
    if (initialUser != null) {
      _applyUser(initialUser);
    }
    if (_uid != null) {
      loadUserData();
    }
  }

  // --- Getters ---

  String? get uid => _uid;
  String get currentBook => _currentBook;
  int get currentChapter => _currentChapter;
  int get verseFrom => _verseFrom;
  int get verseTo => _verseTo;
  int get currentVerse => _verseFrom;
  String get verseRangeText =>
      _verseFrom == _verseTo ? '$_verseFrom' : '$_verseFrom-$_verseTo';
  String get currentReferenceText =>
      '$_currentBook $_currentChapter:$verseRangeText';
  int get maxChapters => BibleBooks.getChapterCount(_currentBook);
  TimeOfDay get reminderTime => _reminderTime;
  ReadingEntry? get todayReading => _todayReading;
  bool get isReadToday => _todayReading?.completed ?? false;
  List<ReadingEntry> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  DateTime get currentDate => _now();

  /// Today's date formatted as 'yyyy-MM-dd'.
  String get todayDateKey => formatDate(currentDate);

  /// Number of consecutive days with marked study readings.
  int get streak => calculateStreak(currentDate);

  // --- Configuration & Initialization ---

  /// Sets or updates the active user context.
  void setUser(AppUser? user) {
    if (user == null) {
      _uid = null;
      _todayReading = null;
      _history = [];
      _pendingLoad = null;
      notifyListeners();
      return;
    }

    _uid = user.uid;
    _applyUser(user);
    loadUserData();
  }

  void _applyUser(AppUser user) {
    _currentBook = user.currentBook;
    _currentChapter = user.currentChapter;
    _verseFrom = user.verseFrom;
    _verseTo = user.verseTo < user.verseFrom ? user.verseFrom : user.verseTo;
    _reminderTime = _parseReminderTime(user.reminderTime);
    notifyListeners();
  }

  /// Sets a custom date provider (useful for testing date transitions).
  void setNowProvider(DateTime Function() nowProvider) {
    _now = nowProvider;
    notifyListeners();
  }

  /// Fetches today's reading status and user reading history from the repository.
  Future<void> loadUserData() async {
    if (_uid == null) return;
    _isLoading = true;
    notifyListeners();

    final targetUid = _uid;
    final future = () async {
      try {
        final dateKey = todayDateKey;
        final reading = await _repo.getReadingForDate(
          uid: targetUid!,
          date: dateKey,
        );
        final history = await _repo.getReadingHistory(uid: targetUid);
        if (_uid == targetUid) {
          _todayReading = reading;
          _history = List<ReadingEntry>.from(history);
        }
      } catch (e) {
        debugPrint('Error loading study data: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }();

    _pendingLoad = future;
    await future;
    if (_pendingLoad == future) {
      _pendingLoad = null;
    }
  }

  // --- Study Navigation ---

  /// Changes the current book and adjusts the chapter if it exceeds the new book's max chapters.
  Future<void> setBook(String newBook) async {
    if (_currentBook == newBook) return;

    _currentBook = newBook;
    final max = BibleBooks.getChapterCount(newBook);
    if (_currentChapter > max) {
      _currentChapter = max;
    }
    _verseFrom = 1;
    _verseTo = 1;
    notifyListeners();

    await _persistCurrentStudy();
  }

  /// Changes the current chapter (clamped between 1 and the book's chapter count).
  Future<void> setChapter(int chapter) async {
    final clamped = chapter.clamp(1, maxChapters);
    if (_currentChapter == clamped) return;

    _currentChapter = clamped;
    _verseFrom = 1;
    _verseTo = 1;
    notifyListeners();

    await _persistCurrentStudy();
  }

  /// Increments to the next chapter if within range.
  Future<void> nextChapter() async {
    if (_currentChapter < maxChapters) {
      await setChapter(_currentChapter + 1);
    }
  }

  /// Decrements to the previous chapter if within range.
  Future<void> previousChapter() async {
    if (_currentChapter > 1) {
      await setChapter(_currentChapter - 1);
    }
  }

  /// Changes the "from" verse (clamped between 1 and 176).
  /// If [from] is greater than current [_verseTo], [_verseTo] is advanced to match.
  Future<void> setVerseFrom(int from) async {
    final clamped = from.clamp(1, 176);
    if (_verseFrom == clamped && _verseTo >= clamped) return;

    _verseFrom = clamped;
    if (_verseTo < clamped) {
      _verseTo = clamped;
    }
    notifyListeners();

    await _persistCurrentStudy();
  }

  /// Changes the "to" verse (clamped between [_verseFrom] and 176).
  /// "To" can never be lower than "From".
  Future<void> setVerseTo(int to) async {
    final clamped = to.clamp(_verseFrom, 176);
    if (_verseTo == clamped) return;

    _verseTo = clamped;
    notifyListeners();

    await _persistCurrentStudy();
  }

  /// Sets both "from" and "to" verses, ensuring "to" >= "from".
  Future<void> setVerseRange(int from, int to) async {
    final clampedFrom = from.clamp(1, 176);
    final clampedTo = to < clampedFrom ? clampedFrom : to.clamp(1, 176);
    if (_verseFrom == clampedFrom && _verseTo == clampedTo) return;

    _verseFrom = clampedFrom;
    _verseTo = clampedTo;
    notifyListeners();

    await _persistCurrentStudy();
  }

  /// Increments "from" verse by 1 (max 176).
  Future<void> incrementVerseFrom() async {
    if (_verseFrom < 176) {
      await setVerseFrom(_verseFrom + 1);
    }
  }

  /// Decrements "from" verse by 1 (min 1).
  Future<void> decrementVerseFrom() async {
    if (_verseFrom > 1) {
      await setVerseFrom(_verseFrom - 1);
    }
  }

  /// Increments "to" verse by 1 (max 176).
  Future<void> incrementVerseTo() async {
    if (_verseTo < 176) {
      await setVerseTo(_verseTo + 1);
    }
  }

  /// Decrements "to" verse by 1 (never lower than [_verseFrom]).
  Future<void> decrementVerseTo() async {
    if (_verseTo > _verseFrom) {
      await setVerseTo(_verseTo - 1);
    }
  }

  /// Changes the current single verse (backward-compatible).
  Future<void> setVerse(int verse) async {
    await setVerseRange(verse, verse);
  }

  /// Increments the verse by 1 (backward-compatible).
  Future<void> incrementVerse() async {
    await incrementVerseFrom();
  }

  /// Decrements the verse by 1 (backward-compatible).
  Future<void> decrementVerse() async {
    await decrementVerseFrom();
  }

  // --- Mark Read & Undo ---

  /// Marks today as read, or undos today's reading if already marked.
  Future<void> toggleMarkToday() async {
    if (_uid == null) return;

    if (_pendingLoad != null) {
      await _pendingLoad;
    }
    if (_uid == null) return;

    final dateKey = todayDateKey;
    final currentlyCompleted = isReadToday;

    final entry = ReadingEntry(
      date: dateKey,
      book: _currentBook,
      chapter: _currentChapter,
      verseFrom: _verseFrom,
      verseTo: _verseTo,
      completed: !currentlyCompleted,
      updatedAt: DateTime.now(),
    );

    _todayReading = entry;

    // Update in-memory history
    final existingIndex = _history.indexWhere((e) => e.date == dateKey);
    if (existingIndex >= 0) {
      _history[existingIndex] = entry;
    } else {
      _history.insert(0, entry);
    }
    _history.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    await _repo.saveReading(uid: _uid!, entry: entry);
  }

  // --- Reminder Time ---

  /// Updates and persists the daily reminder time.
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    notifyListeners();

    if (_uid != null) {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      await _repo.updateReminderTime(
        uid: _uid!,
        reminderTime: formatted,
      );
    }
  }

  // --- Streak Calculation ---

  /// Calculates consecutive days with completed readings.
  /// If today is completed, streak counts backwards from today.
  /// If today is not completed, streak is preserved from yesterday.
  int calculateStreak(DateTime asOfDate) {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final todayKey = formatDate(today);

    // Build lookup set of dates that have completed readings
    final completedDates = <String>{};
    for (final entry in _history) {
      if (entry.completed) {
        completedDates.add(entry.date);
      }
    }
    if (_todayReading?.completed == true) {
      completedDates.add(todayKey);
    }

    final hasToday = completedDates.contains(todayKey);
    DateTime checkDate;

    if (hasToday) {
      checkDate = today;
    } else {
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final yesterdayKey = formatDate(yesterday);
      if (completedDates.contains(yesterdayKey)) {
        checkDate = yesterday;
      } else {
        return 0;
      }
    }

    int count = 0;
    while (true) {
      final key = formatDate(checkDate);
      if (completedDates.contains(key)) {
        count++;
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      } else {
        break;
      }
    }

    return count;
  }

  // --- Helpers ---

  Future<void> _persistCurrentStudy() async {
    if (_uid == null) return;
    await _repo.updateCurrentStudy(
      uid: _uid!,
      book: _currentBook,
      chapter: _currentChapter,
      verseFrom: _verseFrom,
      verseTo: _verseTo,
    );
  }

  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static TimeOfDay _parseReminderTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return const TimeOfDay(hour: 7, minute: 0);
  }
}
