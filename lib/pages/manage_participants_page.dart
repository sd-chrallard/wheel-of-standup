import 'package:flutter/material.dart';

import '../models/participant.dart';
import '../state/participants_controller.dart';
import '../widgets/participant_form_dialog.dart';

class ManageParticipantsPage extends StatelessWidget {
  const ManageParticipantsPage({super.key, required this.controller});

  static const String routeName = '/participants';

  final ParticipantsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Participants')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          final List<Participant> participants = controller.participants;

          if (participants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'No participants yet.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Add names to populate the wheel.'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add participant'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: participants.length,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final Participant participant = participants[index];
              return Card(
                child: ListTile(
                  title: Text(participant.name),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditDialog(context, participant),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, participant),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add'),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (_) => const ParticipantFormDialog(
        title: 'Add Participant',
        submitLabel: 'Add',
      ),
    );

    if (name == null) {
      return;
    }

    final String? error = await controller.addParticipant(name);
    if (!context.mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    Participant participant,
  ) async {
    final String? updatedName = await showDialog<String>(
      context: context,
      builder: (_) => ParticipantFormDialog(
        title: 'Edit Participant',
        submitLabel: 'Save',
        initialName: participant.name,
      ),
    );

    if (updatedName == null) {
      return;
    }

    final String? error = await controller.updateParticipant(
      id: participant.id,
      rawName: updatedName,
    );

    if (!context.mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Participant participant,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove participant?'),
          content: Text('Delete ${participant.name} from the wheel?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await controller.removeParticipant(participant.id);
  }
}
