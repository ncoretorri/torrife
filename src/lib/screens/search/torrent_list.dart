import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:torri/models/torrent.dart';
import 'package:torri/screens/search/torrent_detail.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:provider/provider.dart';
import 'package:torri/states/torrents_state.dart';

class TorrentList extends StatefulWidget {
  const TorrentList({super.key});

  @override
  State<TorrentList> createState() => _TorrentListState();
}

class _TorrentListState extends State<TorrentList> {
  late TorrentsState _torrentsState;

  @override
  void initState() {
    super.initState();
    _torrentsState = Provider.of<TorrentsState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: Consumer<NcoreState>(
          builder: (context, state, child) => ListView.separated(
              shrinkWrap: true,
              itemCount: state.torrents.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                var torrent = state.torrents[index];
                var uploadedDate = torrent.uploadedDate?.split(" ")[0];
                var uploadedTime = torrent.uploadedDate?.split(" ")[1];
        
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      visualDensity:
                          const VisualDensity(vertical: 4), // to expand
                      onTap: () => selectTorrent(torrent),
                      title: Text(torrent.name),
                      subtitle: Text([
                        torrent.subtitle ?? '',
                        '${torrent.type} ${torrent.imdb ?? ''}'
                      ].where((x) => x != '').join('\n')),
                      leading: Container(
                        decoration: getBoxColor(torrent.type),
                        child: Column(
                          children: [
                            Text(torrent.size),
                            Text(torrent.seeders != null
                                ? '${torrent.seeders} seeder'
                                : ''),
                            torrent.type.endsWith("_hun")
                                ? Flag.fromCode(
                                    FlagsCode.HU,
                                    width: 15.0,
                                    height: 15.0,
                                  )
                                : Flag.fromCode(
                                    FlagsCode.US,
                                    width: 15.0,
                                    height: 15.0,
                                  ),
                          ],
                        ),
                      ),
                      trailing: Column(
                        children: [
                          Visibility(
                              visible:
                                  uploadedTime != null || uploadedDate != null,
                              child: const Text("Feltöltve:")),
                          Text(uploadedDate ?? ""),
                          Text(uploadedTime ?? ""),
                        ],
                      ),
                      tileColor: getTileColor(torrent),
                    ),
                    if (index == state.torrents.length - 1 && state.hasNextPage)
                      ElevatedButton(
                        onPressed: () {
                          state.loadNextPage();
                        },
                        child: Text("Több betöltése.."),
                      )
                  ],
                );
              }),
        ),
      ),
    );
  }

  Color? getTileColor(Torrent torrent) {
    if (_torrentsState.torrents.any((x) => x.externalId == torrent.id)) {
      return Colors.green.shade900;
    }
    
    return null;
  }

  void selectTorrent(Torrent torrent) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TorrentDetail(torrent: torrent)),
    );
  }

  BoxDecoration? getBoxColor(String type) {
    if (type.startsWith("xvid")) {
      return BoxDecoration(color: Colors.blue.withAlpha(120));
    }
    if (type.startsWith("hd")) {
      return BoxDecoration(color: Colors.green.withAlpha(150));
    }

    return null;
  }
}
