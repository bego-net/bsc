import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../state/locale_state.dart';
import '../../state/ot_state.dart';
import '../../ui/ui.dart';

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
    final languageCode = context.watch<LocaleState>().languageCode;
    final l10n = AppLocalizations.of(context)!;
    final maxChapters = BibleBooks.getChapterCount(_selectedBook);
    final localizedBook = BibleBooks.getLocalizedName(_selectedBook, languageCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.otPlan, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // ── Plan Configuration Card ─────────────────────────────────
                  SectionTitle(title: l10n.pickBook),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.selectBook, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$localizedBook (${l10n.chaptersCount(maxChapters)})',
                                  style: AppTextStyles.body(fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.startChapter, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                color: _startChapter > 1 ? AppColors.accent : AppColors.textMuted,
                                onPressed: _startChapter > 1
                                    ? () => setState(() => _startChapter--)
                                    : null,
                              ),
                              Expanded(
                                child: Text(
                                  '${l10n.chapter} $_startChapter / $maxChapters',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                color: _startChapter < maxChapters ? AppColors.accent : AppColors.textMuted,
                                onPressed: _startChapter < maxChapters
                                    ? () => setState(() => _startChapter++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.startDate, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _pickStartDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDate(_startDate), style: AppTextStyles.body()),
                                const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.topic, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _topicController,
                          style: AppTextStyles.body(),
                          decoration: InputDecoration(
                            hintText: l10n.topic,
                            hintStyle: AppTextStyles.bodyMuted(),
                            fillColor: AppColors.background,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.cardBorder),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Plan Preview Card ─────────────────────────────────────
                  AppCard(
                    color: AppColors.accentLight,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(
                              l10n.otPlan,
                              style: AppTextStyles.cardTitle(color: AppColors.accent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• $localizedBook ($_startChapter–$maxChapters)\n'
                          '• ${l10n.startDate}: ${_formatDate(_startDate)}',
                          style: AppTextStyles.body(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Sticky Save Button ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  label: l10n.publish,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : () => _publish(l10n, languageCode),
                ),
              ),
            ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.oldTestamentHeader, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: l10n.searchBooks,
                  hintStyle: AppTextStyles.bodyMuted(),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final book = _filtered[i];
                final isSelected = book.name == widget.initial ||
                    book.amharicName == widget.initial;
                final displayName = book.localizedName(languageCode);
                final altName = languageCode == 'am' ? book.name : book.amharicName;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    color: isSelected ? AppColors.accentLight : Colors.white,
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        displayName,
                        style: AppTextStyles.body(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.accent : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '$altName • ${l10n.chaptersCount(book.chapterCount)}',
                        style: AppTextStyles.caption(),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      onTap: () => Navigator.of(context).pop(book.name),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
