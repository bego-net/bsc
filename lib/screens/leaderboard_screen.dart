import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member_summary.dart';
import '../services/points.dart';
import '../state/auth_state.dart';
import '../state/dashboard_state.dart';

/// Weekly Leaderboard displaying community rankings with category filters.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardCategory _selectedCategory = LeaderboardCategory.overall;

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
    final currentUid = context.watch<AuthState>().user?.uid;
    final theme = Theme.of(context);

    final ranked = rankedMembers(dash.allMembers, category: _selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<LeaderboardCategory>(
                segments: const [
                  ButtonSegment(
                    value: LeaderboardCategory.overall,
                    label: Text('Overall'),
                    icon: Icon(Icons.stars_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: LeaderboardCategory.individual,
                    label: Text('Individual'),
                    icon: Icon(Icons.person_outline, size: 16),
                  ),
                  ButtonSegment(
                    value: LeaderboardCategory.team,
                    label: Text('Team'),
                    icon: Icon(Icons.group_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: LeaderboardCategory.oldTestament,
                    label: Text('Old Testament'),
                    icon: Icon(Icons.menu_book_outlined, size: 16),
                  ),
                ],
                selected: {_selectedCategory},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedCategory = newSelection.first;
                  });
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Builder(
              builder: (context) {
                if (dash.isLoading && dash.allMembers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (dash.error != null && dash.allMembers.isEmpty) {
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
                if (ranked.isEmpty) {
                  return const Center(
                    child: Text('No activity recorded for this week yet.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: dash.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: ranked.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final member = ranked[index];
                      final rank = index + 1;
                      final isMe = member.uid == currentUid;
                      final points = pointsForCategory(member, _selectedCategory);

                      return _LeaderboardRow(
                        rank: rank,
                        member: member,
                        points: points,
                        isMe: isMe,
                        category: _selectedCategory,
                        theme: theme,
                      );
                    },
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

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final MemberSummary member;
  final int points;
  final bool isMe;
  final LeaderboardCategory category;
  final ThemeData theme;

  const _LeaderboardRow({
    required this.rank,
    required this.member,
    required this.points,
    required this.isMe,
    required this.category,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    Color? rankColor;
    IconData? rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFD4AF37); // Gold
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = const Color(0xFFA8A8A8); // Silver
      rankIcon = Icons.military_tech;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankIcon = Icons.military_tech;
    }

    final rowBg = isMe
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
        : (isTop3
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
            : null);

    return Container(
      color: rowBg,
      child: ListTile(
        leading: SizedBox(
          width: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rankIcon != null) ...[
                Icon(rankIcon, color: rankColor, size: 20),
                const SizedBox(width: 2),
              ],
              Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: isTop3 ? FontWeight.bold : FontWeight.w500,
                  color: rankColor ?? theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.name.isNotEmpty ? member.name : 'Member',
                style: TextStyle(
                  fontWeight: (isTop3 || isMe) ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isMe)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'You',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          _subtitleText(member),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isTop3
                ? (rankColor?.withValues(alpha: 0.15) ?? theme.colorScheme.primary.withValues(alpha: 0.1))
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$points pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isTop3 ? rankColor : theme.colorScheme.primary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleText(MemberSummary m) {
    switch (category) {
      case LeaderboardCategory.overall:
        final parts = <String>[];
        if (m.ibsDaysThisWeek > 0) parts.add('${m.ibsDaysThisWeek}d IBS');
        if (m.otDaysThisWeek > 0) parts.add('${m.otDaysThisWeek}d OT');
        if (m.preparedThisWeek) parts.add('Prepared');
        return parts.isEmpty ? 'No activity yet' : parts.join(' • ');
      case LeaderboardCategory.individual:
        return '${m.ibsDaysThisWeek} day(s) read this week';
      case LeaderboardCategory.team:
        return m.preparedThisWeek ? 'Prepared for session' : 'Not yet prepared';
      case LeaderboardCategory.oldTestament:
        return '${m.otDaysThisWeek} day(s) completed this week';
    }
  }
}
