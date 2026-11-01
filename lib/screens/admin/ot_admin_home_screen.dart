import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/bible_books.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../state/locale_state.dart';
import '../../state/ot_state.dart';
import 'ot_edit_week_screen.dart';
import 'ot_overview_screen.dart';

/// Admin navigation hub for Old Testament management.
class OtAdminHomeScreen extends StatelessWidget {
  const OtAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otState = context.watch<OtState>();
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode =
        Provider.of<LocaleState?>(context)?.languageCode ?? l10n.localeName;
    final currentWeek = otState.currentWeek;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otAdminTools)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: Text(l10n.editWeekTopicPlan),
            subtitle: Text(
              currentWeek != null
                  ? (currentWeek.isBookFinished()
                      ? l10n.bookFinishedStatus
                      : (currentWeek.topic.isNotEmpty
                          ? '${currentWeek.topic} (${currentWeek.startDate})'
                          : '${BibleBooks.getLocalizedName(currentWeek.book ?? "OT", languageCode)} (${currentWeek.startDate})'))
                  : l10n.noActiveWeekPublished,
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
            title: Text(l10n.otMemberOverview),
            subtitle: Text(l10n.viewCompletionStats),
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
