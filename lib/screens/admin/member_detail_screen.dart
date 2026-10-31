import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member_summary.dart';
import '../../state/dashboard_state.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Member Detail')),
      body: FutureBuilder<MemberSummary>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                  Text('Role: ${member.role}',
                      style: theme.textTheme.bodySmall),
                  Text(
                    'Joined: ${_fmtDate(member.joinDate)}',
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
          title: 'Current Study',
          children: [
            _Row('Book', member.currentBook),
            _Row('Chapter', '${member.currentChapter}'),
            _Row('Verse range',
                '${member.currentVerseFrom}–${member.currentVerseTo}'),
          ],
        ),
        const SizedBox(height: 8),

        // ── Streaks ────────────────────────────────────────────────────────
        _Section(
          title: 'Streaks',
          children: [
            _Row('Individual BS streak', '${member.ibsStreak} days'),
            _Row('Old Testament streak', '${member.otStreak} days'),
          ],
        ),
        const SizedBox(height: 8),

        // ── IBS History ────────────────────────────────────────────────────
        _Section(
          title: 'Individual BS – last 30 days',
          children: member.ibsHistory.isEmpty
              ? [const Text('No readings recorded.')]
              : member.ibsHistory
                  .map((e) => _Row(e.date, e.referenceText))
                  .toList(),
        ),
        const SizedBox(height: 8),

        // ── OT History ────────────────────────────────────────────────────
        _Section(
          title: 'Old Testament – last 30 days',
          children: member.otReadingDates.isEmpty
              ? [const Text('No readings recorded.')]
              : member.otReadingDates
                  .map((d) => _Row(d, '✓ Completed'))
                  .toList(),
        ),
        const SizedBox(height: 8),

        // ── Team BS History ───────────────────────────────────────────────
        _Section(
          title: 'Team BS – prepared per week',
          children: member.teamPrepHistory.isEmpty
              ? [const Text('No data available.')]
              : member.teamPrepHistory.entries
                  .map((e) => _Row(e.key, e.value ? '✓ Prepared' : '– Not prepared'))
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
