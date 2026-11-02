import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../state/locale_state.dart';
import '../../state/ot_state.dart';
import '../../ui/ui.dart';
import 'ot_edit_week_screen.dart';
import 'ot_overview_screen.dart';

/// Admin navigation hub for Old Testament management.
class OtAdminHomeScreen extends StatelessWidget {
  const OtAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otState = context.watch<OtState>();
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode =
        Provider.of<LocaleState?>(context)?.languageCode ?? l10n.localeName;
    final currentWeek = otState.currentWeek;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.otAdminTools, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _OtToolCard(
            icon: Icons.edit_calendar_outlined,
            title: l10n.editWeekTopicPlan,
            subtitle: currentWeek != null
                ? (currentWeek.isBookFinished()
                    ? l10n.bookFinishedStatus
                    : (currentWeek.topic.isNotEmpty
                        ? '${currentWeek.topic} (${currentWeek.startDate})'
                        : '${BibleBooks.getLocalizedName(currentWeek.book ?? "OT", languageCode)} (${currentWeek.startDate})'))
                : l10n.noActiveWeekPublished,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtEditWeekScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _OtToolCard(
            icon: Icons.people_outline,
            title: l10n.otMemberOverview,
            subtitle: l10n.viewCompletionStats,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtOverviewScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OtToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OtToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle()),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMuted(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
