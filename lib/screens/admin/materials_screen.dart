import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/material_item.dart';
import '../../state/team_state.dart';

/// Admin screen to manage study materials (add, edit, delete).
class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamState = context.watch<TeamState>();
    final materials = teamState.materials;
    final week = teamState.currentWeek;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add material',
            onPressed: week == null
                ? null
                : () => _showEditDialog(context, null, teamState),
          ),
        ],
      ),
      body: week == null
          ? const Center(child: Text('Publish a week first.'))
          : materials.isEmpty
              ? const Center(
                  child: Text('No materials yet. Tap + to add.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: materials.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = materials[i];
                    return ListTile(
                      title: Text(m.title),
                      subtitle: Text(
                        m.published ? 'Published' : 'Draft',
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
          title:
              Text(existing == null ? 'Add Material' : 'Edit Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Body / description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL (optional)',
                    hintText: 'https://…',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                SwitchListTile(
                  title: const Text('Published'),
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
              child: const Text('Cancel'),
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
              child: const Text('Save'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Material?'),
        content: Text('"${m.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await teamState.deleteMaterial(m.id);
    }
  }
}
