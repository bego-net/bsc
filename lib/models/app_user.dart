/// Represents a user profile in the application.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'member' or 'admin'
  final DateTime createdAt;
  final String currentBook;
  final int currentChapter;
  final int currentVerse;
  final String reminderTime; // e.g., '07:00'

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'member',
    required this.createdAt,
    this.currentBook = 'John',
    this.currentChapter = 1,
    this.currentVerse = 1,
    this.reminderTime = '07:00',
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'currentBook': currentBook,
      'currentChapter': currentChapter,
      'currentVerse': currentVerse,
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

    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      createdAt: parseDate(map['createdAt']),
      currentBook: map['currentBook'] as String? ?? 'John',
      currentChapter: (map['currentChapter'] as num?)?.toInt() ?? 1,
      currentVerse: (map['currentVerse'] as num?)?.toInt() ?? 1,
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
      currentVerse: currentVerse ?? this.currentVerse,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
