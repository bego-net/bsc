import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/member_overview_item.dart';
import '../../repositories/team_repository.dart';
import '../../state/team_state.dart';
import '../../ui/ui.dart';

/// Read-only admin screen showing all members and their preparation status.
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  List<MemberOverviewItem>? _members;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final teamState = context.read<TeamState>();
      final repo = context.read<TeamRepository>();
      final week = teamState.currentWeek;

      if (week == null) {
        setState(() {
          _members = [];
          _loading = false;
        });
        return;
      }

      final members = await repo.getMemberOverview(week.id);
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final members = _members ?? [];
    final preparedCount = members.where((m) => m.isPrepared).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.memberOverview, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: AppColors.textPrimary),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.couldNotLoadMemberOverview, style: AppTextStyles.body()),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: l10n.retry,
                          onPressed: _load,
                        ),
                      ],
                    ),
                  ),
                )
              : members.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.people_outline,
                          title: l10n.noMembersFound,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Summary card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: AppCard(
                            color: AppColors.accentLight,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.group_outlined, color: AppColors.accent, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.preparedOf(preparedCount, members.length),
                                        style: AppTextStyles.cardTitle(color: AppColors.accent),
                                      ),
                                      const SizedBox(height: 6),
                                      AppProgressBar(
                                        value: members.isEmpty
                                            ? 0.0
                                            : preparedCount / members.length,
                                        fillColor: AppColors.accent,
                                        backgroundColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: members.length,
                            itemBuilder: (_, i) {
                              final m = members[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: AppCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.accentLight,
                                        child: Text(
                                          m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                          style: AppTextStyles.cardTitle(
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.name, style: AppTextStyles.cardTitle()),
                                            if (m.lastReadingDate != null)
                                              Text(
                                                l10n.lastReadingDate(m.lastReadingDate!),
                                                style: AppTextStyles.caption(),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: m.isPrepared
                                              ? AppColors.accentLight
                                              : AppColors.cardBorder.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          m.isPrepared ? Icons.check : Icons.close,
                                          size: 18,
                                          color: m.isPrepared ? AppColors.accent : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
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
