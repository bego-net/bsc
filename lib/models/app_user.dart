/// Represents a user profile in the application.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'member' or 'admin'
  final DateTime createdAt;
  final String currentBook;
  final int currentChapter;
  final int verseFrom;
  final int verseTo;
  final String reminderTime; // e.g., '07:00'

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'member',
    required this.createdAt,
    this.currentBook = 'John',
    this.currentChapter = 1,
    int? currentVerse,
    int? verseFrom,
    int? verseTo,
    this.reminderTime = '07:00',
  })  : verseFrom = verseFrom ?? currentVerse ?? 1,
        verseTo = verseTo ?? currentVerse ?? verseFrom ?? 1;

  /// Backward-compatible alias for [verseFrom].
  int get currentVerse => verseFrom;

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'currentBook': currentBook,
      'currentChapter': currentChapter,
      'currentVerse': verseFrom,
      'verseFrom': verseFrom,
      'verseTo': verseTo,
      'reminderTime': reminderTime,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final legacyVerse = (map['currentVerse'] as num?)?.toInt() ?? 1;
    final vFrom = (map['verseFrom'] as num?)?.toInt() ?? legacyVerse;
    final vTo = (map['verseTo'] as num?)?.toInt() ?? vFrom;

    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      createdAt: parseDate(map['createdAt']),
      currentBook: map['currentBook'] as String? ?? 'John',
      currentChapter: (map['currentChapter'] as num?)?.toInt() ?? 1,
      verseFrom: vFrom,
      verseTo: vTo,
      reminderTime: map['reminderTime'] as String? ?? '07:00',
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    String? currentBook,
    int? currentChapter,
    int? currentVerse,
    int? verseFrom,
    int? verseTo,
    String? reminderTime,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      currentBook: currentBook ?? this.currentBook,
      currentChapter: currentChapter ?? this.currentChapter,
      verseFrom: verseFrom ?? currentVerse ?? this.verseFrom,
      verseTo: verseTo ?? currentVerse ?? this.verseTo,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
