import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/models/hnr.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/screens/torrents/torrent_detail.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:provider/provider.dart';

class Torrents extends StatefulWidget {
  const Torrents({super.key});

  @override
  State<Torrents> createState() => _TorrentsState();
}

class _TorrentsState extends State<Torrents> {
  final gb = NumberFormat("###.#");
  late NcoreState _ncoreState;
  late TorrentsState _torrentsState;
  bool _loading = false;
  bool? _group = false;

  @override
  void initState() {
    super.initState();
    _ncoreState = Provider.of<NcoreState>(context, listen: false);
    _torrentsState = Provider.of<TorrentsState>(context, listen: false);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Column(
            children: [
              Row(children: [
                Text("Csoportosítás"),
                Checkbox(
                    value: _group,
                    onChanged: (value) => setState(() {
                          _group = value;
                          _torrentsState.group(value == true);
                        })),
                Expanded(child: SizedBox()),
                ElevatedButton(onPressed: load, child: Icon(Icons.refresh))
              ]),
              Expanded(
                child: Consumer<TorrentsState>(
                  builder: (context, state, child) => ListView.separated(
                    itemBuilder: (ctx, index) {
                      var torrent = state.torrents[index];
                      if (torrent.children.length < 2) {
                        return createCard(torrent);
                      } else {
                        return ExpansionTile(
                            title: Text(torrent.displayName),
                            children: [
                              for (var child in torrent.children)
                                createCard(child)
                            ]);
                      }
                    },
                    separatorBuilder: (ctx, int index) => const Divider(),
                    itemCount: state.torrents.length,
                  ),
                ),
              ),
            ],
          );
  }

  Card createCard(TorrentData torrent) {
    var hnr = _ncoreState.hnrs
        .where((hnr) => hnr.externalId == torrent.externalId)
        .firstOrNull;

    return Card(
      child: ListTile(
        title: Row(
          children: [
            Flexible(child: Text(torrent.displayName)),
            SizedBox(
              width: 4.0,
            ),
            if (hnr == null)
              Icon(
                Icons.done,
                color: Colors.green,
              )
            else
              Icon(Icons.upload,
                  color:
                      torrent.status == "Stopped" ? Colors.red : Colors.green),
          ],
        ),
        subtitle: Text(torrent.torrentName),
        trailing: Column(
          children: [
            Text(torrent.status),
            Text("${gb.format(torrent.size / 1000 / 1000 / 1000)}Gb")
          ],
        ),
        onTap: () => openDetails(torrent, hnr),
        tileColor: getTileColor(torrent),
      ),
    );
  }

  Color? getTileColor(TorrentData info) {
    if (!info.organizeFiles) {
      return null;
    }

    if (info.hasError) {
      return Colors.red;
    }

    if (info.isProcessed) {
      return Colors.green.shade900;
    }
    return null;
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    await _ncoreState.loadHnrs();
    await _torrentsState.load();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void openDetails(TorrentData torrent, Hnr? hnr) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TorrentDetail(
                  torrent: torrent,
                  hnr: hnr,
                )));
  }
}
