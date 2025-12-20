import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/seriemask.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/utils/backend.dart';

class Masks extends StatefulWidget {
  const Masks({super.key, required this.torrent});

  final TorrentData torrent;

  @override
  State<Masks> createState() => _MasksState();
}

class _MasksState extends State<Masks> {
  bool _loading = false;
  final _fixSeason = TextEditingController();
  final _mask = TextEditingController();
  late List<SerieMask> _masks;
  int? _index;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    _mask.dispose();
    _fixSeason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maszkok"),
        actions: [
          IconButton(onPressed: add, icon: Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? Loading()
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    children: <Widget>[
                      for (int index = 0; index < _masks.length; index += 1)
                        ListTile(
                          onTap: () => open(index),
                          key: Key('$index'),
                          title: Text(_masks[index].mask),
                          trailing: IconButton(
                              onPressed: () => remove(index),
                              icon: Icon(Icons.remove)),
                        ),
                    ],
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final SerieMask item = _masks.removeAt(oldIndex);
                        _masks.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: save,
                  child: Text("Mentés"),
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
    );
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    var masks = await getIt<Backend>().getMasks(widget.torrent.hash);

    setState(() {
      _masks = masks;
      _loading = false;
    });
  }

  void add() {
    _index = null;
    showMyDialog();
  }

  void open(int index) {
    var mask = _masks[index];
    _index = index;
    _mask.text = mask.mask;
    _fixSeason.text = mask.fixSeason?.toString() ?? "";
    showMyDialog();
  }

  void remove(int index) {
    _masks.removeAt(index);
    setState(() {
      _masks = _masks;
    });
  }

  Future save() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().updateMasks(widget.torrent.hash, _masks);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hozzáadás'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _mask,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Maszk',
                  ),
                ),
                TextField(
                  controller: _fixSeason,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Fix season',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Mégsem'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                if (_index == null) {
                  _masks.insert(
                      0,
                      SerieMask(
                          _mask.text,
                          _fixSeason.text.isNotEmpty &&
                                  int.tryParse(_fixSeason.text) != null
                              ? int.parse(_fixSeason.text)
                              : null));
                } else {
                  _masks[_index!].mask = _mask.text;
                  _masks[_index!].fixSeason = _fixSeason.text.isNotEmpty &&
                          int.tryParse(_fixSeason.text) != null
                      ? int.parse(_fixSeason.text)
                      : null;
                }
                _mask.text = "";
                _fixSeason.text = "";

                setState(() {
                  _masks = _masks;
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
