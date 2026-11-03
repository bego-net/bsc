import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/bible_books.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../models/reading_entry.dart';
import '../state/auth_state.dart';
import '../state/locale_state.dart';
import '../state/study_state.dart';
import '../ui/ui.dart';
import '../widgets/profile_avatar_button.dart';
import 'book_picker_screen.dart';

/// Screen for the member's daily individual Bible study, chapter & verse controls,
/// reading confirmation, streak tracking, reminder setting, and reading history.
/// Redesigned with a modern, calm, single-hand friendly UI in a soft light theme.
class IndividualScreen extends StatelessWidget {
  const IndividualScreen({super.key});

  /// The font family used for headings supporting Ethiopic and Latin scripts.
  static const String headingFontFamily = 'Noto Sans Ethiopic';

  // Palette constants
  static const Color kBackgroundColor = Color(0xFFF4F1EA);
  static const Color kCardColor = Colors.white;
  static const Color kAccentColor = Color(0xFF2F6F5E);
  static const Color kTextPrimary = Color(0xFF1E2621);
  static const Color kTextSecondary = Color(0xFF656B64);
  static const Color kSurfaceMuted = Color(0xFFECE7DE);
  static const Color kCardBorder = Color(0xFFE4DFD5);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final studyState = context.watch<StudyState>();
    final localeState = Provider.of<LocaleState?>(context);
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode = localeState?.languageCode ?? l10n.localeName;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.individualBsTitle,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        actions: [
          // Log out button
          IconButton(
            icon: const Icon(Icons.logout, color: kTextSecondary),
            tooltip: l10n.logOut,
            onPressed: () => _confirmLogout(context, authState, l10n),
          ),
          const ProfileAvatarButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Offline pending-write indicator
                OfflineIndicator(
                  hasPendingWrites: studyState.hasPendingWrites,
                  isFromCache: false,
                  compact: true,
                ),
                // Header: Greeting with user name and today's date
                _buildGreetingHeader(
                  context,
                  authState,
                  studyState,
                  languageCode,
                  l10n,
                ),
                const SizedBox(height: 16),

                // Hero card (top): "Currently studying", passage, streak, steppers, and Mark as read
                _buildHeroCard(context, studyState, languageCode, l10n),
                const SizedBox(height: 16),

                // Weekly strip: 7 small circles for Mon to Sun
                _buildWeeklyStrip(context, studyState, languageCode, l10n),
                const SizedBox(height: 20),

                // History Section
                _buildHistorySection(context, studyState, languageCode, l10n),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Greeting section showing friendly user greeting and today's date.
  Widget _buildGreetingHeader(
    BuildContext context,
    AuthState authState,
    StudyState studyState,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final userName = authState.user?.name.trim() ?? '';
    final greeting = userName.isNotEmpty
        ? l10n.greetingUser(userName)
        : l10n.greetingGuest;
    final formattedDate = _formatHeaderDate(
      studyState.currentDate,
      languageCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Hero card (top): "Currently studying", book & chapter in large text,
  /// verse range, streak badge (🔥 + count), stepper buttons, and main action button.
  Widget _buildHeroCard(
    BuildContext context,
    StudyState state,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final localizedBook = BibleBooks.getLocalizedName(
      state.currentBook,
      languageCode,
    );

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top header inside card: "Currently studying" + Streak badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.currentlyStudying,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Streak badge (🔥 + number)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3DFC1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    Text(
                      state.streak == 1
                          ? l10n.streakDay(state.streak)
                          : l10n.streakDays(state.streak),
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tappable passage block: Book + Chapter large, and Verse range
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final selectedBook = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) =>
                        BookPickerScreen(currentBook: state.currentBook),
                  ),
                );
                if (selectedBook != null) {
                  state.setBook(selectedBook);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$localizedBook ${state.currentChapter}',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kSurfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.selectBook,
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kAccentColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: kAccentColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () =>
                          _showVerseFromInputDialog(context, state, l10n),
                      borderRadius: BorderRadius.circular(8),
                      child: Text(
                        state.verseFrom == state.verseTo
                            ? '${l10n.verse} ${state.verseFrom}'
                            : '${l10n.verses} ${state.verseFrom}-${state.verseTo}',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: kAccentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: kCardBorder, height: 1),
          const SizedBox(height: 16),

          // Chapter stepper control
          _buildStepperControl(
            label: '${l10n.chapter} (${l10n.chaptersCount(state.maxChapters)})',
            valueText: '${l10n.chapter} ${state.currentChapter}',
            canDecrement: state.currentChapter > 1,
            canIncrement: state.currentChapter < state.maxChapters,
            onDecrement: () => state.previousChapter(),
            onIncrement: () => state.nextChapter(),
            onTapValue: () =>
                _showChapterPicker(context, state, localizedBook, l10n),
          ),
          const SizedBox(height: 14),

          // Verse steppers ("From verse" and "To verse")
          Row(
            children: [
              Expanded(
                child: _buildStepperControl(
                  label: l10n.fromVerse,
                  valueText: '${state.verseFrom}',
                  canDecrement: state.verseFrom > 1,
                  canIncrement: state.verseFrom < 176,
                  onDecrement: () => state.decrementVerseFrom(),
                  onIncrement: () => state.incrementVerseFrom(),
                  onTapValue: () =>
                      _showVerseFromInputDialog(context, state, l10n),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStepperControl(
                  label: l10n.toVerse,
                  valueText: '${state.verseTo}',
                  canDecrement: state.verseTo > state.verseFrom,
                  canIncrement: state.verseTo < 176,
                  onDecrement: () => state.decrementVerseTo(),
                  onIncrement: () => state.incrementVerseTo(),
                  onTapValue: () =>
                      _showVerseToInputDialog(context, state, l10n),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Action button: "Mark as read today" / "Read ✓" with Next chapter
          _buildMainActionButton(context, state, localizedBook, l10n),
        ],
      ),
    );
  }

  /// Big, clear stepper button control (− and +) with rounded chip (min 48px tap targets).
  Widget _buildStepperControl({
    required String label,
    required String valueText,
    required bool canDecrement,
    required bool canIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required VoidCallback onTapValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorder),
          ),
          child: Row(
            children: [
              // Minus button (−)
              SizedBox(
                width: 48,
                height: 48,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                    onTap: canDecrement ? onDecrement : null,
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        size: 22,
                        color: canDecrement ? kTextPrimary : kCardBorder,
                      ),
                    ),
                  ),
                ),
              ),

              // Rounded chip value
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTapValue,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        valueText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Plus button (+)
              SizedBox(
                width: 48,
                height: 48,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(15),
                    ),
                    onTap: canIncrement ? onIncrement : null,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 22,
                        color: canIncrement ? kTextPrimary : kCardBorder,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Full-width main action button at the bottom of the hero card.
  /// Animates cleanly between "Mark as read today" and "Read ✓" state,
  /// then displays "Next chapter" continuation.
  Widget _buildMainActionButton(
    BuildContext context,
    StudyState state,
    String localizedBook,
    AppLocalizations l10n,
  ) {
    final isRead = state.isReadToday;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: !isRead
          ? SizedBox(
              key: const ValueKey('mark_as_read_state'),
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => state.toggleMarkToday(),
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: Text(
                  l10n.markAsReadToday,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          : Column(
              key: const ValueKey('read_completed_state'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Completed button (tap to undo)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => state.toggleMarkToday(),
                    icon: const Icon(
                      Icons.check_circle,
                      color: kAccentColor,
                      size: 22,
                    ),
                    label: Text(
                      '${l10n.readTodayCompleted} (${l10n.undoRead})',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kAccentColor.withValues(alpha: 0.08),
                      side: const BorderSide(color: kAccentColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Next chapter continuation
                if (state.currentChapter < state.maxChapters) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.tonalIcon(
                      onPressed: () => state.nextChapter(),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: Text(
                        '${l10n.advance}: $localizedBook ${state.currentChapter + 1}',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kAccentColor,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kAccentColor.withValues(alpha: 0.14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  /// Weekly strip showing 7 small circles for Mon to Sun,
  /// with days read filled in green and today highlighted.
  Widget _buildWeeklyStrip(
    BuildContext context,
    StudyState state,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final now = state.currentDate;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    // Set of completed date keys
    final completedDates = <String>{};
    for (final entry in state.history) {
      if (entry.completed) {
        completedDates.add(entry.date);
      }
    }
    if (state.isReadToday) {
      completedDates.add(state.todayDateKey);
    }

    final dayLabels = [
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
      l10n.daySun,
    ];

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.thisWeek,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = weekDays[index];
              final dayKey = StudyState.formatDate(day);
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final isRead = completedDates.contains(dayKey);

              final dayNumber = languageCode == 'am'
                  ? _gregorianToEthiopian(day).day
                  : day.day;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabels[index],
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? kAccentColor : kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRead
                          ? kAccentColor
                          : (isToday ? Colors.white : kSurfaceMuted),
                      border: Border.all(
                        color: isRead
                            ? kAccentColor
                            : (isToday ? kAccentColor : kCardBorder),
                        width: isToday ? 2.0 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isRead
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : Text(
                            '$dayNumber',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 14,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isToday ? kAccentColor : kTextSecondary,
                            ),
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// History section: clean list cards with date, passage and check icon,
  /// newest first, with a friendly empty state.
  Widget _buildHistorySection(
    BuildContext context,
    StudyState state,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final entries = state.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            l10n.readingHistory,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),

        if (entries.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kCardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: kSurfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 28,
                      color: kAccentColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noHistoryYet,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.firstStudyPrompt,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isToday = entry.date == state.todayDateKey;
              final localizedRef = entry.localizedReferenceText(languageCode);

              return Card(
                elevation: 0,
                color: kCardColor,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isToday
                        ? kAccentColor.withValues(alpha: 0.4)
                        : kCardBorder,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () =>
                      _showEntryDetails(context, entry, languageCode, l10n),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.completed
                          ? kAccentColor.withValues(alpha: 0.12)
                          : kSurfaceMuted,
                    ),
                    child: Icon(
                      entry.completed
                          ? Icons.check_circle
                          : Icons.remove_circle_outline,
                      color: entry.completed ? kAccentColor : kTextSecondary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    localizedRef,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    entry.date + (isToday ? ' (${l10n.today})' : ''),
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: kTextSecondary,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Opens dialog showing full details of a past reading.
  void _showEntryDetails(
    BuildContext context,
    ReadingEntry entry,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final localizedRef = entry.localizedReferenceText(languageCode);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            localizedRef,
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.portion}: $localizedRef'),
              const SizedBox(height: 4),
              Text('${l10n.date}: ${entry.date}'),
              const SizedBox(height: 4),
              Text(
                '${l10n.status}: ${entry.completed ? l10n.completedStatus : l10n.undoneStatus}',
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.recordedTime}: ${entry.updatedAt.toLocal().toString().split('.').first}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.close,
                style: GoogleFonts.notoSansEthiopic(
                  color: kAccentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Opens a bottom sheet grid picker to quickly select a chapter.
  void _showChapterPicker(
    BuildContext context,
    StudyState state,
    String localizedBook,
    AppLocalizations l10n,
  ) {
    final max = state.maxChapters;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          minChildSize: 0.35,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: kCardBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.selectChapterForBook(localizedBook),
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: max,
                      itemBuilder: (context, index) {
                        final chapter = index + 1;
                        final isSelected = chapter == state.currentChapter;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            state.setChapter(chapter);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kAccentColor
                                  : kBackgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? kAccentColor : kCardBorder,
                              ),
                            ),
                            child: Text(
                              '$chapter',
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : kTextPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Opens a dialog to enter the "From" verse directly.
  void _showVerseFromInputDialog(
    BuildContext context,
    StudyState state,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: '${state.verseFrom}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.enterFromVerse,
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '1 to 176',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.notoSansEthiopic(color: kTextSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kAccentColor),
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val >= 1 && val <= 176) {
                  state.setVerseFrom(val);
                }
                Navigator.of(context).pop();
              },
              child: Text(l10n.save, style: GoogleFonts.notoSansEthiopic()),
            ),
          ],
        );
      },
    );
  }

  /// Opens a dialog to enter the "To" verse directly.
  void _showVerseToInputDialog(
    BuildContext context,
    StudyState state,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: '${state.verseTo}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.enterToVerse,
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '${state.verseFrom} to 176',
              helperText: l10n.cannotBeLowerThanFrom(state.verseFrom),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.notoSansEthiopic(color: kTextSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kAccentColor),
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val >= state.verseFrom && val <= 176) {
                  state.setVerseTo(val);
                }
                Navigator.of(context).pop();
              },
              child: Text(l10n.save, style: GoogleFonts.notoSansEthiopic()),
            ),
          ],
        );
      },
    );
  }

  /// Confirmation dialog before logging out.
  void _confirmLogout(
    BuildContext context,
    AuthState authState,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.logoutConfirmTitle,
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.logoutConfirmMessage,
            style: GoogleFonts.notoSansEthiopic(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.notoSansEthiopic(color: kTextSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kAccentColor),
              onPressed: () {
                Navigator.of(context).pop();
                authState.logOut();
              },
              child: Text(l10n.logOut, style: GoogleFonts.notoSansEthiopic()),
            ),
          ],
        );
      },
    );
  }

