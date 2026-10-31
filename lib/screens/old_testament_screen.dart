import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ot_day.dart';
import '../state/auth_state.dart';
import '../state/ot_state.dart';
import '../widgets/profile_avatar_button.dart';
import 'admin/ot_admin_home_screen.dart';
import 'admin/ot_edit_week_screen.dart';
import 'ot_history_screen.dart';

/// The Old Testament tab — displays the weekly topic plan, daily reading,
/// catch-up list, streak, reminder toggle, and history.
class OldTestamentScreen extends StatefulWidget {
  const OldTestamentScreen({super.key});

  @override
  State<OldTestamentScreen> createState() => _OldTestamentScreenState();
}

class _OldTestamentScreenState extends State<OldTestamentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OtState>().loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final otState = context.watch<OtState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Old Testament'),
        actions: [
          if (authState.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Admin Tools',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const OtAdminHomeScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Past Weeks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OtHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () => otState.loadData(),
          ),
          const ProfileAvatarButton(),
        ],
      ),
      body: _buildBody(context, otState, colorScheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OtState otState,
    ColorScheme colorScheme,
  ) {
    if (otState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (otState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                otState.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  otState.clearError();
                  otState.loadData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final week = otState.currentWeek;
    if (week == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No Old Testament plan published yet',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your church leaders will publish this week\'s topic and passages soon.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isFinished = otState.isBookFinished;
    final todayDay = otState.todayDay;

    return RefreshIndicator(
      onRefresh: otState.loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Topic & Progress Card ─────────────────────────────────────────
          _TopicProgressCard(
            otState: otState,
            weekTopic: week.topic.isNotEmpty
                ? week.topic
                : (week.book != null
                    ? '${week.book} Daily Reading'
                    : 'Old Testament Reading'),
          ),
          const SizedBox(height: 16),

          // ── Today's Reading Highlighted Card / Book Finished ──────────────
          if (isFinished)
            _BookFinishedCard(
              book: week.book ?? 'Book',
              isAdmin: context.watch<AuthState>().isAdmin,
            )
          else if (todayDay != null)
            _TodayHighlightCard(
              todayDay: todayDay,
              isCompleted: otState.isTodayCompleted,
              onToggle: () => otState.toggleDay(todayDay.date),
            )
          else
            _NoReadingTodayCard(),
          const SizedBox(height: 16),

          // ── The Week List (with catch-up & locked future days) ───────────
          _WeekDaysList(otState: otState),
          const SizedBox(height: 16),

          // ── Reminder Switch ───────────────────────────────────────────────
          _ReminderSwitchCard(
            enabled: otState.remindersEnabled,
            onChanged: (val) => otState.setRemindersEnabled(val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TopicProgressCard extends StatelessWidget {
  final OtState otState;
  final String weekTopic;

  const _TopicProgressCard({
    required this.otState,
    required this.weekTopic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_library_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This Week\'s Topic',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Streak indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${otState.streak}d streak',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              weekTopic,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: otState.progressFraction,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              otState.progressText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayHighlightCard extends StatelessWidget {
  final OtDay todayDay;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _TodayHighlightCard({
    required this.todayDay,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today_outlined, color: colorScheme.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Today\'s Reading',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              todayDay.passageText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: isCompleted
                  ? OutlinedButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Completed ✓  (tap to undo)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as read'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookFinishedCard extends StatelessWidget {
  final String book;
  final bool isAdmin;

  const _BookFinishedCard({
    required this.book,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: colorScheme.secondary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Book finished',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'All chapters for $book have been completed! Great job reading daily.',
              style: theme.textTheme.bodyMedium,
            ),
            if (isAdmin) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('Pick a new book'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const OtEditWeekScreen(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoReadingTodayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.event_available_outlined, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No reading scheduled for today. Catch up on earlier days below!',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDaysList extends StatelessWidget {
  final OtState otState;

  const _WeekDaysList({required this.otState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = OtState.todayDateString;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'Weekly Reading Schedule',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 12),
            ...otState.days.map((day) {
              final isCompleted = otState.readings[day.date] == true;
              final isToday = day.date == today;
              final isFuture = otState.isFutureDay(day.date);

              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: isCompleted
                      ? Colors.green.shade100
                      : isToday
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isFuture
                            ? Icons.lock_outline
                            : Icons.menu_book,
                    size: 14,
                    color: isCompleted
                        ? Colors.green.shade800
                        : isToday
                            ? colorScheme.primary
                            : Colors.grey,
                  ),
                ),
                title: Text(
                  '${day.dayName}: ${day.passageText}',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isFuture ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  isFuture ? '${day.date} (Locked)' : day.date,
                  style: TextStyle(
                    fontSize: 11,
                    color: isFuture ? Colors.grey.shade400 : null,
                  ),
                ),
                trailing: isFuture
                    ? const Icon(Icons.lock, size: 18, color: Colors.grey)
                    : IconButton(
                        icon: Icon(
                          isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isCompleted ? colorScheme.primary : Colors.grey,
                        ),
                        onPressed: () => otState.toggleDay(day.date),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ReminderSwitchCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ReminderSwitchCard({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: SwitchListTile(
        title: const Text('Old Testament reminders'),
        subtitle: const Text('Daily reminder on days with assigned reading'),
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}
