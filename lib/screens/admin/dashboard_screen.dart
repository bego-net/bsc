import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/member_summary.dart';
import '../../services/points.dart';
import '../../services/weekly_summary.dart';
import '../../state/dashboard_state.dart';
import '../../state/locale_state.dart';
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: l10n.membersList,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MembersListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: l10n.copySummary,
            onPressed: dash.isLoading ? null : () => _copySummary(context, dash, languageCode, l10n),
          ),
          const ProfileAvatarButton(),
        ],
      ),
      body: Builder(builder: (context) {
        if (dash.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dash.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${l10n.error}: ${dash.error}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => dash.refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: dash.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionLabel(theme, l10n.thisWeek),
              const SizedBox(height: 8),
              _MembersCard(dash: dash, l10n: l10n),
              const SizedBox(height: 8),
              _IbsCard(dash: dash, l10n: l10n),
              const SizedBox(height: 8),
              _TeamCard(dash: dash, languageCode: languageCode, l10n: l10n),
              const SizedBox(height: 8),
              _OtCard(dash: dash, l10n: l10n),
              const SizedBox(height: 8),
              _EncouragementCard(dash: dash, l10n: l10n),
              const SizedBox(height: 20),
              _sectionLabel(theme, l10n.leaderboardTitle),
              const SizedBox(height: 8),
              _TopReadersList(members: dash.allMembers, l10n: l10n),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) => Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
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
      icon: Icons.group_outlined,
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
          Text(l10n.noMembersNeedsEncouragement)
        else ...[
          _Stat(label: '${list.length}', value: ''),
          const SizedBox(height: 4),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDetailScreen(uid: member.uid),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.chevron_right, size: 16),
            const SizedBox(width: 4),
            Expanded(child: Text(member.name)),
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
      return Text(l10n.noLeaderboardData);
    }
    return Column(
      children: [
        for (int i = 0; i < top.length; i++)
          _TopReaderTile(rank: i + 1, member: top[i], l10n: l10n),
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(medal, style: const TextStyle(fontSize: 22)),
      title: Text(member.name),
      subtitle: Text(
          'IBS: ${member.ibsDaysThisWeek}d  OT: ${member.otDaysThisWeek}d'
          '${member.preparedThisWeek ? '  ✓ ${l10n.preparedBadge}' : ''}'),
      trailing: Text(
        l10n.points(pts),
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDetailScreen(uid: member.uid),
        ),
      ),
    );
  }
}
