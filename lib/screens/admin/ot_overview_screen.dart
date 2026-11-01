import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/ot_state.dart';

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
      appBar: AppBar(title: Text(l10n.otMemberOverview)),
      body: otState.overviewLoading
          ? const Center(child: CircularProgressIndicator())
          : week == null
              ? Center(child: Text(l10n.noActiveWeekPublishedDot))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            week.topic,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.weekStartingTotal(
                              week.startDate,
                              overview.length,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: overview.isEmpty
                          ? Center(child: Text(l10n.noMembersRegistered))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: overview.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final item = overview[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      item.name.isNotEmpty
                                          ? item.name[0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(item.email),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.completedDays == item.totalDays &&
                                              item.totalDays > 0
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.displayProgress,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: item.completedDays ==
                                                    item.totalDays &&
                                                item.totalDays > 0
                                            ? Colors.green.shade800
                                            : null,
                                      ),
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
