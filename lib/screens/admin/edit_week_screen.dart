import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../models/study_week.dart';
import '../../state/auth_state.dart';
import '../../state/team_state.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Published: ${result.passageText}')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not publish. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit This Week\'s Study')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Book picker ────────────────────────────────────────────────
            _SectionLabel('Book'),
            InkWell(
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
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(_book),
              ),
            ),
            const SizedBox(height: 16),

            // ── Chapter stepper ────────────────────────────────────────────
            _SectionLabel('Chapter  (1 – $_maxChapter)'),
            _Stepper(
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

            // ── Verse range ────────────────────────────────────────────────
            _SectionLabel('Verse From'),
            _Stepper(
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
            const SizedBox(height: 12),
            _SectionLabel('Verse To'),
            _Stepper(
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
            const SizedBox(height: 16),

            // ── Session day ────────────────────────────────────────────────
            _SectionLabel('Session Day'),
            DropdownButtonFormField<String>(
              initialValue: _sessionDay,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _days
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _sessionDay = v!),
            ),
            const SizedBox(height: 16),

            // ── Session time ────────────────────────────────────────────────
            _SectionLabel('Session Time'),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              title: Text(_formatTime(_sessionTime)),
              trailing: const Icon(Icons.access_time_outlined),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _sessionTime,
                );
                if (t != null) setState(() => _sessionTime = t);
              },
            ),
            const SizedBox(height: 16),

            // ── Place ──────────────────────────────────────────────────────
            _SectionLabel('Place'),
            TextFormField(
              controller: _placeController,
              decoration: const InputDecoration(
                hintText: 'e.g. Church hall, Room 2',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a place' : null,
            ),
            const SizedBox(height: 16),

            // ── Thursday reminder time ─────────────────────────────────────
            _SectionLabel('Thursday Reminder Time'),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              title: Text(_formatTime(_reminderTime)),
              trailing: const Icon(Icons.notifications_outlined),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (t != null) setState(() => _reminderTime = t);
              },
            ),
            const SizedBox(height: 24),

            // ── New week toggle ────────────────────────────────────────────
            CheckboxListTile(
              title: const Text('Start as a new week document'),
              subtitle: const Text(
                'Turn on if the passage has changed and you want a clean history entry.',
              ),
              value: _isNewWeek,
              onChanged: (v) => setState(() => _isNewWeek = v ?? false),
            ),
            const SizedBox(height: 24),

            // ── Publish button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _publish,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
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
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? onDecrement : null,
        ),
        Expanded(
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? onIncrement : null,
        ),
      ],
    );
  }
}

/// Inline book picker reusing the 66-book list.
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
    final all = BibleBooks.all;
    final filtered = _query.isEmpty
        ? all
        : all
            .where(
              (b) => b.name.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search book…',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final book = filtered[i];
          return ListTile(
            title: Text(book.name),
            selected: book.name == widget.initial,
            onTap: () => Navigator.of(context).pop(book.name),
          );
        },
      ),
    );
  }
}
