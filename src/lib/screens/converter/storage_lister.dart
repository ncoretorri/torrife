import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/utils/backend.dart';

class StorageLister extends StatefulWidget {
  const StorageLister(
      {super.key, required this.storageName, required this.relativePath});

  final String storageName;
  final String relativePath;

  @override
  State<StorageLister> createState() => _StorageListerState();
}

class _StorageListerState extends State<StorageLister> {
  bool _loading = false;
  List<Entry> _entries = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("${widget.storageName}/${widget.relativePath}"),
      ),
      body: _loading
          ? Loading()
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                var entry = _entries[index];
                return ListTile(
                    title: Text(entry.name),
                    onTap: () => openSubFolder(entry),
                    trailing: getTrailing(entry));
              },
            ),
    );
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    var entries = await getIt<Backend>()
        .getEntries(widget.storageName, widget.relativePath);

    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  void openSubFolder(Entry entry) {
    if (entry.isDirectory) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorageLister(
            storageName: widget.storageName,
            relativePath: widget.relativePath.isEmpty
                ? entry.name
                : "${widget.relativePath}/${entry.name}",
          ),
        ),
      );
    }
  }

  Future convert(Entry entry) async {
    await getIt<Backend>().queueConvert(
        widget.storageName,
        widget.relativePath.isEmpty
            ? entry.name
            : "${widget.relativePath}/${entry.name}");
    await load();
  }

  Future cancel(Entry entry) async {
    await getIt<Backend>().cancelConvert(
        widget.storageName,
        widget.relativePath.isEmpty
            ? entry.name
            : "${widget.relativePath}/${entry.name}");
    await load();
  }

  Widget getTrailing(Entry entry) {
    if (entry.isFinished) {
      return Text("Kész");
    }
    if (entry.isQueued) {
      return ElevatedButton(
          onPressed: () => cancel(entry), child: Text("Mégsem"));
    }
    return ElevatedButton(
        onPressed: () => convert(entry), child: Text("Konvertálás"));
  }
}
