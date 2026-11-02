import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/ot_state.dart';
import '../../ui/ui.dart';

/// Read-only admin overview of member progress for the current Old Testament week.
class OtOverviewScreen extends StatefulWidget {
  const OtOverviewScreen({super.key});

  @override
  State<OtOverviewScreen> createState() => _OtOverviewScreenState();
}

class _OtOverviewScreenState extends State<OtOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OtState>().loadOverview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final otState = context.watch<OtState>();
    final l10n = AppLocalizations.of(context)!;
    final overview = otState.overview;
    final week = otState.currentWeek;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.otMemberOverview, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: otState.overviewLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : week == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: l10n.noActiveWeekPublishedDot,
                    ),
                  ),
                )
              : Column(
                  children: [
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
                              child: const Icon(Icons.menu_book, color: AppColors.accent, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    week.topic,
                                    style: AppTextStyles.cardTitle(color: AppColors.accent),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.weekStartingTotal(
                                      week.startDate,
                                      overview.length,
                                    ),
                                    style: AppTextStyles.caption(color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: overview.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: EmptyState(
                                  icon: Icons.people_outline,
                                  title: l10n.noMembersRegistered,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: overview.length,
                              itemBuilder: (context, i) {
                                final item = overview[i];
                                final isAllDone = item.completedDays == item.totalDays && item.totalDays > 0;

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
                                            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
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
                                              Text(item.name, style: AppTextStyles.cardTitle()),
                                              Text(item.email, style: AppTextStyles.caption()),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isAllDone
                                                ? AppColors.accentLight
                                                : AppColors.cardBorder.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${item.completedDays} / ${item.totalDays}',
                                            style: AppTextStyles.label(
                                              color: isAllDone ? AppColors.accent : AppColors.textMuted,
                                              fontWeight: FontWeight.w700,
                                            ),
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
