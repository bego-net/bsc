import '../data/bible_books.dart';

/// Represents a weekly group Bible study session and assignment.
class StudyWeek {
  final String id;
  final String book;
  final int chapter;
  final int verseFrom;
  final int verseTo;
  final String sessionDay; // e.g., 'Friday'
  final String sessionTime; // e.g., '6:00 PM'
  final String place; // e.g., 'Church hall'
  final String thursdayReminderTime; // e.g., '18:00' or '6:00 PM'
  final DateTime publishedAt;
  final String updatedBy;

  const StudyWeek({
    required this.id,
    this.book = 'Matthew',
    this.chapter = 5,
    this.verseFrom = 1,
    this.verseTo = 8,
    this.sessionDay = 'Friday',
    this.sessionTime = '6:00 PM',
    this.place = 'Church hall',
    this.thursdayReminderTime = '18:00',
    required this.publishedAt,
    this.updatedBy = '',
  });

  /// Formatted verse string, e.g. "3" or "1-8".
  String get verseRangeText =>
      verseFrom == verseTo ? '$verseFrom' : '$verseFrom-$verseTo';

  /// Complete passage reference, e.g. "Matthew 5:1-8" or "Matthew 5:3".
  String get passageText => '$book $chapter:$verseRangeText';

  /// Complete passage reference localized to [languageCode] (e.g., "ማቴዎስ 5:1-8").
  String localizedPassageText([String languageCode = 'am']) {
    final localizedBook = BibleBooks.getLocalizedName(book, languageCode);
    return '$localizedBook $chapter:$verseRangeText';
  }

  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verseFrom': verseFrom,
      'verseTo': verseTo,
      'sessionDay': sessionDay,
      'sessionTime': sessionTime,
      'place': place,
      'thursdayReminderTime': thursdayReminderTime,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory StudyWeek.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final vFrom = (map['verseFrom'] as num?)?.toInt() ?? 1;
    final vTo = (map['verseTo'] as num?)?.toInt() ?? vFrom;

    return StudyWeek(
      id: id,
      book: map['book'] as String? ?? 'Matthew',
      chapter: (map['chapter'] as num?)?.toInt() ?? 1,
      verseFrom: vFrom,
      verseTo: vTo,
      sessionDay: map['sessionDay'] as String? ?? 'Friday',
      sessionTime: map['sessionTime'] as String? ?? '6:00 PM',
      place: map['place'] as String? ?? 'Church hall',
      thursdayReminderTime: map['thursdayReminderTime'] as String? ?? '18:00',
      publishedAt: parseDate(map['publishedAt']),
      updatedBy: map['updatedBy'] as String? ?? '',
    );
  }

  StudyWeek copyWith({
    String? id,
    String? book,
    int? chapter,
    int? verseFrom,
    int? verseTo,
    String? sessionDay,
    String? sessionTime,
    String? place,
    String? thursdayReminderTime,
    DateTime? publishedAt,
    String? updatedBy,
  }) {
    return StudyWeek(
      id: id ?? this.id,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseFrom: verseFrom ?? this.verseFrom,
      verseTo: verseTo ?? this.verseTo,
      sessionDay: sessionDay ?? this.sessionDay,
      sessionTime: sessionTime ?? this.sessionTime,
      place: place ?? this.place,
      thursdayReminderTime: thursdayReminderTime ?? this.thursdayReminderTime,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
