/// Represents a Bible book and its chapter count.
class BibleBook {
  final String name;
  final int chapterCount;
  final String testament;

  const BibleBook({
    required this.name,
    required this.chapterCount,
    required this.testament,
  });
}

/// Catalog of all 66 Bible books in canonical order with chapter counts.
class BibleBooks {
  static const List<BibleBook> all = [
    // Old Testament (39 books)
    BibleBook(name: 'Genesis', chapterCount: 50, testament: 'OT'),
    BibleBook(name: 'Exodus', chapterCount: 40, testament: 'OT'),
    BibleBook(name: 'Leviticus', chapterCount: 27, testament: 'OT'),
    BibleBook(name: 'Numbers', chapterCount: 36, testament: 'OT'),
    BibleBook(name: 'Deuteronomy', chapterCount: 34, testament: 'OT'),
    BibleBook(name: 'Joshua', chapterCount: 24, testament: 'OT'),
    BibleBook(name: 'Judges', chapterCount: 21, testament: 'OT'),
    BibleBook(name: 'Ruth', chapterCount: 4, testament: 'OT'),
    BibleBook(name: '1 Samuel', chapterCount: 31, testament: 'OT'),
    BibleBook(name: '2 Samuel', chapterCount: 24, testament: 'OT'),
    BibleBook(name: '1 Kings', chapterCount: 22, testament: 'OT'),
    BibleBook(name: '2 Kings', chapterCount: 25, testament: 'OT'),
    BibleBook(name: '1 Chronicles', chapterCount: 29, testament: 'OT'),
    BibleBook(name: '2 Chronicles', chapterCount: 36, testament: 'OT'),
    BibleBook(name: 'Ezra', chapterCount: 10, testament: 'OT'),
    BibleBook(name: 'Nehemiah', chapterCount: 13, testament: 'OT'),
    BibleBook(name: 'Esther', chapterCount: 10, testament: 'OT'),
    BibleBook(name: 'Job', chapterCount: 42, testament: 'OT'),
    BibleBook(name: 'Psalms', chapterCount: 150, testament: 'OT'),
    BibleBook(name: 'Proverbs', chapterCount: 31, testament: 'OT'),
    BibleBook(name: 'Ecclesiastes', chapterCount: 12, testament: 'OT'),
    BibleBook(name: 'Song of Solomon', chapterCount: 8, testament: 'OT'),
    BibleBook(name: 'Isaiah', chapterCount: 66, testament: 'OT'),
    BibleBook(name: 'Jeremiah', chapterCount: 52, testament: 'OT'),
    BibleBook(name: 'Lamentations', chapterCount: 5, testament: 'OT'),
    BibleBook(name: 'Ezekiel', chapterCount: 48, testament: 'OT'),
    BibleBook(name: 'Daniel', chapterCount: 12, testament: 'OT'),
    BibleBook(name: 'Hosea', chapterCount: 14, testament: 'OT'),
    BibleBook(name: 'Joel', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Amos', chapterCount: 9, testament: 'OT'),
    BibleBook(name: 'Obadiah', chapterCount: 1, testament: 'OT'),
    BibleBook(name: 'Jonah', chapterCount: 4, testament: 'OT'),
    BibleBook(name: 'Micah', chapterCount: 7, testament: 'OT'),
    BibleBook(name: 'Nahum', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Habakkuk', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Zephaniah', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Haggai', chapterCount: 2, testament: 'OT'),
    BibleBook(name: 'Zechariah', chapterCount: 14, testament: 'OT'),
    BibleBook(name: 'Malachi', chapterCount: 4, testament: 'OT'),

    // New Testament (27 books)
    BibleBook(name: 'Matthew', chapterCount: 28, testament: 'NT'),
    BibleBook(name: 'Mark', chapterCount: 16, testament: 'NT'),
    BibleBook(name: 'Luke', chapterCount: 24, testament: 'NT'),
    BibleBook(name: 'John', chapterCount: 21, testament: 'NT'),
    BibleBook(name: 'Acts', chapterCount: 28, testament: 'NT'),
    BibleBook(name: 'Romans', chapterCount: 16, testament: 'NT'),
    BibleBook(name: '1 Corinthians', chapterCount: 16, testament: 'NT'),
    BibleBook(name: '2 Corinthians', chapterCount: 13, testament: 'NT'),
    BibleBook(name: 'Galatians', chapterCount: 6, testament: 'NT'),
    BibleBook(name: 'Ephesians', chapterCount: 6, testament: 'NT'),
    BibleBook(name: 'Philippians', chapterCount: 4, testament: 'NT'),
    BibleBook(name: 'Colossians', chapterCount: 4, testament: 'NT'),
    BibleBook(name: '1 Thessalonians', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '2 Thessalonians', chapterCount: 3, testament: 'NT'),
    BibleBook(name: '1 Timothy', chapterCount: 6, testament: 'NT'),
    BibleBook(name: '2 Timothy', chapterCount: 4, testament: 'NT'),
    BibleBook(name: 'Titus', chapterCount: 3, testament: 'NT'),
    BibleBook(name: 'Philemon', chapterCount: 1, testament: 'NT'),
    BibleBook(name: 'Hebrews', chapterCount: 13, testament: 'NT'),
    BibleBook(name: 'James', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '1 Peter', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '2 Peter', chapterCount: 3, testament: 'NT'),
    BibleBook(name: '1 John', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '2 John', chapterCount: 1, testament: 'NT'),
    BibleBook(name: '3 John', chapterCount: 1, testament: 'NT'),
    BibleBook(name: 'Jude', chapterCount: 1, testament: 'NT'),
    BibleBook(name: 'Revelation', chapterCount: 22, testament: 'NT'),
  ];

  /// Returns the chapter count for the given [bookName], defaulting to 1 if not found.
  static int getChapterCount(String bookName) {
    for (final book in all) {
      if (book.name.toLowerCase() == bookName.toLowerCase()) {
        return book.chapterCount;
      }
    }
    return 1;
  }

  /// Finds the [BibleBook] by [name].
  static BibleBook? findByName(String name) {
    for (final book in all) {
      if (book.name.toLowerCase() == name.toLowerCase()) {
        return book;
      }
    }
    return null;
  }
}
