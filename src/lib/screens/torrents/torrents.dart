import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/screens/torrents/torrent_detail.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:torri/utils/backend.dart';
import 'package:provider/provider.dart';

class Torrents extends StatefulWidget {
  const Torrents({super.key});

  @override
  State<Torrents> createState() => _TorrentsState();
}

class _TorrentsState extends State<Torrents> {
  late NcoreState _ncoreState;
  late TorrentsState _torrentsState;
  bool _loading = false;

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
              Expanded(
                child: Consumer<TorrentsState>(
                  builder: (context, state, child) => ListView.separated(
                    itemBuilder: (ctx, index) {
                      var torrent = state.torrents[index];
                      return Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              Flexible(child: Text(torrent.displayName)),
                              SizedBox(
                                width: 4.0,
                              ),
                              if (!_ncoreState.hnrIds
                                  .contains(torrent.externalId))
                                Icon(
                                  Icons.done,
                                  color: Colors.green,
                                )
                              else
                                Icon(Icons.upload,
                                    color: torrent.status == "Stopped"
                                        ? Colors.red
                                        : Colors.green),
                            ],
                          ),
                          subtitle: Text(torrent.torrentName),
                          trailing: Text(torrent.status),
                          onTap: () => openDetails(torrent, index),
                          tileColor: getTileColor(torrent),
                        ),
                      );
                    },
                    separatorBuilder: (ctx, int index) => const Divider(),
                    itemCount: state.torrents.length,
                  ),
                ),
              ),
            ],
          );
  }

  Color? getTileColor(TorrentData info) {
    if (info.hasError) {
      return Colors.red;
    }

    if (info.isProcessed) {
      return Colors.green.shade900;
    }
    return null;
  }

  Future startAll() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().startAll();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future stopAll() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().stopAll();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future load() async {
    await _ncoreState.loadHnrs();

    setState(() {
      _loading = true;
    });

    await _torrentsState.load();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void openDetails(TorrentData torrent, int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TorrentDetail(
                  torrent: torrent,
                  index: index,
                )));
  }
}
