import 'package:flutter/material.dart';

class RenameDialog extends StatefulWidget {
  const RenameDialog(
      {super.key, required this.displayName, required this.renameTorrent});
  final String displayName;
  final Function renameTorrent;

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  final _displayName = TextEditingController();
  bool _displayNameError = false;

  @override
  void initState() {
    super.initState();
    _displayName.text = widget.displayName;
  }

  @override
  void dispose() {
    _displayName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Átnevezés"),
      content: SizedBox(
        height: 119,
        child: Column(
          children: [
            TextField(
              controller: _displayName,
              onChanged: (_) {
                if (_displayNameError && _displayName.text.trim().isNotEmpty) {
                  setState(() {
                    _displayNameError = false;
                  });
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Cím',
                errorText: _displayNameError ? '' : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Mégsem"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Mehet"),
          onPressed: () => widget.renameTorrent(_displayName.text.trim()),
        )
      ],
    );
  }
}
