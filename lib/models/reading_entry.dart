/// Represents a daily reading log entry for a member.
class ReadingEntry {
  /// The date key in format 'yyyy-MM-dd'.
  final String date;
  final String book;
  final int chapter;
  final int verse;
  final bool completed;
  final DateTime updatedAt;

  const ReadingEntry({
    required this.date,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.completed,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
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

    return ReadingEntry(
      date: date,
      book: map['book'] as String? ?? 'John',
      chapter: (map['chapter'] as num?)?.toInt() ?? 1,
      verse: (map['verse'] as num?)?.toInt() ?? 1,
      completed: map['completed'] as bool? ?? false,
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  ReadingEntry copyWith({
    String? date,
    String? book,
    int? chapter,
    int? verse,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return ReadingEntry(
      date: date ?? this.date,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
