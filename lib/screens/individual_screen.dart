import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/bible_books.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../models/reading_entry.dart';
import '../state/auth_state.dart';
import '../state/locale_state.dart';
import '../state/study_state.dart';
import '../widgets/profile_avatar_button.dart';
import 'book_picker_screen.dart';

/// Screen for the member's daily individual Bible study, chapter & verse controls,
/// reading confirmation, streak tracking, reminder setting, and reading history.
class IndividualScreen extends StatelessWidget {
  const IndividualScreen({super.key});

  /// The font family used for headings supporting Ethiopic and Latin scripts.
  static const String headingFontFamily = 'Noto Sans Ethiopic';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.watch<AuthState>();
    final studyState = context.watch<StudyState>();
    final localeState = Provider.of<LocaleState?>(context);
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode = localeState?.languageCode ?? l10n.localeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.individualBsTitle,
          style: GoogleFonts.getFont(
            headingFontFamily,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Streak indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 4),
                  Text(
                    studyState.streak == 1
                        ? l10n.streakDay(studyState.streak)
                        : l10n.streakDays(studyState.streak),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Log out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logOut,
            onPressed: () => _confirmLogout(context, authState, l10n),
          ),
          const ProfileAvatarButton(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // Top Card: "Currently studying"
              _buildCurrentlyStudyingCard(context, studyState, languageCode, l10n),
              const SizedBox(height: 14),

              // Mark as read today button & Next chapter action
              _buildMarkTodaySection(context, studyState, languageCode, l10n),
              const SizedBox(height: 20),

              // History Section
              _buildHistorySection(context, studyState, languageCode, l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// The top card showing ONLY the book and chapter, with verse number below it,
  /// plus chapter and verse navigation.
  Widget _buildCurrentlyStudyingCard(
    BuildContext context,
    StudyState state,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizedBook = BibleBooks.getLocalizedName(state.currentBook, languageCode);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tap card to change book
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final selectedBook = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => BookPickerScreen(
                      currentBook: state.currentBook,
                    ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.currentlyStudying,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              l10n.selectBook,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Large book and chapter title
                    Text(
                      '$localizedBook ${state.currentChapter}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Verse range below it
                    Text(
                      state.verseFrom == state.verseTo
                          ? '${l10n.verse} ${state.verseFrom}'
                          : '${l10n.verses} ${state.verseFrom}-${state.verseTo}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),

            // Chapter selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.chapter} (${l10n.chaptersCount(state.maxChapters)})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: state.currentChapter > 1
                            ? () => state.previousChapter()
                            : null,
                        visualDensity: VisualDensity.compact,
                      ),
                      InkWell(
                        onTap: () => _showChapterPicker(context, state, localizedBook, l10n),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            '${l10n.chapter} ${state.currentChapter}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: state.currentChapter < state.maxChapters
                            ? () => state.nextChapter()
                            : null,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Verse range: "From verse" and "To verse" steppers
            Row(
              children: [
                // "From verse" stepper
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.fromVerse,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: state.verseFrom > 1
                                  ? () => state.decrementVerseFrom()
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                            InkWell(
                              onTap: () => _showVerseFromInputDialog(context, state, l10n),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Text(
                                  '${state.verseFrom}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: state.verseFrom < 176
                                  ? () => state.incrementVerseFrom()
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // "To verse" stepper
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.toVerse,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: state.verseTo > state.verseFrom
                                  ? () => state.decrementVerseTo()
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                            InkWell(
                              onTap: () => _showVerseToInputDialog(context, state, l10n),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Text(
                                  '${state.verseTo}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: state.verseTo < 176
                                  ? () => state.incrementVerseTo()
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Big "Mark as read today" button and one-tap "Next chapter" continuation.
  Widget _buildMarkTodaySection(
    BuildContext context,
    StudyState state,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRead = state.isReadToday;
    final nextBookName = BibleBooks.getLocalizedName(state.currentBook, languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isRead)
          FilledButton.icon(
            onPressed: () => state.toggleMarkToday(),
            icon: const Icon(Icons.check_circle_outline, size: 22),
            label: Text(
              l10n.markAsReadToday,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        else ...[
          OutlinedButton.icon(
            onPressed: () => state.toggleMarkToday(),
            icon: Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
            label: Text(
              '${l10n.readTodayCompleted} (${l10n.undoRead})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: colorScheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // One-tap Next chapter offer
          if (state.currentChapter < state.maxChapters)
            FilledButton.tonalIcon(
              onPressed: () => state.nextChapter(),
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                '${l10n.advance}: $nextBookName ${state.currentChapter + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ],
    );
  }

  /// Reading history list, newest days first.
  Widget _buildHistorySection(
    BuildContext context,
    StudyState state,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entries = state.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.readingHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        if (entries.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_edu,
                      size: 40,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noHistoryYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.firstStudyPrompt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isToday
                        ? colorScheme.primary.withValues(alpha: 0.4)
                        : colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                color: Colors.white,
                child: ListTile(
                  onTap: () => _showEntryDetails(context, entry, languageCode, l10n),
                  leading: CircleAvatar(
                    backgroundColor: entry.completed
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    child: Icon(
                      entry.completed ? Icons.check : Icons.close,
                      color: entry.completed
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    localizedRef,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.date + (isToday ? ' (${l10n.today})' : ''),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.info_outline, size: 20),
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
          title: Text(localizedRef),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.portion}: $localizedRef'),
              Text('${l10n.date}: ${entry.date}'),
              const SizedBox(height: 6),
              Text('${l10n.status}: ${entry.completed ? l10n.completedStatus : l10n.undoneStatus}'),
              const SizedBox(height: 6),
              Text(
                '${l10n.recordedTime}: ${entry.updatedAt.toLocal().toString().split('.').first}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.selectChapterForBook(localizedBook),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: max,
                      itemBuilder: (context, index) {
                        final chapter = index + 1;
                        final isSelected = chapter == state.currentChapter;
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            state.setChapter(chapter);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$chapter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : null,
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
          title: Text(l10n.enterFromVerse),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '1 to 176',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val >= 1 && val <= 176) {
                  state.setVerseFrom(val);
                }
                Navigator.of(context).pop();
              },
              child: Text(l10n.save),
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
          title: Text(l10n.enterToVerse),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '${state.verseFrom} to 176',
              helperText: l10n.cannotBeLowerThanFrom(state.verseFrom),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val >= state.verseFrom && val <= 176) {
                  state.setVerseTo(val);
                }
                Navigator.of(context).pop();
              },
              child: Text(l10n.save),
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
          title: Text(l10n.logoutConfirmTitle),
          content: Text(l10n.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                authState.logOut();
              },
              child: Text(l10n.logOut),
            ),
          ],
        );
      },
    );
  }
}
