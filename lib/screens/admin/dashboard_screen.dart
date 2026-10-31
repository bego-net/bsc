import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/member_summary.dart';
import '../../services/points.dart';
import '../../services/weekly_summary.dart';
import '../../state/dashboard_state.dart';
import 'members_list_screen.dart';
import '../../widgets/profile_avatar_button.dart';
import 'member_detail_screen.dart';

/// Admin-only home for the Dashboard tab: summary cards + top readers.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load on first open; respects 2-min cache.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardState>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Members list',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MembersListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy weekly summary',
            onPressed: dash.isLoading ? null : () => _copySummary(context, dash),
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
                Text('Error: ${dash.error}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => dash.refresh(),
                  child: const Text('Retry'),
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
              _sectionLabel(theme, 'This week at a glance'),
              const SizedBox(height: 8),
              _MembersCard(dash: dash),
              const SizedBox(height: 8),
              _IbsCard(dash: dash),
              const SizedBox(height: 8),
              _TeamCard(dash: dash),
              const SizedBox(height: 8),
              _OtCard(dash: dash),
              const SizedBox(height: 8),
              _EncouragementCard(dash: dash),
              const SizedBox(height: 20),
              _sectionLabel(theme, 'Top readers this week'),
              const SizedBox(height: 8),
              _TopReadersList(members: dash.allMembers),
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

  void _copySummary(BuildContext context, DashboardState dash) {
    final text = buildWeeklySummary(
      teamWeek: dash.currentTeamWeek,
      members: dash.allMembers,
      otTopic: dash.otTopic,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weekly summary copied to clipboard!')),
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
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
  const _MembersCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      icon: Icons.group_outlined,
      title: 'Members',
      children: [
        _Stat(label: 'Total', value: '${dash.totalMembers}'),
        _Stat(label: 'Active this week', value: '${dash.activeThisWeek}'),
      ],
    );
  }
}

class _IbsCard extends StatelessWidget {
  final DashboardState dash;
  const _IbsCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      icon: Icons.person_outline,
      title: 'Individual Bible Study',
      children: [
        _Stat(
            label: 'Avg days read this week',
            value: dash.avgIbsDaysThisWeek.toStringAsFixed(1)),
        _Stat(label: 'Read today', value: '${dash.readTodayCount}'),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  final DashboardState dash;
  const _TeamCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final week = dash.currentTeamWeek;
    return _SummaryCard(
      icon: Icons.group_outlined,
      title: 'Team Bible Study',
      children: [
        if (week != null)
          _Stat(label: 'Passage', value: week.passageText),
        _Stat(
            label: 'Prepared',
            value: '${dash.preparedCount} of ${dash.totalMembers}'),
      ],
    );
  }
}

class _OtCard extends StatelessWidget {
  final DashboardState dash;
  const _OtCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      icon: Icons.menu_book_outlined,
      title: 'Old Testament',
      children: [
        if (dash.otTopic.isNotEmpty)
          _Stat(label: 'Topic', value: dash.otTopic),
        _Stat(
            label: 'Avg readings this week',
            value: dash.avgOtDaysThisWeek.toStringAsFixed(1)),
      ],
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  final DashboardState dash;
  const _EncouragementCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final list = dash.needsEncouragementList;
    return _SummaryCard(
      icon: Icons.favorite_border,
      title: 'Needs encouragement (3+ days without reading)',
      children: [
        if (list.isEmpty)
          const Text('Everyone is on track! 🎉')
        else ...[
          _Stat(label: 'Count', value: '${list.length}'),
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
  const _TopReadersList({required this.members});

  @override
  Widget build(BuildContext context) {
    final top = topReaders(members);
    if (top.isEmpty) {
      return const Text('No reading data yet.');
    }
    return Column(
      children: [
        for (int i = 0; i < top.length; i++)
          _TopReaderTile(rank: i + 1, member: top[i]),
      ],
    );
  }
}

class _TopReaderTile extends StatelessWidget {
  final int rank;
  final MemberSummary member;
  const _TopReaderTile({required this.rank, required this.member});

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
          '${member.preparedThisWeek ? '  ✓ Prepared' : ''}'),
      trailing: Text('$pts pts',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDetailScreen(uid: member.uid),
        ),
      ),
    );
  }
}
