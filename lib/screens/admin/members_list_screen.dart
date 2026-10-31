import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/dashboard_state.dart';
import 'member_detail_screen.dart';

/// Searchable, sortable list of all members for the admin.
class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
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
    final members = dash.filteredMembers;

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name or email…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: dash.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        dash.setSearch('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: dash.setSearch,
          ),
        ),
        // ── Sort chips + filter chip ────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _SortChip(
                label: 'Name',
                selected: dash.sort == MemberSort.name,
                onTap: () => dash.setSort(MemberSort.name),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Last active',
                selected: dash.sort == MemberSort.lastActive,
                onTap: () => dash.setSort(MemberSort.lastActive),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Most active',
                selected: dash.sort == MemberSort.mostActive,
                onTap: () => dash.setSort(MemberSort.mostActive),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Needs encouragement'),
                selected: dash.filterNeedsEncouragement,
                onSelected: (_) => dash.toggleNeedsEncouragementFilter(),
              ),
            ],
          ),
        ),
        // ── Members list ────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: dash.refresh,
            child: members.isEmpty
                ? const Center(child: Text('No members found.'))
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final m = members[index];
                      final lastRead = m.lastReadDate != null
                          ? 'Last read: ${m.lastReadDate}'
                          : 'No reading recorded';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                          ),
                        ),
                        title: Text(m.name),
                        subtitle: Text(
                          '${m.currentBook} ${m.currentChapter}  •  '
                          'IBS: ${m.ibsDaysThisWeek}/7  '
                          'OT: ${m.otDaysThisWeek}/${m.otTotalDaysThisWeek}  '
                          '${m.preparedThisWeek ? '✓' : '–'}\n'
                          '$lastRead',
                        ),
                        isThreeLine: true,
                        trailing: m.needsEncouragement
                            ? const Tooltip(
                                message: 'Needs encouragement',
                                child:
                                    Icon(Icons.favorite, color: Colors.orange),
                              )
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberDetailScreen(uid: m.uid),
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

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
