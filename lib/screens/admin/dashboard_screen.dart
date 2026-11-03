import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/member_summary.dart';
import '../../services/points.dart';
import '../../services/weekly_summary.dart';
import '../../state/dashboard_state.dart';
import '../../state/locale_state.dart';
import '../../ui/ui.dart';
import '../../widgets/profile_avatar_button.dart';
import 'member_detail_screen.dart';
import 'members_list_screen.dart';

/// Admin dashboard screen showing study metrics, team prepared counts,
/// encouragement lists, and top reader leaderboards.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardState>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardState>();
    final languageCode = context.watch<LocaleState>().languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.dashboardTitle, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline, color: AppColors.textPrimary),
            tooltip: l10n.membersList,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MembersListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, color: AppColors.textPrimary),
            tooltip: l10n.copySummary,
            onPressed: dash.isLoading ? null : () => _copySummary(context, dash, languageCode, l10n),
          ),
          const ProfileAvatarButton(),
        ],
      ),
      body: Builder(builder: (context) {
        if (dash.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (dash.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.error}: ${dash.error}',
                    style: AppTextStyles.body(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.retry,
                    onPressed: () => dash.refresh(),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: dash.refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              SectionTitle(title: l10n.thisWeek),
              const SizedBox(height: 10),
              _MembersCard(dash: dash, l10n: l10n),
              const SizedBox(height: 12),
              _IbsCard(dash: dash, l10n: l10n),
              const SizedBox(height: 12),
              _TeamCard(dash: dash, languageCode: languageCode, l10n: l10n),
              const SizedBox(height: 12),
              _OtCard(dash: dash, l10n: l10n),
              const SizedBox(height: 12),
              _EncouragementCard(dash: dash, l10n: l10n),
              const SizedBox(height: 24),
              SectionTitle(title: l10n.leaderboardTitle),
              const SizedBox(height: 10),
              _TopReadersList(members: dash.allMembers, l10n: l10n),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  void _copySummary(
    BuildContext context,
    DashboardState dash,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final text = buildWeeklySummary(
      teamWeek: dash.currentTeamWeek,
      members: dash.allMembers,
      otTopic: dash.otTopic,
      languageCode: languageCode,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.summaryCopied)),
    );
  }
}

// ─── Summary Cards ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.cardTitle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMuted(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyles.body(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  final DashboardState dash;
  final AppLocalizations l10n;
  const _MembersCard({required this.dash, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    return _SummaryCard(
      icon: Icons.group_outlined,
      title: l10n.totalMembers,
      children: [
        _Stat(label: l10n.totalMembers, value: '${dash.totalMembers}'),
        _Stat(
          label: isAm ? 'በዚህ ሳምንት ንቁ የሆኑ' : 'Active this week',
          value: '${dash.activeThisWeek}',
        ),
      ],
    );
  }
}

class _IbsCard extends StatelessWidget {
  final DashboardState dash;
  final AppLocalizations l10n;
  const _IbsCard({required this.dash, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    return _SummaryCard(
      icon: Icons.person_outline,
      title: l10n.individualBsTitle,
      children: [
        _Stat(
          label: isAm ? 'አማካይ የንባብ ቀናት' : 'Avg days read this week',
          value: dash.avgIbsDaysThisWeek.toStringAsFixed(1),
        ),
        _Stat(
          label: isAm ? 'ዛሬ ያነበቡ' : 'Read today',
          value: '${dash.readTodayCount}',
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  final DashboardState dash;
  final String languageCode;
  final AppLocalizations l10n;
  const _TeamCard({
    required this.dash,
    required this.languageCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final week = dash.currentTeamWeek;
    final isAm = languageCode == 'am';
    return _SummaryCard(
      icon: Icons.diversity_3_outlined,
      title: l10n.teamBsTitle,
      children: [
        if (week != null)
          _Stat(
            label: l10n.portion,
            value: week.localizedPassageText(languageCode),
          ),
        _Stat(
          label: isAm ? 'የተዘጋጁ' : 'Prepared',
          value: isAm
              ? 'ከ${dash.totalMembers} ${dash.preparedCount}'
              : '${dash.preparedCount} of ${dash.totalMembers}',
        ),
      ],
    );
  }
}

class _OtCard extends StatelessWidget {
  final DashboardState dash;
  final AppLocalizations l10n;
  const _OtCard({required this.dash, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    return _SummaryCard(
      icon: Icons.menu_book_outlined,
      title: l10n.otTitle,
      children: [
        if (dash.otTopic.isNotEmpty)
          _Stat(label: isAm ? 'ርዕስ' : 'Topic', value: dash.otTopic),
        _Stat(
          label: isAm ? 'አማካይ ንባቦች' : 'Avg readings this week',
          value: dash.avgOtDaysThisWeek.toStringAsFixed(1),
        ),
      ],
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  final DashboardState dash;
  final AppLocalizations l10n;
  const _EncouragementCard({required this.dash, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final list = dash.needsEncouragementList;
    return _SummaryCard(
      icon: Icons.favorite_border,
      title: l10n.needsEncouragement,
      children: [
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.noMembersNeedsEncouragement, style: AppTextStyles.bodyMuted()),
          )
        else ...[
          _Stat(label: '${list.length}', value: ''),
          const SizedBox(height: 6),
          ...list.map(
            (m) => _MemberTile(member: m),
          ),
        ],
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberSummary member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDetailScreen(uid: member.uid),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(member.name, style: AppTextStyles.body()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Readers ────────────────────────────────────────────────────────────────

class _TopReadersList extends StatelessWidget {
  final List<MemberSummary> members;
  final AppLocalizations l10n;
  const _TopReadersList({required this.members, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final top = topReaders(members);
    if (top.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(l10n.noLeaderboardData, style: AppTextStyles.bodyMuted()),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < top.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TopReaderTile(rank: i + 1, member: top[i], l10n: l10n),
          ),
      ],
    );
  }
}

class _TopReaderTile extends StatelessWidget {
  final int rank;
  final MemberSummary member;
  final AppLocalizations l10n;
  const _TopReaderTile({
    required this.rank,
    required this.member,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final pts = weeklyPoints(member);
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank.';

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemberDetailScreen(uid: member.uid),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                medal,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppTextStyles.cardTitle()),
                  const SizedBox(height: 2),
                  Text(
                    'IBS: ${member.ibsDaysThisWeek}d  OT: ${member.otDaysThisWeek}d'
                    '${member.preparedThisWeek ? '  ✓ ${l10n.preparedBadge}' : ''}',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
            Text(
              l10n.points(pts),
              style: AppTextStyles.body(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
