import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../state/locale_state.dart';
import '../../state/team_state.dart';
import '../../ui/ui.dart';
import 'dashboard_screen.dart';
import 'edit_week_screen.dart';
import 'materials_screen.dart';
import 'overview_screen.dart';
import 'questions_screen.dart';

/// Admin home — lists links to each admin tool.
/// Only reachable from the TeamScreen Admin button (already guarded by isAdmin check).
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamState = context.watch<TeamState>();
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode =
        Provider.of<LocaleState?>(context)?.languageCode ?? l10n.localeName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.adminTools, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _AdminToolCard(
            icon: Icons.edit_calendar_outlined,
            title: l10n.editThisWeeksStudy,
            subtitle: teamState.currentWeek?.localizedPassageText(languageCode) ??
                l10n.noWeekPublished,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EditWeekScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminToolCard(
            icon: Icons.quiz_outlined,
            title: l10n.manageQuestions,
            subtitle: l10n.questionsCount(teamState.questions.length),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QuestionsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminToolCard(
            icon: Icons.library_books_outlined,
            title: l10n.manageMaterials,
            subtitle: l10n.materialsCount(teamState.materials.length),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MaterialsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminToolCard(
            icon: Icons.people_outline,
            title: l10n.memberOverview,
            subtitle: l10n.viewCompletionStats,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OverviewScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminToolCard(
            icon: Icons.dashboard_outlined,
            title: l10n.adminDashboard,
            subtitle: l10n.adminDashboardSubtitle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DashboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.notifications_outlined, size: 18, color: AppColors.textMuted),
              label: Text(
                l10n.testNotification,
                style: AppTextStyles.caption(color: AppColors.textMuted),
              ),
              onPressed: () async {
                await context.read<TeamState>().sendTestNotification();
                if (context.mounted) {
                  final week = context.read<TeamState>().currentWeek;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        week != null
                            ? l10n.testNotificationSent(
                                week.localizedPassageText(languageCode),
                              )
                            : l10n.noWeekToTest,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminToolCard({
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
