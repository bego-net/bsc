import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member_overview_item.dart';
import '../../repositories/team_repository.dart';
import '../../state/team_state.dart';

/// Read-only admin screen showing all members and their preparation status.
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  List<MemberOverviewItem>? _members;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final teamState = context.read<TeamState>();
      final repo = context.read<TeamRepository>();
      final week = teamState.currentWeek;

      if (week == null) {
        setState(() {
          _members = [];
          _loading = false;
        });
        return;
      }

      final members = await repo.getMemberOverview(week.id);
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load member overview.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _members ?? [];
    final preparedCount = members.where((m) => m.isPrepared).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : members.isEmpty
                  ? const Center(child: Text('No members found.'))
                  : Column(
                      children: [
                        // Summary banner
                        Container(
                          width: double.infinity,
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Text(
                            '$preparedCount of ${members.length} prepared',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: members.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final m = members[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    m.name.isNotEmpty
                                        ? m.name[0].toUpperCase()
                                        : '?',
                                  ),
                                ),
                                title: Text(m.name),
                                subtitle: m.lastReadingDate != null
                                    ? Text(
                                        'Last reading: ${m.lastReadingDate}',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    : null,
                                trailing: m.isPrepared
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.grey,
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
