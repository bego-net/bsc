import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/bible_books.dart';
import '../l10n/app_localizations.dart';
import '../state/locale_state.dart';

/// Screen allowing the user to search and select one of the 66 Bible books
/// in English or Amharic.
class BookPickerScreen extends StatefulWidget {
  final String currentBook;

  const BookPickerScreen({
    super.key,
    required this.currentBook,
  });

  @override
  State<BookPickerScreen> createState() => _BookPickerScreenState();
}

class _BookPickerScreenState extends State<BookPickerScreen> {
  final _searchController = TextEditingController();
  List<BibleBook> _filteredBooks = BibleBooks.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _filteredBooks = BibleBooks.search(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LocaleState>().languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectBook),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: l10n.searchBooks,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Book list
              Expanded(
                child: _filteredBooks.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noBooksFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredBooks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          final currentLower = widget.currentBook.trim().toLowerCase();
                          final isSelected = book.name.toLowerCase() == currentLower ||
                              book.amharicName.toLowerCase() == currentLower;

                          final displayName = book.localizedName(languageCode);
                          final altName = languageCode == 'am' ? book.name : book.amharicName;
                          final testamentLabel = book.testament == 'OT'
                              ? l10n.oldTestament
                              : (languageCode == 'am' ? 'አዲስ ኪዳን' : 'New Testament');

                          return ListTile(
                            tileColor: isSelected
                                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            title: Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              '$altName • ${l10n.chaptersCount(book.chapterCount)} • $testamentLabel',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: colorScheme.primary)
                                : const Icon(Icons.chevron_right, size: 20),
                            onTap: () {
                              Navigator.of(context).pop(book.name);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
