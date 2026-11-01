import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/bible_books.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../models/ot_day.dart';
import '../models/ot_week.dart';
import '../state/auth_state.dart';
import '../state/locale_state.dart';
import '../state/ot_state.dart';
import '../widgets/profile_avatar_button.dart';
import 'admin/ot_admin_home_screen.dart';
import 'admin/ot_edit_week_screen.dart';
import 'ot_history_screen.dart';

/// Screen displaying the active [OtWeek] reading plan for the current week,
/// today's assigned reading with one-tap completion, and streak count.
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
    final localeState = Provider.of<LocaleState?>(context);
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode = localeState?.languageCode ?? l10n.localeName;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.otTitle),
        actions: [
          if (authState.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: l10n.adminTools,
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
            tooltip: l10n.pastWeeks,
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
            tooltip: l10n.refresh,
            onPressed: () => otState.loadData(),
          ),
          const ProfileAvatarButton(),
        ],
      ),
      body: _buildBody(context, otState, colorScheme, languageCode, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OtState otState,
    ColorScheme colorScheme,
    String languageCode,
    AppLocalizations l10n,
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
                child: Text(l10n.retry),
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
                l10n.noOtWeek,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.contactAdminPlan,
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
    final localizedBook = week.book != null
        ? BibleBooks.getLocalizedName(week.book!, languageCode)
        : '';
    final defaultTopic = localizedBook.isNotEmpty
        ? (languageCode == 'am' ? '$localizedBook የዕለት ንባብ' : '$localizedBook Daily Reading')
        : l10n.otPlan;
    final weekTopic = week.topic.isNotEmpty ? week.topic : defaultTopic;

    return RefreshIndicator(
      onRefresh: otState.loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Topic & Progress Card ─────────────────────────────────────────
          _TopicProgressCard(
            otState: otState,
            weekTopic: weekTopic,
            l10n: l10n,
          ),
          const SizedBox(height: 16),

          // ── Today's Reading Highlighted Card / Book Finished ──────────────
          if (isFinished)
            _BookFinishedCard(
              book: localizedBook.isNotEmpty ? localizedBook : (week.book ?? ''),
              isAdmin: context.watch<AuthState>().isAdmin,
              l10n: l10n,
            )
          else if (todayDay != null)
            _TodayHighlightCard(
              todayDay: todayDay,
              isCompleted: otState.isTodayCompleted,
              onToggle: () => otState.toggleDay(todayDay.date),
              languageCode: languageCode,
              l10n: l10n,
            )
          else
            _NoReadingTodayCard(l10n: l10n),
          const SizedBox(height: 16),

          // ── The Week List (with catch-up & locked future days) ───────────
          _WeekDaysList(
            otState: otState,
            languageCode: languageCode,
            l10n: l10n,
          ),
          const SizedBox(height: 16),

          // ── Reminder Switch ───────────────────────────────────────────────
          _ReminderSwitchCard(
            enabled: otState.remindersEnabled,
            onChanged: (val) => otState.setRemindersEnabled(val),
            l10n: l10n,
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
  final AppLocalizations l10n;

  const _TopicProgressCard({
    required this.otState,
    required this.weekTopic,
    required this.l10n,
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
                    l10n.otPlan,
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
                        '${otState.streak}d ${l10n.streakFormatted(otState.streak)}',
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
              l10n.completedDaysProgress(otState.completedDaysCount, otState.totalDaysCount),
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
  final String languageCode;
  final AppLocalizations l10n;

  const _TodayHighlightCard({
    required this.todayDay,
    required this.isCompleted,
    required this.onToggle,
    required this.languageCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final passage = todayDay.localizedPassageText(languageCode);

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
                  l10n.todayReading,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              passage,
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
                      label: Text('${l10n.completedStatus} (${l10n.undoRead})'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.markAsReadToday),
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
  final AppLocalizations l10n;

  const _BookFinishedCard({
    required this.book,
    required this.isAdmin,
    required this.l10n,
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
                  l10n.bookFinished,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.bookFinishedNotice,
              style: theme.textTheme.bodyMedium,
            ),
            if (isAdmin) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                icon: const Icon(Icons.menu_book),
                label: Text(l10n.pickBook),
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
  final AppLocalizations l10n;

  const _NoReadingTodayCard({required this.l10n});

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.event_available_outlined, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.checkBackLater,
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
  final String languageCode;
  final AppLocalizations l10n;

  const _WeekDaysList({
    required this.otState,
    required this.languageCode,
    required this.l10n,
  });

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
                l10n.otPlan,
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
              final localizedPassage = day.localizedPassageText(languageCode);
              final dayDisplayName = day.localizedDayName(languageCode);

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
                  '$dayDisplayName: $localizedPassage',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isFuture ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  isFuture ? '${day.date} (Locked)' : (isToday ? '${day.date} (${l10n.today})' : day.date),
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
  final AppLocalizations l10n;

  const _ReminderSwitchCard({
    required this.enabled,
    required this.onChanged,
    required this.l10n,
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
        title: Text(l10n.otReminders),
        subtitle: Text(l10n.otReminderBody),
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}
