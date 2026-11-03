import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/ot_week.dart';
import '../state/locale_state.dart';
import '../state/ot_state.dart';
import '../ui/ui.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.pastWeeks, style: AppTextStyles.title()),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: otState.historyLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: EmptyState(
                            icon: Icons.history_rounded,
                            title: l10n.noLeaderboardData,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: history.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final week = history[i];
                          return _WeekHistoryCard(
                            week: week,
                            languageCode: languageCode,
                            l10n: l10n,
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}

class _WeekHistoryCard extends StatelessWidget {
  final OtWeek week;
  final String languageCode;
  final AppLocalizations l10n;

  const _WeekHistoryCard({
    required this.week,
    required this.languageCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final daysCount = week.days.length;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: const Border(),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_month_outlined, color: AppColors.accent, size: 18),
        ),
        title: Text(
          week.topic.isNotEmpty ? week.topic : l10n.otPlan,
          style: AppTextStyles.title(),
        ),
        subtitle: Text(
          '${l10n.startDate}: ${week.startDate} • $daysCount',
          style: AppTextStyles.caption(),
        ),
        children: [
          const Divider(color: AppColors.border, height: 1),
          if (week.days.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.checkBackLater, style: AppTextStyles.subtitle()),
            )
          else
            ...week.days.map((day) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Text(
                  day.localizedDayName(languageCode),
                  style: AppTextStyles.caption(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  day.localizedPassageText(languageCode),
                  style: AppTextStyles.body(),
                ),
                subtitle: Text(day.date, style: AppTextStyles.caption()),
              );
            }),
        ],
      ),
    );
  }
}
