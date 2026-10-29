import '../models/reading_entry.dart';

/// Abstract repository interface for Bible study progress and reading history.
abstract class StudyRepository {
  /// Updates the user's currently active book, chapter, and verse immediately.
  Future<void> updateCurrentStudy({
    required String uid,
    required String book,
    required int chapter,
    required int verse,
  });

  /// Updates the user's reminder time setting.
  Future<void> updateReminderTime({
    required String uid,
    required String reminderTime,
  });

  /// Gets the reading entry for a specific [date] (format 'yyyy-MM-dd').
  Future<ReadingEntry?> getReadingForDate({
    required String uid,
    required String date,
  });

  /// Saves or updates a daily reading entry under `users/{uid}/readings/{date}`.
  Future<void> saveReading({
    required String uid,
    required ReadingEntry entry,
  });

  /// Retrieves the history of readings, newest first.
  Future<List<ReadingEntry>> getReadingHistory({
    required String uid,
  });
}
