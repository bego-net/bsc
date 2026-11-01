import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/material_item.dart';
import '../../state/team_state.dart';

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
      appBar: AppBar(
        title: Text(l10n.manageMaterials),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addMaterial,
            onPressed: week == null
                ? null
                : () => _showEditDialog(context, null, teamState),
          ),
        ],
      ),
      body: week == null
          ? Center(child: Text(l10n.publishWeekFirst))
          : materials.isEmpty
              ? Center(child: Text(l10n.noMaterialsYet))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: materials.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = materials[i];
                    return ListTile(
                      title: Text(m.title),
                      subtitle: Text(
                        m.published ? l10n.published : l10n.draft,
                        style: TextStyle(
                          color: m.published ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () =>
                                _showEditDialog(context, m, teamState),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(context, m, teamState),
                          ),
                        ],
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
          title: Text(existing == null ? l10n.addMaterial : l10n.editMaterial),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.title,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.bodyDescription,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: l10n.urlOptional,
                    hintText: 'https://…',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                SwitchListTile(
                  title: Text(l10n.published),
                  value: published,
                  onChanged: (v) =>
                      setDialogState(() => published = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
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
              child: Text(l10n.save),
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
        title: Text(l10n.deleteMaterial),
        content: Text('"${m.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await teamState.deleteMaterial(m.id);
    }
  }
}
