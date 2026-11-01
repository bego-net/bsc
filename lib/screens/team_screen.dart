import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../models/material_item.dart';
import '../models/question.dart';
import '../models/study_week.dart';
import '../state/auth_state.dart';
import '../state/locale_state.dart';
import '../state/team_state.dart';
import '../widgets/profile_avatar_button.dart';
import 'admin/admin_home_screen.dart';

/// Screen displaying the active [StudyWeek] information, questions,
/// materials, and member's prepared checkbox.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TeamState>().loadData();
      }
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final teamState = context.watch<TeamState>();
    final localeState = Provider.of<LocaleState?>(context);
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final languageCode = localeState?.languageCode ?? l10n.localeName;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teamBsTitle),
        actions: [
          if (authState.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: l10n.adminTools,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminHomeScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: l10n.refresh,
            onPressed: () => teamState.loadData(),
          ),
          const ProfileAvatarButton(),
        ],
      ),
      body: _buildBody(context, teamState, colorScheme, languageCode, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TeamState teamState,
    ColorScheme colorScheme,
    String languageCode,
    AppLocalizations l10n,
  ) {
    if (teamState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (teamState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                teamState.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  teamState.clearError();
                  teamState.loadData();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final week = teamState.currentWeek;
    if (week == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noActiveWeek,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.checkBackLater,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final localizedPassage = week.localizedPassageText(languageCode);

    return RefreshIndicator(
      onRefresh: teamState.loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── This Week's Study Card ────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.book_outlined, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.thisWeeksPassage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  localizedPassage,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: week.sessionDay,
                ),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text: week.sessionTime,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: week.place,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Mark as Prepared ──────────────────────────────────────────────
          _PreparedButton(
            isPrepared: teamState.isPrepared,
            onTap: () => teamState.togglePrepared(),
            l10n: l10n,
          ),
          const SizedBox(height: 16),

          // ── Questions ────────────────────────────────────────────────────
          _QuestionsSection(
            questions: teamState.questions,
            title: l10n.discussionQuestions,
            emptyText: l10n.checkBackLater,
          ),
          const SizedBox(height: 16),

          // ── Materials ────────────────────────────────────────────────────
          _MaterialsSection(
            materials: teamState.materials,
            onOpenUrl: _openUrl,
            title: l10n.studyMaterials,
            emptyText: l10n.checkBackLater,
            openLinkText: languageCode == 'am' ? 'ሊንኩን ክፈት →' : 'Open link →',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreparedButton extends StatelessWidget {
  const _PreparedButton({
    required this.isPrepared,
    required this.onTap,
    required this.l10n,
  });
  final bool isPrepared;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: isPrepared
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.check_circle_outline),
              label: Text('${l10n.preparedBadge} (${l10n.undoRead})'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          : FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.markAsPrepared),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
    );
  }
}

class _QuestionsSection extends StatelessWidget {
  const _QuestionsSection({
    required this.questions,
    required this.title,
    required this.emptyText,
  });
  final List<Question> questions;
  final String title;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (questions.isEmpty)
            Text(
              emptyText,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ...questions.asMap().entries.map((e) {
              final idx = e.key + 1;
              final q = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        '$idx',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MaterialsSection extends StatelessWidget {
  const _MaterialsSection({
    required this.materials,
    required this.onOpenUrl,
    required this.title,
    required this.emptyText,
    required this.openLinkText,
  });
  final List<MaterialItem> materials;
  final Future<void> Function(String url) onOpenUrl;
  final String title;
  final String emptyText;
  final String openLinkText;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (materials.isEmpty)
            Text(
              emptyText,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ...materials.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (m.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        m.body,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (m.url != null && m.url!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => onOpenUrl(m.url!),
                        child: Text(
                          openLinkText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
