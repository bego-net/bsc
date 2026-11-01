import 'package:intl/intl.dart';

import '../data/bible_books.dart';

/// Represents a daily Old Testament assigned reading for a week.
class OtDay {
  /// The date string in yyyy-MM-dd format.
  final String date;
  final String book;
  final int chapter;
  final int? verseFrom;
  final int? verseTo;

  const OtDay({
    required this.date,
    required this.book,
    required this.chapter,
    this.verseFrom,
    this.verseTo,
  });

  /// Formatted passage string, e.g.:
  /// - "Genesis 12" (whole chapter)
  /// - "Psalms 23:1" (single verse)
  /// - "Psalms 23:1-6" (verse range)
  /// Formatted passage string localized to [languageCode].
  String localizedPassageText([String languageCode = 'am']) {
    final localizedBook = BibleBooks.getLocalizedName(book, languageCode);
    if (verseFrom == null && verseTo == null) {
      return '$localizedBook $chapter';
    }
    final from = verseFrom;
    final to = verseTo ?? from;
    if (from == null) {
      return '$localizedBook $chapter';
    }
    if (from == to) {
      return '$localizedBook $chapter:$from';
    }
    return '$localizedBook $chapter:$from-$to';
  }

  /// Day of week display name localized to [languageCode] (e.g., ሰኞ or Monday).
  String localizedDayName([String languageCode = 'am']) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('EEEE', languageCode).format(dt);
    } catch (_) {
      return dayName;
    }
  }

  String get passageText {
    if (verseFrom == null && verseTo == null) {
      return '$book $chapter';
    }
    final from = verseFrom;
    final to = verseTo ?? from;
    if (from == null) {
      return '$book $chapter';
    }
    if (from == to) {
      return '$book $chapter:$from';
    }
    return '$book $chapter:$from-$to';
  }

  /// Day of week display name (e.g., 'Monday', 'Tuesday').
  String get dayName {
    try {
      final dt = DateTime.parse(date);
      switch (dt.weekday) {
        case DateTime.monday:
          return 'Monday';
        case DateTime.tuesday:
          return 'Tuesday';
        case DateTime.wednesday:
          return 'Wednesday';
        case DateTime.thursday:
          return 'Thursday';
        case DateTime.friday:
          return 'Friday';
        case DateTime.saturday:
          return 'Saturday';
        case DateTime.sunday:
          return 'Sunday';
        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verseFrom': verseFrom,
      'verseTo': verseTo,
    };
  }

  factory OtDay.fromMap(String date, Map<String, dynamic> map) {
    return OtDay(
      date: date,
      book: map['book'] as String? ?? 'Genesis',
      chapter: (map['chapter'] as num?)?.toInt() ?? 1,
      verseFrom: (map['verseFrom'] as num?)?.toInt(),
      verseTo: (map['verseTo'] as num?)?.toInt(),
    );
  }

  OtDay copyWith({
    String? date,
    String? book,
    int? chapter,
    int? verseFrom,
    int? verseTo,
  }) {
    return OtDay(
      date: date ?? this.date,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseFrom: verseFrom ?? this.verseFrom,
      verseTo: verseTo ?? this.verseTo,
    );
  }
}
