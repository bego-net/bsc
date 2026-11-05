import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/member_summary.dart';
import '../services/points.dart';
import '../state/auth_state.dart';
import '../state/dashboard_state.dart';
import '../ui/ui.dart';
import '../widgets/profile_avatar_button.dart';

/// Screen displaying the member leaderboard with categories and weekly points.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardCategory _selectedCategory = LeaderboardCategory.overall;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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
    final l10n = AppLocalizations.of(context)!;
    final ranked = rankedMembers(dash.allMembers, category: _selectedCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.leaderboardTitle,
          style: AppTextStyles.title(),
        ),
        actions: const [
          ProfileAvatarButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // ── Filter Chips Bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        category: LeaderboardCategory.overall,
                        label: l10n.overall,
                        icon: Icons.stars_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        category: LeaderboardCategory.individual,
                        label: l10n.individualCategory,
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        category: LeaderboardCategory.team,
                        label: l10n.teamCategory,
                        icon: Icons.group_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        category: LeaderboardCategory.oldTestament,
                        label: l10n.otCategory,
                        icon: Icons.menu_book_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              if (dash.lastFetched != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${l10n.lastUpdated}: ${_formatTime(dash.lastFetched!)}',
                      style: AppTextStyles.caption(color: AppColors.textMuted),
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // ── Leaderboard List / Podium ────────────────────────────────────
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (dash.isLoading && dash.allMembers.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }
                    if (dash.error != null && dash.allMembers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${l10n.error}: ${dash.error}', style: AppTextStyles.body()),
                              const SizedBox(height: 12),
                              PrimaryButton(
                                label: l10n.retry,
                                onPressed: () => dash.refresh(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (ranked.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: EmptyState(
                            icon: Icons.leaderboard_rounded,
                            title: l10n.noLeaderboardData,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: dash.refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: ranked.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final member = ranked[index];
                          final rank = index + 1;
                          final isMe = member.uid == currentUid;
                          final points = pointsForCategory(member, _selectedCategory);

                          return _LeaderboardItemCard(
                            rank: rank,
                            member: member,
                            points: points,
                            isMe: isMe,
                            l10n: l10n,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required LeaderboardCategory category,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == category;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
            ),
            boxShadow: isSelected ? [] : AppColors.subtleShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardItemCard extends StatelessWidget {
  final int rank;
  final MemberSummary member;
  final int points;
  final bool isMe;
  final AppLocalizations l10n;

  const _LeaderboardItemCard({
    required this.rank,
    required this.member,
    required this.points,
    required this.isMe,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    Color? rankBg;
    Color? rankColor;
    String? rankMedal;

    if (rank == 1) {
      rankBg = const Color(0xFFFEF3C7);
      rankColor = AppColors.gold;
      rankMedal = '🥇';
    } else if (rank == 2) {
      rankBg = const Color(0xFFF3F4F6);
      rankColor = AppColors.silver;
      rankMedal = '🥈';
    } else if (rank == 3) {
      rankBg = const Color(0xFFFDF2E9);
      rankColor = AppColors.bronze;
      rankMedal = '🥉';
    }

    final cardBorder = isMe
        ? Border.all(color: AppColors.accent, width: 2)
        : (rank <= 3
            ? Border.all(color: (rankColor ?? AppColors.border).withValues(alpha: 0.4))
            : Border.all(color: AppColors.border));

    final isAm = Localizations.localeOf(context).languageCode == 'am';

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: cardBorder,
      color: isMe ? AppColors.accent.withValues(alpha: 0.05) : AppColors.card,
      child: Row(
        children: [
          // Rank Badge / Medal
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankBg ?? AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: rankMedal != null
                ? Text(rankMedal, style: const TextStyle(fontSize: 18))
                : Text(
                    '$rank',
                    style: AppTextStyles.caption(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: AppTextStyles.title(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAm ? 'እኔ' : 'You',
                          style: AppTextStyles.caption(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'IBS: ${member.ibsDaysThisWeek}d  •  OT: ${member.otDaysThisWeek}d'
                  '${member.preparedThisWeek ? '  •  ✓ ${l10n.preparedBadge}' : ''}',
                  style: AppTextStyles.caption(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Points Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$points pts',
              style: AppTextStyles.caption(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
