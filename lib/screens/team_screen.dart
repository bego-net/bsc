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
import '../ui/ui.dart';
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
    try {
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.offlineLinkNotice)),
        );
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.offlineLinkNotice)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final teamState = context.watch<TeamState>();
    final localeState = Provider.of<LocaleState?>(context);
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
          l10n.teamBsTitle,
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
                    builder: (_) => const AdminHomeScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: AppColors.textSecondary),
            tooltip: l10n.refresh,
            onPressed: () => teamState.loadData(),
          ),
          const ProfileAvatarButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildBody(context, teamState, languageCode, l10n),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TeamState teamState,
    String languageCode,
    AppLocalizations l10n,
  ) {
    if (teamState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (teamState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                teamState.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.retry,
                onPressed: () {
                  teamState.clearError();
                  teamState.loadData();
                },
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
          padding: const EdgeInsets.all(20),
          child: EmptyState(
            icon: Icons.calendar_today_outlined,
            title: l10n.noActiveWeek,
            subtitle: l10n.checkBackLater,
          ),
        ),
      );
    }

    final localizedPassage = week.localizedPassageText(languageCode);

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: teamState.loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Offline pending-write indicator
          OfflineIndicator(
            hasPendingWrites: teamState.hasPendingWrites,
            isFromCache: false,
            compact: true,
          ),
          // ── Hero Card: This Week's Passage & Session Info ─────────────────────
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.thisWeeksPassage,
                      style: AppTextStyles.caption(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatChip.accent(l10n.teamBs),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  localizedPassage,
                  style: AppTextStyles.headingLarge(),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),
                _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  text: week.sessionDay,
                ),
                const SizedBox(height: 8),
                _InfoItem(
                  icon: Icons.access_time_outlined,
                  text: week.sessionTime,
                ),
                const SizedBox(height: 8),
                _InfoItem(
                  icon: Icons.location_on_outlined,
                  text: week.place,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Mark as Prepared Large Button ────────────────────────────────────
          PrimaryButton(
            label: teamState.isPrepared
                ? '${l10n.preparedBadge} (${l10n.undoRead})'
                : l10n.markAsPrepared,
            icon: teamState.isPrepared ? Icons.check_circle : Icons.check_circle_outline,
            isOutlined: teamState.isPrepared,
            onPressed: () => teamState.togglePrepared(),
          ),
          const SizedBox(height: 20),

          // ── Questions Section ────────────────────────────────────────────────
          SectionTitle(title: l10n.discussionQuestions),
          const SizedBox(height: 6),
          if (teamState.questions.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  l10n.checkBackLater,
                  style: AppTextStyles.subtitle(),
                ),
              ),
            )
          else
            ...teamState.questions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final question = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuestionCard(index: index, question: question),
              );
            }),
          const SizedBox(height: 16),

          // ── Materials Section ────────────────────────────────────────────────
          SectionTitle(title: l10n.studyMaterials),
          const SizedBox(height: 6),
          if (teamState.materials.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  l10n.checkBackLater,
                  style: AppTextStyles.subtitle(),
                ),
              ),
            )
          else
            ...teamState.materials.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MaterialCard(
                  item: m,
                  onOpenUrl: _openUrl,
                  linkText: languageCode == 'am' ? 'ሊንኩን ክፈት →' : 'Open link →',
                ),
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;

  const _QuestionCard({required this.index, required this.question});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: AppTextStyles.caption(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.text,
              style: AppTextStyles.body(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialItem item;
  final Future<void> Function(String url) onOpenUrl;
  final String linkText;

  const _MaterialCard({
    required this.item,
    required this.onOpenUrl,
    required this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.title(),
                ),
              ),
            ],
          ),
          if (item.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.body,
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ],
          if (item.url != null && item.url!.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => onOpenUrl(item.url!),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      linkText,
                      style: AppTextStyles.button(color: AppColors.accent),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accent),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
