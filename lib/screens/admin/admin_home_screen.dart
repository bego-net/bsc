import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/team_state.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text('Edit This Week\'s Study'),
            subtitle: Text(
              teamState.currentWeek?.passageText ?? 'No week published',
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
            title: const Text('Manage Questions'),
            subtitle: Text('${teamState.questions.length} question(s)'),
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
            title: const Text('Manage Materials'),
            subtitle: Text('${teamState.materials.length} material(s)'),
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
            title: const Text('Member Overview'),
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

          // ── Hidden test notification button ─────────────────────────────
          // Small, secondary — for verifying notifications work on device.
          // NOTE: flutter_local_notifications does NOT work on Chrome (web).
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.notifications_outlined, size: 16),
              label: const Text(
                '🔔 Test notification',
                style: TextStyle(fontSize: 12),
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
                            ? 'Test notification sent for ${week.passageText}'
                            : 'No week published — nothing to test.',
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
