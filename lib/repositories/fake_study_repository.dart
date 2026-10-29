import '../models/reading_entry.dart';
import 'study_repository.dart';

/// In-memory implementation of [StudyRepository] for testing and offline development.
class FakeStudyRepository implements StudyRepository {
  /// Map of `uid` to Map of `date` -> [ReadingEntry].
  final Map<String, Map<String, ReadingEntry>> _readings = {};

  /// User current studies: `uid` -> Map of field values.
  final Map<String, Map<String, dynamic>> _userProfiles = {};

  @override
  Future<void> updateCurrentStudy({
    required String uid,
    required String book,
    required int chapter,
    int? verse,
    int? verseFrom,
    int? verseTo,
  }) async {
    final vFrom = verseFrom ?? verse ?? 1;
    final vTo = verseTo ?? verse ?? vFrom;
    final profile = _userProfiles.putIfAbsent(uid, () => {});
    profile['currentBook'] = book;
    profile['currentChapter'] = chapter;
    profile['currentVerse'] = vFrom;
    profile['verseFrom'] = vFrom;
    profile['verseTo'] = vTo;
  }

  @override
  Future<void> updateReminderTime({
    required String uid,
    required String reminderTime,
  }) async {
    final profile = _userProfiles.putIfAbsent(uid, () => {});
    profile['reminderTime'] = reminderTime;
  }

  @override
  Future<ReadingEntry?> getReadingForDate({
    required String uid,
    required String date,
  }) async {
    return _readings[uid]?[date];
  }

  @override
  Future<void> saveReading({
    required String uid,
    required ReadingEntry entry,
  }) async {
    final userReadings = _readings.putIfAbsent(uid, () => {});
    userReadings[entry.date] = entry;
  }

  @override
  Future<List<ReadingEntry>> getReadingHistory({
    required String uid,
  }) async {
    final userReadings = _readings[uid]?.values.toList() ?? [];
    // Sort newest date first
    userReadings.sort((a, b) => b.date.compareTo(a.date));
    return List<ReadingEntry>.from(userReadings);
  }
}
