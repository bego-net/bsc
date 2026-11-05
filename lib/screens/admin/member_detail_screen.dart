import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../models/member_summary.dart';
import '../../state/dashboard_state.dart';
import '../../state/locale_state.dart';
import '../../ui/ui.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.memberDetail, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: FutureBuilder<MemberSummary>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${l10n.error}: ${snapshot.error}',
                style: AppTextStyles.body(),
              ),
            );
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
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LocaleState>().languageCode;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ── Profile header card ─────────────────────────────────────────────
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.accentLight,
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.titleMedium().copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(member.email, style: AppTextStyles.bodyMuted()),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: member.role == 'admin'
                                ? AppColors.accentLight
                                : AppColors.cardBorder.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            member.role == 'admin' ? l10n.adminBadge : l10n.memberBadge,
                            style: AppTextStyles.caption(
                              color: member.role == 'admin'
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.joined}: ${_fmtDate(member.joinDate)}',
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Current study ──────────────────────────────────────────────────
        SectionTitle(title: l10n.currentStudy),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Row(
                l10n.book,
                BibleBooks.getLocalizedName(member.currentBook, languageCode),
              ),
              const Divider(height: 16, color: AppColors.cardBorder),
              _Row(l10n.chapter, '${member.currentChapter}'),
              const Divider(height: 16, color: AppColors.cardBorder),
              _Row(
                l10n.verses,
                '${member.currentVerseFrom}–${member.currentVerseTo}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Streaks ────────────────────────────────────────────────────────
        SectionTitle(title: l10n.streaks),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Row(l10n.ibsStreakLabel, '🔥 ${l10n.daysCount(member.ibsStreak)}'),
              const Divider(height: 16, color: AppColors.cardBorder),
              _Row(l10n.otStreakLabel, '🔥 ${l10n.daysCount(member.otStreak)}'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── IBS History ────────────────────────────────────────────────────
        SectionTitle(title: l10n.ibsHistory30),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: member.ibsHistory.isEmpty
              ? Text(l10n.noReadingsRecorded, style: AppTextStyles.bodyMuted())
              : Column(
                  children: [
                    for (int i = 0; i < member.ibsHistory.length; i++) ...[
                      if (i > 0) const Divider(height: 14, color: AppColors.cardBorder),
                      _Row(
                        member.ibsHistory[i].date,
                        member.ibsHistory[i].localizedReferenceText(languageCode),
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 16),

        // ── OT History ────────────────────────────────────────────────────
        SectionTitle(title: l10n.otHistory30),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: member.otReadingDates.isEmpty
              ? Text(l10n.noReadingsRecorded, style: AppTextStyles.bodyMuted())
              : Column(
                  children: [
                    for (int i = 0; i < member.otReadingDates.length; i++) ...[
                      if (i > 0) const Divider(height: 14, color: AppColors.cardBorder),
                      _Row(member.otReadingDates[i], l10n.completedCheck),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 16),

        // ── Team BS History ───────────────────────────────────────────────
        SectionTitle(title: l10n.teamBsHistory),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: member.teamPrepHistory.isEmpty
              ? Text(l10n.noDataAvailable, style: AppTextStyles.bodyMuted())
              : Column(
                  children: [
                    for (int i = 0; i < member.teamPrepHistory.entries.length; i++) ...[
                      if (i > 0) const Divider(height: 14, color: AppColors.cardBorder),
                      _Row(
                        member.teamPrepHistory.entries.elementAt(i).key,
                        member.teamPrepHistory.entries.elementAt(i).value
                            ? l10n.preparedCheck
                            : l10n.notPrepared,
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: AppTextStyles.bodyMuted()),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
