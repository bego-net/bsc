import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../state/locale_state.dart';
import '../../state/ot_state.dart';

/// Screen allowing admins to create and publish a new Old Testament reading plan.
class OtEditWeekScreen extends StatefulWidget {
  const OtEditWeekScreen({super.key});

  @override
  State<OtEditWeekScreen> createState() => _OtEditWeekScreenState();
}

class _OtEditWeekScreenState extends State<OtEditWeekScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();

  String _selectedBook = 'Genesis';
  int _startChapter = 1;
  late DateTime _startDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();

    final currentWeek = context.read<OtState>().currentWeek;
    if (currentWeek != null) {
      if (currentWeek.book != null && currentWeek.book!.isNotEmpty) {
        _selectedBook = currentWeek.book!;
        _startChapter = currentWeek.startChapter ?? 1;
      }
      _topicController.text = currentWeek.topic;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _publish(AppLocalizations l10n, String languageCode) async {
    if (!_formKey.currentState!.validate()) return;

    final topic = _topicController.text.trim();
    setState(() => _isSaving = true);

    final published = await context.read<OtState>().publishWeek(
          topic: topic,
          book: _selectedBook,
          startChapter: _startChapter,
          startDate: _formatDate(_startDate),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (published != null) {
      final locBook = BibleBooks.getLocalizedName(_selectedBook, languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$locBook ch. $_startChapter (${_formatDate(_startDate)}) ✓',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = context.watch<LocaleState>().languageCode;
    final l10n = AppLocalizations.of(context)!;
    final maxChapters = BibleBooks.getChapterCount(_selectedBook);
    final localizedBook = BibleBooks.getLocalizedName(_selectedBook, languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otPlan)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Book Picker ───────────────────────────────────────────────
            Text(
              l10n.pickBook,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => _OtBookPickerPage(initial: _selectedBook),
                  ),
                );
                if (picked != null && picked != _selectedBook) {
                  setState(() {
                    _selectedBook = picked;
                    final newMax = BibleBooks.getChapterCount(picked);
                    if (_startChapter > newMax) {
                      _startChapter = 1;
                    }
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.selectBook,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  '$localizedBook (${l10n.chaptersCount(maxChapters)})',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Starting Chapter ──────────────────────────────────────────
            Text(
              l10n.startChapter,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.chapter} $_startChapter / $maxChapters',
                      style: theme.textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _startChapter > 1
                              ? () => setState(() => _startChapter--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _startChapter < maxChapters
                              ? () => setState(() => _startChapter++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Start Date Picker ─────────────────────────────────────────
            Text(
              l10n.startDate,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickStartDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_formatDate(_startDate)),
              ),
            ),
            const SizedBox(height: 16),

            // ── Topic (Optional) ──────────────────────────────────────────
            Text(
              l10n.topic,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: l10n.topic,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Plan Preview Card ─────────────────────────────────────────
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.otPlan,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• $localizedBook ($_startChapter–$maxChapters)\n'
                      '• ${l10n.startDate}: ${_formatDate(_startDate)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Publish Button ────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSaving ? null : () => _publish(l10n, languageCode),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.publish_outlined),
              label: Text(_isSaving ? l10n.loading : l10n.publish),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Searchable picker restricted to the 39 Old Testament books only.
class _OtBookPickerPage extends StatefulWidget {
  final String initial;

  const _OtBookPickerPage({required this.initial});

  @override
  State<_OtBookPickerPage> createState() => _OtBookPickerPageState();
}

class _OtBookPickerPageState extends State<_OtBookPickerPage> {
  final _searchController = TextEditingController();
  List<BibleBook> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = BibleBooks.oldTestament;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    setState(() {
      _filtered = BibleBooks.search(query, testament: 'OT');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LocaleState>().languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.oldTestamentHeader)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchBooks,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final book = _filtered[i];
                final isSelected = book.name == widget.initial ||
                    book.amharicName == widget.initial;
                final displayName = book.localizedName(languageCode);
                final altName = languageCode == 'am' ? book.name : book.amharicName;

                return ListTile(
                  title: Text(displayName),
                  subtitle: Text('$altName • ${l10n.chaptersCount(book.chapterCount)}'),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(book.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
