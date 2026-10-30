import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question.dart';
import '../../state/team_state.dart';

/// Admin screen to manage discussion questions (add, edit, delete, reorder).
class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamState = context.watch<TeamState>();
    final questions = teamState.questions;
    final week = teamState.currentWeek;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add question',
            onPressed: week == null
                ? null
                : () => _showEditDialog(context, null, teamState),
          ),
        ],
      ),
      body: week == null
          ? const Center(child: Text('Publish a week first.'))
          : questions.isEmpty
              ? const Center(child: Text('No questions yet. Tap + to add.'))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: questions.length,
                  onReorderItem: (oldIndex, newIndex) {
                    teamState.reorderQuestions(oldIndex, newIndex);
                  },
                  itemBuilder: (_, i) {
                    final q = questions[i];
                    return ListTile(
                      key: ValueKey(q.id),
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle),
                      ),
                      title: Text(q.text),
                      subtitle: Text(
                        q.published ? 'Published' : 'Draft',
                        style: TextStyle(
                          color: q.published ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () =>
                                _showEditDialog(context, q, teamState),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(context, q, teamState),
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
    Question? existing,
    TeamState teamState,
  ) async {
    final textController =
        TextEditingController(text: existing?.text ?? '');
    bool published = existing?.published ?? true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Question' : 'Edit Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Question text',
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                title: const Text('Published'),
                value: published,
                onChanged: (v) => setDialogState(() => published = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
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
              child: const Text('Save'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question?'),
        content: Text('"${q.text}"'),
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
      await teamState.deleteQuestion(q.id);
    }
  }
}
