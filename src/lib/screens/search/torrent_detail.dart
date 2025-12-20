import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
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
  final _title = TextEditingController();
  final _year = TextEditingController();
  late NcoreState _ncoreState;
  bool _loading = false;
  bool? _startDownload;
  String? _description;

  @override
  void initState() {
    super.initState();
    _ncoreState = Provider.of<NcoreState>(context, listen: false);
    _title.text = widget.torrent.name;
    _year.text = DateTime.now().year.toString();
    _startDownload = !widget.torrent.isSerie();

    print(widget.torrent.id);

    if (widget.torrent.imdbLink != null) getTorrentInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.torrent.name)),
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
                        Text("Start?"),
                        Checkbox(
                          value: _startDownload,
                          onChanged: (value) => setState(() {
                            _startDownload = value;
                          }),
                        ),
                        ElevatedButton(
                            onPressed: downloadFile, child: Text("Letöltés")),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(_description ?? ''),
                    ),
                  ],
                ),
        ));
  }

  Future getTorrentInfo() async {
    setState(() {
      _loading = true;
    });

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
        widget.torrent.isSerie() ? 'Serie' : 'Movie',
        widget.torrent.id,
        _title.text,
        _year.text,
        _startDownload == true);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