  /// Formats date for header display. In Amharic, formats using the Ethiopian calendar.
  String _formatHeaderDate(DateTime date, String languageCode) {
    if (languageCode == 'am') {
      final eth = _gregorianToEthiopian(date);
      final weekday = _amharicWeekdays[date.weekday] ?? '';
      final monthName = _ethiopianMonths[eth.month] ?? '';
      return '$weekday፣ $monthName ${eth.day}';
    }
    try {
      return DateFormat('EEEE, MMMM d', languageCode).format(date);
    } catch (_) {
      try {
        return DateFormat('EEEE, MMMM d').format(date);
      } catch (_) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    }
  }

  /// Converts a Gregorian [DateTime] to Ethiopian calendar (year, month, day).
  static ({int year, int month, int day}) _gregorianToEthiopian(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jdn =
        day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;

    final r = (jdn - 1724221) % 1461;
    final n = (r % 365) + 365 * (r ~/ 1460);
    final ethYear =
        4 * ((jdn - 1724221) ~/ 1461) + (r ~/ 365) - (r ~/ 1460) + 1;
    final ethMonth = n ~/ 30 + 1;
    final ethDay = (n % 30) + 1;

    return (year: ethYear, month: ethMonth, day: ethDay);
  }

  static const Map<int, String> _amharicWeekdays = {
    1: 'ሰኞ',
    2: 'ማክሰኞ',
    3: 'ረቡዕ',
    4: 'ሐሙስ',
    5: 'ዓርብ',
    6: 'ቅዳሜ',
    7: 'እሑድ',
  };

  static const Map<int, String> _ethiopianMonths = {
    1: 'መስከረም',
    2: 'ጥቅምት',
    3: 'ኅዳር',
    4: 'ታኅሣሥ',
    5: 'ጥር',
    6: 'የካቲት',
    7: 'መጋቢት',
    8: 'ሚያዝያ',
    9: 'ግንቦት',
    10: 'ሰኔ',
    11: 'ሐምሌ',
    12: 'ነሐሴ',
    13: 'ጳጉሜ',
  };
}
