import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../models/member_summary.dart';
import '../../state/dashboard_state.dart';
import '../../state/locale_state.dart';

/// Read-only member detail screen. Opens by tapping in list or encouragement card.
class MemberDetailScreen extends StatefulWidget {
  final String uid;
  const MemberDetailScreen({super.key, required this.uid});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Future<MemberSummary> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture =
        context.read<DashboardState>().loadMemberDetail(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.memberDetail)),
      body: FutureBuilder<MemberSummary>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          final m = snapshot.data!;
          return _MemberDetailBody(member: m);
        },
      ),
    );
  }
}

class _MemberDetailBody extends StatelessWidget {
  final MemberSummary member;
  const _MemberDetailBody({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LocaleState>().languageCode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Profile header ─────────────────────────────────────────────────
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(member.email,
                      style: theme.textTheme.bodySmall),
                  Text(
                    '${l10n.role}: ${member.role == "admin" ? l10n.adminBadge : l10n.memberBadge}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${l10n.joined}: ${_fmtDate(member.joinDate)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),

        // ── Current study ──────────────────────────────────────────────────
        _Section(
          title: l10n.currentStudy,
          children: [
            _Row(
              l10n.book,
              BibleBooks.getLocalizedName(member.currentBook, languageCode),
            ),
            _Row(l10n.chapter, '${member.currentChapter}'),
            _Row(l10n.verses,
                '${member.currentVerseFrom}–${member.currentVerseTo}'),
          ],
        ),
        const SizedBox(height: 8),

        // ── Streaks ────────────────────────────────────────────────────────
        _Section(
          title: l10n.streaks,
          children: [
            _Row(l10n.ibsStreakLabel, l10n.daysCount(member.ibsStreak)),
            _Row(l10n.otStreakLabel, l10n.daysCount(member.otStreak)),
          ],
        ),
        const SizedBox(height: 8),

        // ── IBS History ────────────────────────────────────────────────────
        _Section(
          title: l10n.ibsHistory30,
          children: member.ibsHistory.isEmpty
              ? [Text(l10n.noReadingsRecorded)]
              : member.ibsHistory
                  .map((e) => _Row(e.date, e.localizedReferenceText(languageCode)))
                  .toList(),
        ),
        const SizedBox(height: 8),

        // ── OT History ────────────────────────────────────────────────────
        _Section(
          title: l10n.otHistory30,
          children: member.otReadingDates.isEmpty
              ? [Text(l10n.noReadingsRecorded)]
              : member.otReadingDates
                  .map((d) => _Row(d, l10n.completedCheck))
                  .toList(),
        ),
        const SizedBox(height: 8),

        // ── Team BS History ───────────────────────────────────────────────
        _Section(
          title: l10n.teamBsHistory,
          children: member.teamPrepHistory.isEmpty
              ? [Text(l10n.noDataAvailable)]
              : member.teamPrepHistory.entries
                  .map((e) => _Row(
                        e.key,
                        e.value ? l10n.preparedCheck : l10n.notPrepared,
                      ))
                  .toList(),
        ),
      ],
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[700])),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
          ),
        ],
      ),
    );
  }
}
