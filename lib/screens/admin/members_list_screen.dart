import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/dashboard_state.dart';
import '../../ui/ui.dart';
import 'member_detail_screen.dart';

/// Searchable, sortable list of all members for the admin.
class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.members, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const _MembersListBody(),
    );
  }
}

class _MembersListBody extends StatefulWidget {
  const _MembersListBody();

  @override
  State<_MembersListBody> createState() => _MembersListBodyState();
}

class _MembersListBodyState extends State<_MembersListBody> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardState>();
    final l10n = AppLocalizations.of(context)!;
    final members = dash.filteredMembers;

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: l10n.searchByNameOrUsername,
                hintStyle: AppTextStyles.bodyMuted(),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: dash.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          dash.setSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: dash.setSearch,
            ),
          ),
        ),

        // ── Sort chips + filter chip ────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _ModernSortChip(
                label: l10n.sortByName,
                selected: dash.sort == MemberSort.name,
                onTap: () => dash.setSort(MemberSort.name),
              ),
              const SizedBox(width: 8),
              _ModernSortChip(
                label: l10n.sortByLastActive,
                selected: dash.sort == MemberSort.lastActive,
                onTap: () => dash.setSort(MemberSort.lastActive),
              ),
              const SizedBox(width: 8),
              _ModernSortChip(
                label: l10n.sortByMostActive,
                selected: dash.sort == MemberSort.mostActive,
                onTap: () => dash.setSort(MemberSort.mostActive),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => dash.toggleNeedsEncouragementFilter(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: dash.filterNeedsEncouragement
                        ? const Color(0xFFFDE8E4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: dash.filterNeedsEncouragement
                          ? const Color(0xFFE26D5C)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: dash.filterNeedsEncouragement
                            ? const Color(0xFFE26D5C)
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.needsEncouragementFilter,
                        style: AppTextStyles.label(
                          color: dash.filterNeedsEncouragement
                              ? const Color(0xFFE26D5C)
                              : AppColors.textPrimary,
                          fontWeight: dash.filterNeedsEncouragement
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Members list ────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: dash.refresh,
            child: members.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      EmptyState(
                        icon: Icons.person_search_outlined,
                        title: l10n.noMembersFound,
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final m = members[index];
                      final lastRead = m.lastReadDate != null
                          ? l10n.lastReadDate(m.lastReadDate!)
                          : l10n.noReadingRecorded;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemberDetailScreen(uid: m.uid),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.accentLight,
                                    child: Text(
                                      m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                      style: AppTextStyles.cardTitle(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                m.name,
                                                style: AppTextStyles.cardTitle(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (m.needsEncouragement)
                                              Tooltip(
                                                message: l10n.needsEncouragementFilter,
                                                child: const Icon(
                                                  Icons.favorite,
                                                  size: 18,
                                                  color: Color(0xFFE26D5C),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${m.currentBook} ${m.currentChapter}  •  '
                                          'IBS: ${m.ibsDaysThisWeek}/7  '
                                          'OT: ${m.otDaysThisWeek}/${m.otTotalDaysThisWeek}  '
                                          '${m.preparedThisWeek ? '✓' : '–'}',
                                          style: AppTextStyles.body(fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          lastRead,
                                          style: AppTextStyles.caption(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ModernSortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModernSortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
