import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({super.key, required this.deleteTorrent});
  final Function deleteTorrent;

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool? removeData = false;
  bool? removeOrganized = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Törlés"),
      content: SizedBox(
        height: 119,
        child: Column(
          children: [
            Text("Biztos törlöd a torrentet?"),
            Row(
              children: [
                Expanded(child: SizedBox()),
                Text("Adat törlése"),
                Checkbox(
                  value: removeData,
                  onChanged: (bool? value) {
                    setState(() {
                      removeData = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: SizedBox()),
                Text("Rendezés törlése"),
                Checkbox(
                  value: removeOrganized,
                  onChanged: (bool? value) {
                    setState(() {
                      removeOrganized = value;
                    });
                  },
                ),
              ],
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
          onPressed: () => widget.deleteTorrent(removeData, removeOrganized),
        )
      ],
    );
  }
}
