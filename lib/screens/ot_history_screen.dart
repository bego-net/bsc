import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ot_week.dart';
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
    final history = otState.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Past OT Weeks')),
      body: otState.historyLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text('No previous weeks found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final week = history[i];
                    return _WeekHistoryTile(week: week);
                  },
                ),
    );
  }
}

class _WeekHistoryTile extends StatelessWidget {
  final OtWeek week;

  const _WeekHistoryTile({required this.week});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysCount = week.days.length;

    return ExpansionTile(
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(
        week.topic.isNotEmpty ? week.topic : 'Topic: Untitled',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Started: ${week.startDate} • $daysCount readings',
        style: theme.textTheme.bodySmall,
      ),
      children: [
        if (week.days.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No readings recorded for this week.'),
          )
        else
          ...week.days.map((day) {
            return ListTile(
              dense: true,
              leading: Text(
                day.dayName.isNotEmpty ? day.dayName.substring(0, 3) : '',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(day.passageText),
              subtitle: Text(day.date),
            );
          }),
      ],
    );
  }
}
