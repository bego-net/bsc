import 'package:flutter/material.dart';

import '../data/bible_books.dart';

/// Screen allowing the user to search and select one of the 66 Bible books.
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
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = BibleBooks.all;
      } else {
        _filteredBooks = BibleBooks.all
            .where((b) => b.name.toLowerCase().contains(query))
            .toList();
      }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bible Book'),
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
                    hintText: 'Search book (e.g. Genesis, Matthew)',
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
                          'No books match "${_searchController.text}"',
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
                          final isSelected = book.name.toLowerCase() ==
                              widget.currentBook.toLowerCase();

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
                              book.name,
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
                              '${book.chapterCount} ${book.chapterCount == 1 ? 'chapter' : 'chapters'} • ${book.testament == 'OT' ? 'Old Testament' : 'New Testament'}',
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
