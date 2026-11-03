import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../state/team_state.dart';
import '../../ui/ui.dart';

/// Admin screen to manage discussion questions (add, edit, delete, reorder).
class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamState = context.watch<TeamState>();
    final l10n = AppLocalizations.of(context)!;
    final questions = teamState.questions;
    final week = teamState.currentWeek;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.manageQuestions, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 28),
            tooltip: l10n.addQuestion,
            onPressed: week == null
                ? null
                : () => _showEditDialog(context, null, teamState),
          ),
        ],
      ),
      body: week == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.edit_calendar_outlined,
                  title: l10n.publishWeekFirst,
                ),
              ),
            )
          : questions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.quiz_outlined,
                      title: l10n.noQuestionsYet,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: questions.length,
                  onReorderItem: (oldIndex, newIndex) {
                    teamState.reorderQuestions(oldIndex, newIndex);
                  },
                  itemBuilder: (_, i) {
                    final q = questions[i];
                    return Padding(
                      key: ValueKey(q.id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReorderableDragStartListener(
                              index: i,
                              child: Container(
                                width: 34,
                                height: 34,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: AppTextStyles.cardTitle(
                                      color: AppColors.accent,
                                    ).copyWith(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.text,
                                    style: AppTextStyles.body(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: q.published
                                          ? AppColors.accentLight
                                          : const Color(0xFFFFF3CD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      q.published ? l10n.published : l10n.draft,
                                      style: AppTextStyles.caption(
                                        color: q.published
                                            ? AppColors.accent
                                            : const Color(0xFF856404),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
                                  onPressed: () => _showEditDialog(context, q, teamState),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, q, teamState),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    Question? existing,
    TeamState teamState,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final textController =
        TextEditingController(text: existing?.text ?? '');
    bool published = existing?.published ?? true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existing == null ? l10n.addQuestion : l10n.editQuestion,
            style: AppTextStyles.titleMedium(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 4,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  labelText: l10n.questionText,
                  labelStyle: AppTextStyles.bodyMuted(),
                  fillColor: AppColors.background,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.accent,
                title: Text(l10n.published, style: AppTextStyles.body()),
                value: published,
                onChanged: (v) => setDialogState(() => published = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel, style: AppTextStyles.label(color: AppColors.textMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) return;
                final next = Question(
                  id: existing?.id ?? '',
                  text: text,
                  order: existing?.order ??
                      (teamState.questions.length + 1),
                  published: published,
                );
                Navigator.pop(ctx);
                await teamState.saveQuestion(next);
              },
              child: Text(l10n.save, style: AppTextStyles.label(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    textController.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Question q,
    TeamState teamState,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteQuestion, style: AppTextStyles.titleMedium()),
        content: Text('"${q.text}"', style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: AppTextStyles.label(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete, style: AppTextStyles.label(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await teamState.deleteQuestion(q.id);
    }
  }
}
