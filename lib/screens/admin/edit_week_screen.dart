import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../models/study_week.dart';
import '../../state/auth_state.dart';
import '../../state/locale_state.dart';
import '../../state/team_state.dart';
import '../../ui/ui.dart';

/// Admin screen to edit and publish the current week's study passage and session info.
class EditWeekScreen extends StatefulWidget {
  const EditWeekScreen({super.key});

  @override
  State<EditWeekScreen> createState() => _EditWeekScreenState();
}

class _EditWeekScreenState extends State<EditWeekScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _book;
  late int _chapter;
  late int _verseFrom;
  late int _verseTo;
  late String _sessionDay;
  late TimeOfDay _sessionTime;
  late TimeOfDay _reminderTime;
  final _placeController = TextEditingController();

  bool _isSaving = false;
  bool _isNewWeek = false;

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    final week = context.read<TeamState>().currentWeek;
    _book = week?.book ?? 'Matthew';
    _chapter = week?.chapter ?? 5;
    _verseFrom = week?.verseFrom ?? 1;
    _verseTo = week?.verseTo ?? 8;
    _sessionDay = week?.sessionDay ?? 'Friday';
    _sessionTime = _parseTime(week?.sessionTime ?? '6:00 PM');
    _reminderTime = _parseTime(week?.thursdayReminderTime ?? '18:00');
    _placeController.text = week?.place ?? 'Church hall';
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String s) {
    try {
      final trimmed = s.trim();
      final isPm = trimmed.toLowerCase().contains('pm');
      final isAm = trimmed.toLowerCase().contains('am');
      final clean = trimmed.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      final parts = clean.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
    } catch (_) {
      return const TimeOfDay(hour: 18, minute: 0);
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  int get _maxChapter => BibleBooks.getChapterCount(_book);

  void _clampVerses() {
    if (_chapter < 1) _chapter = 1;
    if (_chapter > _maxChapter) _chapter = _maxChapter;
    if (_verseFrom < 1) _verseFrom = 1;
    if (_verseFrom > 176) _verseFrom = 176;
    if (_verseTo < _verseFrom) _verseTo = _verseFrom;
    if (_verseTo > 176) _verseTo = 176;
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    _clampVerses();

    final uid = context.read<AuthState>().user?.uid ?? '';
    final existingWeek = context.read<TeamState>().currentWeek;

    final week = StudyWeek(
      id: existingWeek?.id ?? '',
      book: _book,
      chapter: _chapter,
      verseFrom: _verseFrom,
      verseTo: _verseTo,
      sessionDay: _sessionDay,
      sessionTime: _formatTime(_sessionTime),
      place: _placeController.text.trim(),
      thursdayReminderTime:
          '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
      publishedAt: DateTime.now(),
      updatedBy: uid,
    );

    setState(() => _isSaving = true);
    final result = await context
        .read<TeamState>()
        .publishWeek(week, isNewWeek: _isNewWeek);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result != null) {
      final languageCode = context.read<LocaleState>().languageCode;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.publishedFor(result.localizedPassageText(languageCode)),
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotPublish)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LocaleState>().languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.editThisWeeksStudy, style: AppTextStyles.titleMedium()),
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
                  // ── Passage Card ──────────────────────────────────────────
                  SectionTitle(title: l10n.portion),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.book, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final picked = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (_) => _BookPickerPage(initial: _book),
                              ),
                            );
                            if (picked != null && picked != _book) {
                              setState(() {
                                _book = picked;
                                _chapter = 1;
                                _verseFrom = 1;
                                _verseTo = 1;
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
                                  BibleBooks.getLocalizedName(_book, languageCode),
                                  style: AppTextStyles.body(fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.chapterRange(_maxChapter), style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        _ModernStepper(
                          value: _chapter,
                          min: 1,
                          max: _maxChapter,
                          onDecrement: () => setState(() {
                            if (_chapter > 1) _chapter--;
                          }),
                          onIncrement: () => setState(() {
                            if (_chapter < _maxChapter) _chapter++;
                          }),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.verseFrom, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        _ModernStepper(
                          value: _verseFrom,
                          min: 1,
                          max: 176,
                          onDecrement: () => setState(() {
                            if (_verseFrom > 1) _verseFrom--;
                          }),
                          onIncrement: () => setState(() {
                            if (_verseFrom < 176) {
                              _verseFrom++;
                              if (_verseTo < _verseFrom) _verseTo = _verseFrom;
                            }
                          }),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.verseTo, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        _ModernStepper(
                          value: _verseTo,
                          min: _verseFrom,
                          max: 176,
                          onDecrement: () => setState(() {
                            if (_verseTo > _verseFrom) _verseTo--;
                          }),
                          onIncrement: () => setState(() {
                            if (_verseTo < 176) _verseTo++;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Session Details Card ──────────────────────────────────
                  SectionTitle(title: l10n.sessionDay),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.sessionDay, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _sessionDay,
                          decoration: InputDecoration(
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
                          items: _days
                              .map((d) => DropdownMenuItem(value: d, child: Text(d, style: AppTextStyles.body())))
                              .toList(),
                          onChanged: (v) => setState(() => _sessionDay = v!),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.sessionTime, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _sessionTime,
                            );
                            if (t != null) setState(() => _sessionTime = t);
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
                                Text(_formatTime(_sessionTime), style: AppTextStyles.body()),
                                const Icon(Icons.access_time_outlined, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.place, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _placeController,
                          style: AppTextStyles.body(),
                          decoration: InputDecoration(
                            hintText: l10n.placeHint,
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
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.placeRequired : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Reminder & Options Card ───────────────────────────────
                  SectionTitle(title: l10n.thursdayReminderTimeLabel),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.thursdayReminderTimeLabel, style: AppTextStyles.label()),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _reminderTime,
                            );
                            if (t != null) setState(() => _reminderTime = t);
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
                                Text(_formatTime(_reminderTime), style: AppTextStyles.body()),
                                const Icon(Icons.notifications_outlined, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.accent,
                          title: Text(l10n.startAsNewWeek, style: AppTextStyles.cardTitle()),
                          subtitle: Text(l10n.startAsNewWeekSubtitle, style: AppTextStyles.caption()),
                          value: _isNewWeek,
                          onChanged: (v) => setState(() => _isNewWeek = v ?? false),
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
                  onPressed: _isSaving ? null : _publish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernStepper extends StatelessWidget {
  const _ModernStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final int min;
  final int max;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: value > min ? AppColors.accent : AppColors.textMuted,
            onPressed: value > min ? onDecrement : null,
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            color: value < max ? AppColors.accent : AppColors.textMuted,
            onPressed: value < max ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

/// Searchable book picker reusing the 66-book list.
class _BookPickerPage extends StatefulWidget {
  const _BookPickerPage({required this.initial});
  final String initial;

  @override
  State<_BookPickerPage> createState() => _BookPickerPageState();
}

class _BookPickerPageState extends State<_BookPickerPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LocaleState>().languageCode;
    final filtered = BibleBooks.search(_query);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextField(
          autofocus: true,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            hintText: l10n.searchBookHint,
            hintStyle: AppTextStyles.bodyMuted(),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final book = filtered[i];
          final localizedName = book.localizedName(languageCode);
          final isSelected = book.name == widget.initial;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: EdgeInsets.zero,
              color: isSelected ? AppColors.accentLight : Colors.white,
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  localizedName,
                  style: AppTextStyles.body(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  ),
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
    );
  }
}
