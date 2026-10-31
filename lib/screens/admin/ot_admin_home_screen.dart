import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/ot_state.dart';
import 'ot_edit_week_screen.dart';
import 'ot_overview_screen.dart';

/// Admin navigation hub for Old Testament management.
class OtAdminHomeScreen extends StatelessWidget {
  const OtAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otState = context.watch<OtState>();
    final currentWeek = otState.currentWeek;

    return Scaffold(
      appBar: AppBar(title: const Text('OT Admin Tools')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text('Edit This Week\'s Topic & Plan'),
            subtitle: Text(
              currentWeek != null
                  ? (currentWeek.isBookFinished()
                      ? 'Book finished'
                      : (currentWeek.topic.isNotEmpty
                          ? '${currentWeek.topic} (${currentWeek.startDate})'
                          : '${currentWeek.book ?? "OT"} (${currentWeek.startDate})'))
                  : 'No active week published',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtEditWeekScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Member Overview'),
            subtitle: const Text('View completion stats for this week'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtOverviewScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
