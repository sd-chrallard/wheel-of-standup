import 'package:flutter/material.dart';

class ParticipantFormDialog extends StatefulWidget {
  const ParticipantFormDialog({
    super.key,
    required this.title,
    required this.submitLabel,
    this.initialName,
  });

  final String title;
  final String submitLabel;
  final String? initialName;

  @override
  State<ParticipantFormDialog> createState() => _ParticipantFormDialogState();
}

class _ParticipantFormDialogState extends State<ParticipantFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Participant name',
            hintText: 'Enter name',
          ),
          validator: (String? value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Please enter a name.';
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(_nameController.text.trim());
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
