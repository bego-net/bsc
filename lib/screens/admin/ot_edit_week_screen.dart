import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../models/ot_day.dart';
import '../../state/ot_state.dart';

/// Screen allowing admins to create and publish a new Old Testament weekly plan.
class OtEditWeekScreen extends StatefulWidget {
  const OtEditWeekScreen({super.key});

  @override
  State<OtEditWeekScreen> createState() => _OtEditWeekScreenState();
}

class _DayDraft {
  final String date;
  final String dayName;
  String book;
  int chapter;
  bool isWholeChapter;
  int verseFrom = 1;
  int verseTo = 1;

  _DayDraft({
    required this.date,
    required this.dayName,
    this.book = 'Genesis',
    this.chapter = 1,
    this.isWholeChapter = true,
  });

  OtDay toOtDay() {
    return OtDay(
      date: date,
      book: book,
      chapter: chapter,
      verseFrom: isWholeChapter ? null : verseFrom,
      verseTo: isWholeChapter ? null : verseTo,
    );
  }
}

class _OtEditWeekScreenState extends State<OtEditWeekScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();

  late DateTime _startDate;
  bool _includeSaturday = false;
  bool _includeSunday = false;
  bool _isSaving = false;

  final Map<int, _DayDraft> _dayDrafts = {};

  @override
  void initState() {
    super.initState();
    _startDate = _calculateComingMonday();
    _initDays();

    final currentWeek = context.read<OtState>().currentWeek;
    if (currentWeek != null) {
      _topicController.text = currentWeek.topic;
    } else {
      _topicController.text = 'Faith: the journey of Abraham';
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  DateTime _calculateComingMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    return daysUntilMonday == 0
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day + daysUntilMonday);
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _initDays() {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (int i = 0; i < 7; i++) {
      final dt = _startDate.add(Duration(days: i));
      _dayDrafts[i] = _DayDraft(
        date: _formatDate(dt),
        dayName: dayNames[i],
        book: 'Genesis',
        chapter: i + 1,
        isWholeChapter: true,
      );
    }
  }

  void _onStartDateChanged(DateTime newDate) {
    setState(() {
      _startDate = newDate;
      _initDays();
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _onStartDateChanged(picked);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final topic = _topicController.text.trim();
    final days = <OtDay>[];

    // Mon-Fri are always included
    for (int i = 0; i < 5; i++) {
      days.add(_dayDrafts[i]!.toOtDay());
    }
    if (_includeSaturday) {
      days.add(_dayDrafts[5]!.toOtDay());
    }
    if (_includeSunday) {
      days.add(_dayDrafts[6]!.toOtDay());
    }

    setState(() => _isSaving = true);

    final published = await context.read<OtState>().publishWeek(
          topic: topic,
          startDate: _formatDate(_startDate),
          days: days,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (published != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Published: "$topic" (${days.length} days)')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to publish. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeIndices = [
      0, 1, 2, 3, 4,
      if (_includeSaturday) 5,
      if (_includeSunday) 6,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Edit OT Week Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Topic Input ───────────────────────────────────────────────
            Text(
              'Weekly Topic',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                hintText: 'e.g., Faith: the journey of Abraham',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a topic'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Start Date Picker ─────────────────────────────────────────
            Text(
              'Week Start Date (Monday)',
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

            // ── Weekend Options ───────────────────────────────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include Saturday reading'),
                      value: _includeSaturday,
                      onChanged: (v) => setState(() => _includeSaturday = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include Sunday reading'),
                      value: _includeSunday,
                      onChanged: (v) => setState(() => _includeSunday = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Daily Passages ────────────────────────────────────────────
            Text(
              'Daily Passages (${activeIndices.length} days)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...activeIndices.map((idx) {
              final draft = _dayDrafts[idx]!;
              return _DayEditorCard(
                draft: draft,
                onChanged: () => setState(() {}),
              );
            }),

            const SizedBox(height: 24),

            // ── Publish Button ────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSaving ? null : _publish,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.publish_outlined),
              label: Text(_isSaving ? 'Publishing...' : 'Publish Week Plan'),
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

class _DayEditorCard extends StatelessWidget {
  final _DayDraft draft;
  final VoidCallback onChanged;

  const _DayEditorCard({
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxChapters = BibleBooks.getChapterCount(draft.book);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${draft.dayName} (${draft.date})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  draft.toOtDay().passageText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Book Picker
            InkWell(
              onTap: () async {
                final picked = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => _OtBookPickerPage(initial: draft.book),
                  ),
                );
                if (picked != null && picked != draft.book) {
                  draft.book = picked;
                  draft.chapter = 1;
                  draft.verseFrom = 1;
                  draft.verseTo = 1;
                  onChanged();
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Book (Old Testament)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(draft.book),
              ),
            ),
            const SizedBox(height: 10),

            // Chapter
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chapter: ${draft.chapter} (1 – $maxChapters)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: draft.chapter > 1
                      ? () {
                          draft.chapter--;
                          onChanged();
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: draft.chapter < maxChapters
                      ? () {
                          draft.chapter++;
                          onChanged();
                        }
                      : null,
                ),
              ],
            ),

            // Whole Chapter vs Verse Range
            Row(
              children: [
                Checkbox(
                  value: draft.isWholeChapter,
                  onChanged: (v) {
                    draft.isWholeChapter = v ?? true;
                    onChanged();
                  },
                ),
                const Text('Read whole chapter'),
              ],
            ),

            if (!draft.isWholeChapter) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('From: ${draft.verseFrom}'),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: draft.verseFrom > 1
                              ? () {
                                  draft.verseFrom--;
                                  onChanged();
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            draft.verseFrom++;
                            if (draft.verseTo < draft.verseFrom) {
                              draft.verseTo = draft.verseFrom;
                            }
                            onChanged();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text('To: ${draft.verseTo}'),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: draft.verseTo > draft.verseFrom
                              ? () {
                                  draft.verseTo--;
                                  onChanged();
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            draft.verseTo++;
                            onChanged();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
  final List<BibleBook> _otBooks = BibleBooks.oldTestament;
  List<BibleBook> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _otBooks;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _otBooks;
      } else {
        _filtered = _otBooks
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
    return Scaffold(
      appBar: AppBar(title: const Text('Select OT Book (39 books)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search Old Testament book...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final book = _filtered[i];
                final isSelected = book.name == widget.initial;
                return ListTile(
                  title: Text(book.name),
                  subtitle: Text('${book.chapterCount} chapters'),
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
