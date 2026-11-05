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
import '../ui/ui.dart';
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
    final localeState = context.watch<LocaleState?>();
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode = localeState?.languageCode ?? l10n.localeName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.otTitle,
          style: AppTextStyles.title(),
        ),
        actions: [
          if (authState.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.textPrimary),
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
            icon: const Icon(Icons.history_outlined, color: AppColors.textSecondary),
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
            icon: const Icon(Icons.refresh_outlined, color: AppColors.textSecondary),
            tooltip: l10n.refresh,
            onPressed: () => otState.loadData(),
          ),
          const ProfileAvatarButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildBody(context, otState, languageCode, l10n),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OtState otState,
    String languageCode,
    AppLocalizations l10n,
  ) {
    if (otState.isLoading && otState.currentWeek == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (otState.errorMessage != null && otState.currentWeek == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Not available offline yet',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.retry,
                onPressed: () {
                  otState.clearError();
                  otState.loadData();
                },
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
          padding: const EdgeInsets.all(20),
          child: EmptyState(
            icon: Icons.menu_book_outlined,
            title: l10n.noOtWeek,
            subtitle: l10n.contactAdminPlan,
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
      color: AppColors.accent,
      onRefresh: otState.loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Offline pending-write indicator
          OfflineIndicator(
            hasPendingWrites: otState.hasPendingWrites,
            isFromCache: false,
            compact: true,
          ),
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

          // ── Reminder Switch Card ──────────────────────────────────────────
          _ReminderSwitchCard(
            enabled: otState.remindersEnabled,
            onChanged: (val) => otState.setRemindersEnabled(val),
            l10n: l10n,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

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
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.otPlan,
                style: AppTextStyles.caption(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StatChip.streak('${otState.streak}d ${l10n.streakFormatted(otState.streak)}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weekTopic,
            style: AppTextStyles.headingLarge(),
          ),
          const SizedBox(height: 16),
          AppProgressBar(
            value: otState.progressFraction,
            height: 8,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.completedDaysProgress(otState.completedDaysCount, otState.totalDaysCount),
            style: AppTextStyles.caption(),
          ),
        ],
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
    final passage = todayDay.localizedPassageText(languageCode);

    return AppCard(
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.35), width: 1.5),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.today_rounded, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.todayReading,
                style: AppTextStyles.caption(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            passage,
            style: AppTextStyles.headingLarge(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: isCompleted
                ? '${l10n.completedStatus} (${l10n.undoRead})'
                : l10n.markAsReadToday,
            icon: isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            isOutlined: isCompleted,
            onPressed: onToggle,
          ),
        ],
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
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.bookFinished,
                style: AppTextStyles.title(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bookFinishedNotice,
            style: AppTextStyles.body(),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            PrimaryButton(
              icon: Icons.menu_book,
              label: l10n.pickBook,
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
    );
  }
}

class _NoReadingTodayCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _NoReadingTodayCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.event_available_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.checkBackLater,
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ),
        ],
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
    final today = OtState.todayDateString;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              l10n.otPlan,
              style: AppTextStyles.title(),
            ),
          ),
          const Divider(color: AppColors.border, height: 16),
          ...otState.days.map((day) {
            final isCompleted = otState.readings[day.date] == true;
            final isToday = day.date == today;
            final isFuture = otState.isFutureDay(day.date);
            final localizedPassage = day.localizedPassageText(languageCode);
            final dayDisplayName = day.localizedDayName(languageCode);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : isToday
                          ? AppColors.surfaceMuted
                          : AppColors.background,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.accent
                        : isToday
                            ? AppColors.accent
                            : AppColors.border,
                    width: isToday ? 1.8 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isFuture
                          ? Icons.lock_outline
                          : Icons.menu_book,
                  size: 18,
                  color: isCompleted
                      ? AppColors.accent
                      : isToday
                          ? AppColors.accent
                          : AppColors.textMuted,
                ),
              ),
              title: Text(
                '$dayDisplayName: $localizedPassage',
                style: AppTextStyles.body(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isFuture ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                isFuture
                    ? '${day.date} (Locked)'
                    : (isToday ? '${day.date} (${l10n.today})' : day.date),
                style: AppTextStyles.caption(
                  color: isFuture ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
              trailing: isFuture
                  ? const Icon(Icons.lock, size: 20, color: AppColors.textMuted)
                  : IconButton(
                      icon: Icon(
                        isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isCompleted ? AppColors.accent : AppColors.textSecondary,
                      ),
                      onPressed: () => otState.toggleDay(day.date),
                    ),
            );
          }),
        ],
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
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.accent,
        title: Text(l10n.otReminders, style: AppTextStyles.title()),
        subtitle: Text(l10n.otReminderBody, style: AppTextStyles.subtitle()),
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}
