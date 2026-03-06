import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:torri/utils/utils.dart';
import 'package:torri/widgets/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/sysinfo.dart';
import 'package:torri/models/torrent.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:torri/utils/backend.dart';
import 'package:provider/provider.dart';

class TorrentDetail extends StatefulWidget {
  const TorrentDetail({super.key, required this.torrent});

  final Torrent torrent;

  @override
  State<TorrentDetail> createState() => _TorrentDetailState();
}

class _TorrentDetailState extends State<TorrentDetail> {
  final String organize = "organize";
  final String start = "start";
  final String stream = "stream";

  final _title = TextEditingController();
  final _year = TextEditingController();
  late NcoreState _ncoreState;
  bool _loading = false;
  String? _description;
  String? _fullData;
  Set<String> _selection = {};
  SysInfo _sysInfo = SysInfo([], []);
  Storage? _storage;
  Set<String> _torrentEngine = {};
  List<Storage> _storages = [];

  @override
  void initState() {
    super.initState();
    _ncoreState = Provider.of<NcoreState>(context, listen: false);
    _title.text = widget.torrent.name;
    _year.text = DateTime.now().year.toString();
    if (!widget.torrent.isSerie()) {
      _selection.add(start);
    }

    _ncoreState.addListener(listener);
    load();
  }

  @override
  void dispose() {
    _ncoreState.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.torrent.name),
          forceMaterialTransparency: true,
        ),
        body: Container(
          padding: EdgeInsets.all(12.0),
          child: _loading
              ? Loading()
              : Column(
                  children: [
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Cím',
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller: _year,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Év',
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: stream, label: Text("Stream")),
                            ButtonSegment(
                                value: organize, label: Text("Rendez")),
                            ButtonSegment(value: start, label: Text("Start")),
                          ],
                          emptySelectionAllowed: true,
                          selected: _selection,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _selection = newSelection;
                            });
                          },
                          multiSelectionEnabled: true,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        SegmentedButton<String>(
                          segments: [
                            for (var engine in _sysInfo.torrentEngines)
                              ButtonSegment(value: engine, label: Text(engine)),
                          ],
                          emptySelectionAllowed: false,
                          selected: _torrentEngine,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _torrentEngine = newSelection;
                              var torrentEngine = _torrentEngine.first;
                              _storages = _sysInfo.storages
                                  .where((x) =>
                                      x.torrentEngines.contains(torrentEngine))
                                  .toList();
                            });
                          },
                          multiSelectionEnabled: false,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        DropdownButton<Storage>(
                          value: _storage,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                              height: 2, color: Colors.deepPurpleAccent),
                          onChanged: (Storage? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _storage = value;
                            });
                          },
                          items: _storages
                              .map<DropdownMenuItem<Storage>>((Storage value) {
                            return DropdownMenuItem<Storage>(
                                value: value,
                                child: Text(
                                    "${value.name} (${Utils.formatBytes(value.freeSpace)})"));
                          }).toList(),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        ElevatedButton(
                            onPressed: downloadFile, child: Text("Letöltés")),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(_description ?? ''),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(_fullData ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ));
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    _sysInfo = await getIt<Backend>().info();
    var torrentEngine = _sysInfo.torrentEngines[0];
    _torrentEngine = {torrentEngine};
    _storages = _sysInfo.storages
        .where((x) => x.torrentEngines.contains(torrentEngine))
        .toList();
    _storage = _storages.isNotEmpty ? _storages[0] : null;

    await _ncoreState.loadDetails(widget.torrent.id);
  }

  Future getTorrentInfo() async {
    var info = await getIt<Backend>().getTorrentInfo(widget.torrent.imdbLink);

    if (mounted) {
      setState(() {
        _title.text = info.title;
        _year.text = info.year.toString();
        _description = info.description;
        _loading = false;
      });
    }
  }

  Future downloadFile() async {
    setState(() {
      _loading = true;
    });

    await _ncoreState.getTorrentFile(widget.torrent, add);
  }

  Future add(Uint8List file) async {
    await getIt<Backend>().addTorrent(
        file,
        _storage!.name,
        widget.torrent.isSerie() ? 'Serie' : 'Movie',
        widget.torrent.id,
        _title.text,
        _year.text,
        _selection.contains(start),
        _selection.contains(organize),
        _selection.contains(stream),
        _torrentEngine.first);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void listener() {
    if (_ncoreState.detail != null && _ncoreState.detail!.title.isNotEmpty) {
      setState(() {
        _selection.add(organize);
        _loading = false;
        _title.text = _ncoreState.detail!.title;
        _year.text = _ncoreState.detail!.year.toString();
        _description = _ncoreState.detail!.description;
        _fullData = _ncoreState.detail!.fullData;
      });
    } else if (widget.torrent.imdbLink != null) {
      getTorrentInfo();
    }
  }
}
