/// Represents a Bible book, its Amharic name, chapter count, and testament.
class BibleBook {
  final String name;
  final String amharicName;
  final int chapterCount;
  final String testament;

  const BibleBook({
    required this.name,
    required this.amharicName,
    required this.chapterCount,
    required this.testament,
  });

  /// Returns the book name localized according to [languageCode].
  String localizedName(String languageCode) =>
      languageCode == 'am' ? amharicName : name;
}

/// Catalog of all 66 Bible books in canonical order with chapter counts
/// and localized Amharic names.
class BibleBooks {
  static const List<BibleBook> all = [
    // Old Testament (39 books)
    BibleBook(name: 'Genesis', amharicName: 'ዘፍጥረት', chapterCount: 50, testament: 'OT'),
    BibleBook(name: 'Exodus', amharicName: 'ዘጸአት', chapterCount: 40, testament: 'OT'),
    BibleBook(name: 'Leviticus', amharicName: 'ዘሌዋውያን', chapterCount: 27, testament: 'OT'),
    BibleBook(name: 'Numbers', amharicName: 'ዘኍልቍ', chapterCount: 36, testament: 'OT'),
    BibleBook(name: 'Deuteronomy', amharicName: 'ዘዳግም', chapterCount: 34, testament: 'OT'),
    BibleBook(name: 'Joshua', amharicName: 'ኢያሱ', chapterCount: 24, testament: 'OT'),
    BibleBook(name: 'Judges', amharicName: 'መሳፍንት', chapterCount: 21, testament: 'OT'),
    BibleBook(name: 'Ruth', amharicName: 'ሩት', chapterCount: 4, testament: 'OT'),
    BibleBook(name: '1 Samuel', amharicName: '1 ሳሙኤል', chapterCount: 31, testament: 'OT'),
    BibleBook(name: '2 Samuel', amharicName: '2 ሳሙኤል', chapterCount: 24, testament: 'OT'),
    BibleBook(name: '1 Kings', amharicName: '1 ነገሥት', chapterCount: 22, testament: 'OT'),
    BibleBook(name: '2 Kings', amharicName: '2 ነገሥት', chapterCount: 25, testament: 'OT'),
    BibleBook(name: '1 Chronicles', amharicName: '1 ዜና መዋዕል', chapterCount: 29, testament: 'OT'),
    BibleBook(name: '2 Chronicles', amharicName: '2 ዜና መዋዕል', chapterCount: 36, testament: 'OT'),
    BibleBook(name: 'Ezra', amharicName: 'ዕዝራ', chapterCount: 10, testament: 'OT'),
    BibleBook(name: 'Nehemiah', amharicName: 'ነህምያ', chapterCount: 13, testament: 'OT'),
    BibleBook(name: 'Esther', amharicName: 'አስቴር', chapterCount: 10, testament: 'OT'),
    BibleBook(name: 'Job', amharicName: 'ኢዮብ', chapterCount: 42, testament: 'OT'),
    BibleBook(name: 'Psalms', amharicName: 'መዝሙር', chapterCount: 150, testament: 'OT'),
    BibleBook(name: 'Proverbs', amharicName: 'ምሳሌ', chapterCount: 31, testament: 'OT'),
    BibleBook(name: 'Ecclesiastes', amharicName: 'መክብብ', chapterCount: 12, testament: 'OT'),
    BibleBook(name: 'Song of Solomon', amharicName: 'መኃልየ መኃልይ', chapterCount: 8, testament: 'OT'),
    BibleBook(name: 'Isaiah', amharicName: 'ኢሳይያስ', chapterCount: 66, testament: 'OT'),
    BibleBook(name: 'Jeremiah', amharicName: 'ኤርምያስ', chapterCount: 52, testament: 'OT'),
    BibleBook(name: 'Lamentations', amharicName: 'ሰቆቃወ ኤርምያስ', chapterCount: 5, testament: 'OT'),
    BibleBook(name: 'Ezekiel', amharicName: 'ሕዝቅኤል', chapterCount: 48, testament: 'OT'),
    BibleBook(name: 'Daniel', amharicName: 'ዳንኤል', chapterCount: 12, testament: 'OT'),
    BibleBook(name: 'Hosea', amharicName: 'ሆሴዕ', chapterCount: 14, testament: 'OT'),
    BibleBook(name: 'Joel', amharicName: 'ኢዩኤል', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Amos', amharicName: 'አሞጽ', chapterCount: 9, testament: 'OT'),
    BibleBook(name: 'Obadiah', amharicName: 'አብድዩ', chapterCount: 1, testament: 'OT'),
    BibleBook(name: 'Jonah', amharicName: 'ዮናስ', chapterCount: 4, testament: 'OT'),
    BibleBook(name: 'Micah', amharicName: 'ሚክያስ', chapterCount: 7, testament: 'OT'),
    BibleBook(name: 'Nahum', amharicName: 'ናሆም', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Habakkuk', amharicName: 'ዕንባቆም', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Zephaniah', amharicName: 'ሶፎንያስ', chapterCount: 3, testament: 'OT'),
    BibleBook(name: 'Haggai', amharicName: 'ሐጌ', chapterCount: 2, testament: 'OT'),
    BibleBook(name: 'Zechariah', amharicName: 'ዘካርያስ', chapterCount: 14, testament: 'OT'),
    BibleBook(name: 'Malachi', amharicName: 'ሚልክያስ', chapterCount: 4, testament: 'OT'),

    // New Testament (27 books)
    BibleBook(name: 'Matthew', amharicName: 'ማቴዎስ', chapterCount: 28, testament: 'NT'),
    BibleBook(name: 'Mark', amharicName: 'ማርቆስ', chapterCount: 16, testament: 'NT'),
    BibleBook(name: 'Luke', amharicName: 'ሉቃስ', chapterCount: 24, testament: 'NT'),
    BibleBook(name: 'John', amharicName: 'ዮሐንስ', chapterCount: 21, testament: 'NT'),
    BibleBook(name: 'Acts', amharicName: 'የሐዋርያት ሥራ', chapterCount: 28, testament: 'NT'),
    BibleBook(name: 'Romans', amharicName: 'ሮሜ', chapterCount: 16, testament: 'NT'),
    BibleBook(name: '1 Corinthians', amharicName: '1 ቆሮንቶስ', chapterCount: 16, testament: 'NT'),
    BibleBook(name: '2 Corinthians', amharicName: '2 ቆሮንቶስ', chapterCount: 13, testament: 'NT'),
    BibleBook(name: 'Galatians', amharicName: 'ገላትያ', chapterCount: 6, testament: 'NT'),
    BibleBook(name: 'Ephesians', amharicName: 'ኤፌሶን', chapterCount: 6, testament: 'NT'),
    BibleBook(name: 'Philippians', amharicName: 'ፊልጵስዩስ', chapterCount: 4, testament: 'NT'),
    BibleBook(name: 'Colossians', amharicName: 'ቆላስይስ', chapterCount: 4, testament: 'NT'),
    BibleBook(name: '1 Thessalonians', amharicName: '1 ተሰሎንቄ', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '2 Thessalonians', amharicName: '2 ተሰሎንቄ', chapterCount: 3, testament: 'NT'),
    BibleBook(name: '1 Timothy', amharicName: '1 ጢሞቴዎስ', chapterCount: 6, testament: 'NT'),
    BibleBook(name: '2 Timothy', amharicName: '2 ጢሞቴዎስ', chapterCount: 4, testament: 'NT'),
    BibleBook(name: 'Titus', amharicName: 'ቲቶ', chapterCount: 3, testament: 'NT'),
    BibleBook(name: 'Philemon', amharicName: 'ፊልሞና', chapterCount: 1, testament: 'NT'),
    BibleBook(name: 'Hebrews', amharicName: 'ዕብራውያን', chapterCount: 13, testament: 'NT'),
    BibleBook(name: 'James', amharicName: 'ያዕቆብ', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '1 Peter', amharicName: '1 ጴጥሮስ', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '2 Peter', amharicName: '2 ጴጥሮስ', chapterCount: 3, testament: 'NT'),
    BibleBook(name: '1 John', amharicName: '1 ዮሐንስ', chapterCount: 5, testament: 'NT'),
    BibleBook(name: '2 John', amharicName: '2 ዮሐንስ', chapterCount: 1, testament: 'NT'),
    BibleBook(name: '3 John', amharicName: '3 ዮሐንስ', chapterCount: 1, testament: 'NT'),
    BibleBook(name: 'Jude', amharicName: 'ይሁዳ', chapterCount: 1, testament: 'NT'),
    BibleBook(name: 'Revelation', amharicName: 'የዮሐንስ ራእይ', chapterCount: 22, testament: 'NT'),
  ];

  /// Returns only the 39 Old Testament books.
  static List<BibleBook> get oldTestament =>
      all.where((b) => b.testament == 'OT').toList();

  /// Returns the chapter count for the given [bookName], defaulting to 1 if not found.
  /// Matches against both English and Amharic names.
  static int getChapterCount(String bookName) {
    final trimmed = bookName.trim().toLowerCase();
    for (final book in all) {
      if (book.name.toLowerCase() == trimmed ||
          book.amharicName.toLowerCase() == trimmed) {
        return book.chapterCount;
      }
    }
    return 1;
  }

  /// Finds the [BibleBook] by English or Amharic [name].
  static BibleBook? findByName(String name) {
    final trimmed = name.trim().toLowerCase();
    for (final book in all) {
      if (book.name.toLowerCase() == trimmed ||
          book.amharicName.toLowerCase() == trimmed) {
        return book;
      }
    }
    return null;
  }

  /// Returns the localized name for [bookName] in [languageCode] ('am' or 'en').
  /// Accepts either English or Amharic name as input.
  static String getLocalizedName(String bookName, String languageCode) {
    final book = findByName(bookName);
    if (book != null) {
      return book.localizedName(languageCode);
    }
    return bookName;
  }

  /// Searches books by [query] matching either English or Amharic names.
  static List<BibleBook> search(String query, {String? testament}) {
    final q = query.trim().toLowerCase();
    return all.where((b) {
      if (testament != null && b.testament != testament) return false;
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) ||
          b.amharicName.toLowerCase().contains(q);
    }).toList();
  }
}
