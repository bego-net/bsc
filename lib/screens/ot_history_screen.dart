import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/ot_week.dart';
import '../state/locale_state.dart';
import '../state/ot_state.dart';

/// Screen displaying previous Old Testament study weeks.
class OtHistoryScreen extends StatefulWidget {
  const OtHistoryScreen({super.key});

  @override
  State<OtHistoryScreen> createState() => _OtHistoryScreenState();
}

class _OtHistoryScreenState extends State<OtHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OtState>().loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final otState = context.watch<OtState>();
    final languageCode = context.watch<LocaleState>().languageCode;
    final history = otState.history;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pastWeeks)),
      body: otState.historyLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? Center(child: Text(l10n.noLeaderboardData))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final week = history[i];
                    return _WeekHistoryTile(week: week, languageCode: languageCode, l10n: l10n);
                  },
                ),
    );
  }
}

class _WeekHistoryTile extends StatelessWidget {
  final OtWeek week;
  final String languageCode;
  final AppLocalizations l10n;

  const _WeekHistoryTile({
    required this.week,
    required this.languageCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysCount = week.days.length;

    return ExpansionTile(
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(
        week.topic.isNotEmpty ? week.topic : l10n.otPlan,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${l10n.startDate}: ${week.startDate} • $daysCount',
        style: theme.textTheme.bodySmall,
      ),
      children: [
        if (week.days.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.checkBackLater),
          )
        else
          ...week.days.map((day) {
            return ListTile(
              dense: true,
              leading: Text(
                day.localizedDayName(languageCode),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(day.localizedPassageText(languageCode)),
              subtitle: Text(day.date),
            );
          }),
      ],
    );
  }
}
