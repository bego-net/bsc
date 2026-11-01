import '../data/bible_books.dart';

/// Represents a daily reading log entry for a member.
class ReadingEntry {
  /// The date key in format 'yyyy-MM-dd'.
  final String date;
  final String book;
  final int chapter;
  final int verseFrom;
  final int verseTo;
  final bool completed;
  final DateTime updatedAt;

  const ReadingEntry({
    required this.date,
    required this.book,
    required this.chapter,
    int? verse,
    int? verseFrom,
    int? verseTo,
    required this.completed,
    required this.updatedAt,
  })  : verseFrom = verseFrom ?? verse ?? 1,
        verseTo = verseTo ?? verse ?? verseFrom ?? 1;

  /// Backward-compatible alias for [verseFrom].
  int get verse => verseFrom;

  /// Formatted verse string, e.g. "3" or "1-8".
  String get verseRangeText =>
      verseFrom == verseTo ? '$verseFrom' : '$verseFrom-$verseTo';

  /// Complete reference text, e.g. "Matthew 5:1-8" or "Matthew 5:3".
  String get referenceText => '$book $chapter:$verseRangeText';

  /// Complete reference text localized to [languageCode] (e.g., "ዮሐንስ 3:1-8").
  String localizedReferenceText([String languageCode = 'am']) {
    final localizedBook = BibleBooks.getLocalizedName(book, languageCode);
    return '$localizedBook $chapter:$verseRangeText';
  }

  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verseFrom,
      'verseFrom': verseFrom,
      'verseTo': verseTo,
      'completed': completed,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReadingEntry.fromMap(String date, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final legacyVerse = (map['verse'] as num?)?.toInt() ?? 1;
    final vFrom = (map['verseFrom'] as num?)?.toInt() ?? legacyVerse;
    final vTo = (map['verseTo'] as num?)?.toInt() ?? vFrom;

    return ReadingEntry(
      date: date,
      book: map['book'] as String? ?? 'John',
      chapter: (map['chapter'] as num?)?.toInt() ?? 1,
      verseFrom: vFrom,
      verseTo: vTo,
      completed: map['completed'] as bool? ?? false,
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  ReadingEntry copyWith({
    String? date,
    String? book,
    int? chapter,
    int? verse,
    int? verseFrom,
    int? verseTo,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return ReadingEntry(
      date: date ?? this.date,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseFrom: verseFrom ?? verse ?? this.verseFrom,
      verseTo: verseTo ?? verse ?? this.verseTo,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
