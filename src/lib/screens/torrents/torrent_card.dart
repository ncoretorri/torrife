import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:torri/main.dart';
import 'package:torri/models/hnr.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/screens/torrents/torrent_detail.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:torri/utils/backend.dart';
import 'package:torri/utils/utils.dart';
import 'package:torri/widgets/delete_dialog.dart';

class TorrentCard extends StatefulWidget {
  const TorrentCard({super.key, required this.torrent, required this.hnr});

  final TorrentData torrent;
  final Hnr? hnr;

  @override
  State<TorrentCard> createState() => _TorrentCardState();
}

class _TorrentCardState extends State<TorrentCard> {
  bool _loading = false;
  late TorrentsState _torrentsState;

  @override
  void initState() {
    _torrentsState = Provider.of<TorrentsState>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openDetails(widget.torrent, widget.hnr),
      child: Container(
        color: getTileColor(widget.torrent),
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                getIcon(),
                SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    widget.torrent.displayName,
                    maxLines: 1,
                    style: TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.0),
            LinearProgressIndicator(
              color: Colors.green[200],
              value: widget.torrent.progress / 100,
            ),
            SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward),
                          SizedBox(
                            width: 94.0,
                            child: Text(
                                Utils.formatBytes(widget.torrent.downloadRate)),
                          ),
                          Icon(Icons.arrow_upward),
                          SizedBox(
                            width: 94.0,
                            child: Text(
                                Utils.formatBytes(widget.torrent.uploadRate)),
                          ),
                        ],
                      ),
                      Text(widget.torrent.torrentName),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  child: Column(
                    children: [
                      Text(Utils.formatBytes(widget.torrent.size)),
                      Text(widget.torrent.storage),
                      if (_loading)
                        LoadingAnimationWidget.waveDots(
                          color: Colors.white,
                          size: 18,
                        )
                      else
                        Row(
                          children: [
                            if (widget.torrent.status == "Stopped")
                              IconButton(
                                  onPressed: start,
                                  icon: Icon(Icons.play_circle_outline_sharp))
                            else
                              IconButton(
                                onPressed: stop,
                                icon: Icon(Icons.stop),
                              ),
                            if (widget.hnr == null)
                              IconButton(
                                  onPressed: () {
                                    showAlertDialog(context);
                                  },
                                  icon: Icon(Icons.delete)),
                          ],
                        )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
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

  void openDetails(TorrentData torrent, Hnr? hnr) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TorrentDetail(
                  torrent: torrent,
                  hnr: hnr,
                )));
  }

  Icon getIcon() {
    if (widget.torrent.status != "Stopped") {
      if (widget.torrent.progress == 100) {
        return Icon(Icons.upload, color: Colors.green);
      } else {
        return Icon(Icons.download, color: Colors.green);
      }
    }

    return Icon(
      Icons.done,
      color: widget.hnr == null ? Colors.green : Colors.red,
    );
  }

  Future stop() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().stop(widget.torrent.hash);

    setState(() {
      _torrentsState.updateStatus(widget.torrent, "Stopped");
      _loading = false;
    });
  }

  Future start() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().start(widget.torrent.hash);

    setState(() {
      _torrentsState.updateStatus(widget.torrent, "Started");
      _loading = false;
    });
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(deleteTorrent: deleteTorrent);
      },
    );
  }

  Future deleteTorrent(bool removeData, bool removeOrganized) async {
    setState(() {
      _loading = true;
    });

    Navigator.of(context).pop();

    await getIt<Backend>()
        .delete(widget.torrent.hash, removeData, removeOrganized);

    setState(() {
      _loading = false;
      _torrentsState.remove(widget.torrent);
    });
  }
}
