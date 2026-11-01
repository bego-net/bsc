import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../state/locale_state.dart';
import '../../state/team_state.dart';
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
      appBar: AppBar(title: Text(l10n.adminTools)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: Text(l10n.editThisWeeksStudy),
            subtitle: Text(
              teamState.currentWeek?.localizedPassageText(languageCode) ??
                  l10n.noWeekPublished,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EditWeekScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: Text(l10n.manageQuestions),
            subtitle: Text(l10n.questionsCount(teamState.questions.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QuestionsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: Text(l10n.manageMaterials),
            subtitle: Text(l10n.materialsCount(teamState.materials.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MaterialsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(l10n.memberOverview),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OverviewScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: Text(l10n.adminDashboard),
            subtitle: Text(l10n.adminDashboardSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DashboardScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // ── Hidden test notification button ─────────────────────────────
          // Small, secondary — for verifying notifications work on device.
          // NOTE: flutter_local_notifications does NOT work on Chrome (web).
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.notifications_outlined, size: 16),
              label: Text(
                l10n.testNotification,
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
        ],
      ),
    );
  }
}
