import '../data/bible_books.dart';
import 'ot_day.dart';

/// Pure shared function that computes the assigned [OtDay] for a [date] (yyyy-MM-dd)
/// given a plan's [book], [startChapter], and [startDate].
///
/// Returns an [OtDay] with the computed chapter, or `null` if [date] is before [startDate]
/// or if the computed chapter exceeds the total chapters of [book] (book finished).
OtDay? getOtChapterForDate({
  required String book,
  required int startChapter,
  required String startDate,
  required String date,
}) {
  if (book.isEmpty) return null;
  final s = DateTime.tryParse(startDate);
  final t = DateTime.tryParse(date);
  if (s == null || t == null) return null;

  final startDay = DateTime(s.year, s.month, s.day);
  final targetDay = DateTime(t.year, t.month, t.day);
  final diff = targetDay.difference(startDay).inDays;
  if (diff < 0) return null;

  final chapter = startChapter + diff;
  final totalChapters = BibleBooks.getChapterCount(book);
  if (chapter > totalChapters) return null;

  return OtDay(
    date: date,
    book: book,
    chapter: chapter,
  );
}

/// Pure shared function to check if an Old Testament book reading plan has ended
/// on or before [date] (yyyy-MM-dd).
bool isOtBookFinished({
  required String book,
  required int startChapter,
  required String startDate,
  required String date,
}) {
  if (book.isEmpty) return false;
  final s = DateTime.tryParse(startDate);
  final t = DateTime.tryParse(date);
  if (s == null || t == null) return false;

  final startDay = DateTime(s.year, s.month, s.day);
  final targetDay = DateTime(t.year, t.month, t.day);
  final diff = targetDay.difference(startDay).inDays;
  if (diff < 0) return false;

  final chapter = startChapter + diff;
  final totalChapters = BibleBooks.getChapterCount(book);
  return chapter > totalChapters;
}

/// Generates the list of [OtDay]s for a given week (Monday through Sunday)
/// using [getOtChapterForDate]. Defaults to the week of [referenceDate] (or now).
List<OtDay> computeOtDaysForWeek({
  required String book,
  required int startChapter,
  required String startDate,
  DateTime? referenceDate,
}) {
  final now = referenceDate ?? DateTime.now();
  final d = DateTime(now.year, now.month, now.day);
  final daysFromMonday = (d.weekday - DateTime.monday) % 7;
  final monday = d.subtract(Duration(days: daysFromMonday));

  final list = <OtDay>[];
  for (int i = 0; i < 7; i++) {
    final cur = monday.add(Duration(days: i));
    final dateStr =
        '${cur.year}-${cur.month.toString().padLeft(2, '0')}-${cur.day.toString().padLeft(2, '0')}';
    final day = getOtChapterForDate(
      book: book,
      startChapter: startChapter,
      startDate: startDate,
      date: dateStr,
    );
    if (day != null) {
      list.add(day);
    }
  }
  return list;
}

/// Represents an Old Testament study plan curated by leaders.
class OtWeek {
  final String id;
  final String topic;
  /// The start date in yyyy-MM-dd format.
  final String startDate;
  final DateTime publishedAt;
  final String updatedBy;
  /// Loaded or computed days for this week.
  final List<OtDay> days;

  /// Old Testament book for one-chapter-per-day plans (optional for legacy weeks).
  final String? book;

  /// Starting chapter number (default 1).
  final int? startChapter;

  const OtWeek({
    required this.id,
    this.topic = '',
    required this.startDate,
    required this.publishedAt,
    this.updatedBy = '',
    this.days = const [],
    this.book,
    this.startChapter,
  });

  bool get isChapterPerDay => book != null && book!.isNotEmpty;

  /// Returns the assigned [OtDay] for [dateStr] (yyyy-MM-dd).
  /// Uses the shared function [getOtChapterForDate] if [isChapterPerDay],
  /// or falls back to explicit [days] for legacy plans.
  OtDay? getDayForDate(String dateStr) {
    if (isChapterPerDay) {
      return getOtChapterForDate(
        book: book!,
        startChapter: startChapter ?? 1,
        startDate: startDate,
        date: dateStr,
      );
    }
    try {
      return days.firstWhere((d) => d.date == dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if the book has finished on or before [dateStr] (defaults to today).
  bool isBookFinished([String? dateStr]) {
    if (!isChapterPerDay) return false;
    final target = dateStr ?? _todayDateString();
    return isOtBookFinished(
      book: book!,
      startChapter: startChapter ?? 1,
      startDate: startDate,
      date: target,
    );
  }

  static String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'startDate': startDate,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
    if (topic.isNotEmpty) {
      map['topic'] = topic;
    }
    if (book != null && book!.isNotEmpty) {
      map['book'] = book;
    }
    if (startChapter != null) {
      map['startChapter'] = startChapter;
    }
    return map;
  }

  factory OtWeek.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<OtDay> days = const [],
  }) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final book = map['book'] as String?;
    final startChapter = (map['startChapter'] as num?)?.toInt();
    final startDate = map['startDate'] as String? ?? '';

    List<OtDay> effectiveDays = days;
    if (effectiveDays.isEmpty && book != null && book.isNotEmpty) {
      DateTime ref = DateTime.now();
      final startDt = DateTime.tryParse(startDate);
      if (startDt != null && startDt.isAfter(ref)) {
        ref = startDt;
      }
      effectiveDays = computeOtDaysForWeek(
        book: book,
        startChapter: startChapter ?? 1,
        startDate: startDate,
        referenceDate: ref,
      );
    }

    return OtWeek(
      id: id,
      topic: map['topic'] as String? ?? '',
      startDate: startDate,
      publishedAt: parseDate(map['publishedAt']),
      updatedBy: map['updatedBy'] as String? ?? '',
      days: effectiveDays,
      book: book,
      startChapter: startChapter,
    );
  }

  OtWeek copyWith({
    String? id,
    String? topic,
    String? startDate,
    DateTime? publishedAt,
    String? updatedBy,
    List<OtDay>? days,
    String? book,
    int? startChapter,
  }) {
    return OtWeek(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      startDate: startDate ?? this.startDate,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      days: days ?? this.days,
      book: book ?? this.book,
      startChapter: startChapter ?? this.startChapter,
    );
  }
}
