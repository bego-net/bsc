import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/material_item.dart';
import '../../state/team_state.dart';
import '../../ui/ui.dart';

/// Admin screen to manage study materials (add, edit, delete).
class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamState = context.watch<TeamState>();
    final l10n = AppLocalizations.of(context)!;
    final materials = teamState.materials;
    final week = teamState.currentWeek;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.manageMaterials, style: AppTextStyles.titleMedium()),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 28),
            tooltip: l10n.addMaterial,
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
          : materials.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.library_books_outlined,
                      title: l10n.noMaterialsYet,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: materials.length,
                  itemBuilder: (_, i) {
                    final m = materials[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                m.url != null ? Icons.link_outlined : Icons.menu_book_outlined,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.title,
                                    style: AppTextStyles.cardTitle(),
                                  ),
                                  if (m.body.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      m.body,
                                      style: AppTextStyles.bodyMuted(fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: m.published
                                          ? AppColors.accentLight
                                          : const Color(0xFFFFF3CD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.published ? l10n.published : l10n.draft,
                                      style: AppTextStyles.caption(
                                        color: m.published
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
                                  onPressed: () => _showEditDialog(context, m, teamState),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, m, teamState),
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
    MaterialItem? existing,
    TeamState teamState,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController =
        TextEditingController(text: existing?.title ?? '');
    final bodyController =
        TextEditingController(text: existing?.body ?? '');
    final urlController =
        TextEditingController(text: existing?.url ?? '');
    bool published = existing?.published ?? true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existing == null ? l10n.addMaterial : l10n.editMaterial,
            style: AppTextStyles.titleMedium(),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    labelText: l10n.title,
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
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    labelText: l10n.bodyDescription,
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
                TextField(
                  controller: urlController,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration(
                    labelText: l10n.urlOptional,
                    hintText: 'https://…',
                    labelStyle: AppTextStyles.bodyMuted(),
                    hintStyle: AppTextStyles.bodyMuted(),
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
                  keyboardType: TextInputType.url,
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
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                final next = MaterialItem(
                  id: existing?.id ?? '',
                  title: title,
                  body: bodyController.text.trim(),
                  url: urlController.text.trim().isEmpty
                      ? null
                      : urlController.text.trim(),
                  published: published,
                );
                Navigator.pop(ctx);
                await teamState.saveMaterial(next);
              },
              child: Text(l10n.save, style: AppTextStyles.label(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    bodyController.dispose();
    urlController.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MaterialItem m,
    TeamState teamState,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteMaterial, style: AppTextStyles.titleMedium()),
        content: Text('"${m.title}"', style: AppTextStyles.body()),
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
      await teamState.deleteMaterial(m.id);
    }
  }
}
