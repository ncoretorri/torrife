import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/hnr.dart';
import 'package:torri/models/node_data.dart';
import 'package:torri/models/progress.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/screens/torrents/masks.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:torri/utils/backend.dart';
import 'package:provider/provider.dart';

class TorrentDetail extends StatefulWidget {
  const TorrentDetail({super.key, required this.torrent, required this.hnr});

  final TorrentData torrent;
  final Hnr? hnr;

  @override
  State<TorrentDetail> createState() => _TorrentDetailState();
}

class _TorrentDetailState extends State<TorrentDetail> {
  final f = NumberFormat("###.#");
  final gb = NumberFormat("###.#");
  late TorrentsState _torrentsState;
  late Progress _progress;
  TreeNode<NodeData> tree = TreeNode.root();
  bool _loading = false;
  Timer? _timer;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _torrentsState = Provider.of<TorrentsState>(context, listen: false);
    _progress =
        Progress(widget.torrent.progress, 0, 0, 0, 0, 0, widget.torrent.status);

    updateProgress();
    load();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(widget.torrent.displayName),
        actions: [
          if (widget.torrent.status == 'Stopped')
            IconButton(
                onPressed: start, icon: Icon(Icons.play_circle_outline_sharp)),
          if (widget.torrent.status != 'Stopped')
            IconButton(onPressed: pause, icon: Icon(Icons.pause)),
          if (widget.torrent.status != 'Stopped')
            IconButton(onPressed: stop, icon: Icon(Icons.stop)),
          // if (widget.hnr == null)
          IconButton(
              onPressed: () {
                showAlertDialog(context);
              },
              icon: Icon(Icons.delete)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? Loading()
            : Column(
                children: [
                  Row(
                    children: [
                      Text("Letöltve: ${f.format(_progress.progress)}%"),
                      SizedBox(
                        width: 24,
                      ),
                      Text(
                          "Méret: ${gb.format(widget.torrent.size / 1000 / 1000 / 1000)}Gb"),
                      SizedBox(
                        width: 24,
                      ),
                      Text(_progress.status)
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                          "d/u: ${gb.format(_progress.downloadRate / 1000 / 1000)}/${gb.format(_progress.uploadRate / 1000 / 1000)} Mb/s"),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                          "p/s/l: ${_progress.peers}/${_progress.seeds}/${_progress.leechs}"),
                      if (widget.hnr != null)
                        SizedBox(
                          width: 12,
                        ),
                      if (widget.hnr != null) Text("hnr: ${widget.hnr!.left}")
                    ],
                  ),
                  Row(
                    children: [
                      Text("Tároló: ${widget.torrent.storage}"),
                      SizedBox(
                        width: 12,
                      ),
                      if (_progress.status == "Downloading")
                        Text("eta: ${calculateEta()}")
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: organize,
                        child: Text("Rendez"),
                      ),
                      if (widget.torrent.torrentType == "Serie")
                        SizedBox(
                          width: 12,
                        ),
                      if (widget.torrent.torrentType == "Serie")
                        ElevatedButton(
                          onPressed: openMasks,
                          child: Text("Maszkok"),
                        ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Expanded(
                    child: TreeView.simple<NodeData>(
                        showRootNode: true,
                        builder: (ctx, node) => ListTile(
                              textColor: getTextColor(node.data!),
                              leading: Checkbox(
                                value: node.data!.downloading,
                                tristate: true,
                                onChanged: (v) => checkboxClicked(node),
                              ),
                              trailing: node.data!.data != null
                                  ? Column(
                                      children: [
                                        Text(
                                            "${gb.format(node.data!.data!.size / 1000 / 1000)}Mb"),
                                        Text(
                                            "${f.format(node.data!.data!.percentComplete)}%")
                                      ],
                                    )
                                  : null,
                              title: Text(node.data!.title),
                            ),
                        tree: tree),
                  ),
                ],
              ),
      ),
    );
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    var response = await getIt<Backend>().getContent(widget.torrent.hash);

    var root = TreeNode<NodeData>(
        key: widget.torrent.displayName.replaceAll('.', ' '),
        data: NodeData(widget.torrent.displayName, null));

    for (var c in response) {
      var parts = c.name.split('/');

      ListenableNode node = root;
      for (var i = 0; i < parts.length; i++) {
        var key = parts[i].replaceAll('.', ' ');

        if (!node.children.containsKey(key)) {
          var data =
              (i == parts.length - 1) ? NodeData(key, c) : NodeData(key, null);
          var n = TreeNode(key: key, data: data);
          node.add(n);

          var b = node as TreeNode<NodeData>;
          if (b.data != null) {
            b.data!.children.add(data);
          }

          node = n;
        } else {
          node = node.elementAt(key);
        }
      }
    }

    if (mounted) {
      setState(() {
        tree = root;
        _loading = false;
      });
    }
  }

  Future organize() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().organize(widget.torrent.hash);

    setState(() {
      _loading = false;
    });
  }

  void checkboxClicked(TreeNode<NodeData> node) {
    node.data!.downloading = node.data!.downloading == true ? false : true;
    updateTree();
  }

  void updateTree() {
    var t = tree;
    setState(() {
      tree = TreeNode<NodeData>.root();
    });

    setState(() {
      tree = t;
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

  Future updateProgress() async {
    if (_removing) {
      return;
    }
    var progress = await getIt<Backend>().getProgress(widget.torrent.hash);

    if (mounted && !_removing) {
      setState(() {
        _progress = progress;
        widget.torrent.progress = _progress.progress;
      });

      _torrentsState.updateStatus(widget.torrent, _progress.status);

      _timer = Timer(const Duration(seconds: 3), updateProgress);
    }
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

  Future pause() async {
    await getIt<Backend>().pause(widget.torrent.hash);
    _torrentsState.updateStatus(widget.torrent, "Paused");
  }

  Future maskUpdate(bool hasMissingRegex) async {
    setState(() {
      widget.torrent.hasError = hasMissingRegex;
    });

    await load();
  }

  void openMasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Masks(
          torrent: widget.torrent,
          updateResult: maskUpdate,
        ),
      ),
    );
  }

  Color? getTextColor(NodeData nodeData) {
    if (nodeData.hasError ||
        (widget.torrent.torrentType == "Serie" &&
            nodeData.data != null &&
            nodeData.data!.hasError)) {
      return Colors.red;
    }
    return null;
  }

  String calculateEta() {
    if (_progress.downloadRate == 0) {
      return "---";
    }

    var leftBytes = widget.torrent.size * ((100 - _progress.progress) / 100);
    var leftSeconds = leftBytes / _progress.downloadRate;

    return "${f.format(leftSeconds / 60)} p";
  }

  Future deleteTorrent(bool removeData, bool removeOrganized) async {
    _removing = true;

    setState(() {
      _loading = true;
    });

    Navigator.of(context).pop();

    await getIt<Backend>()
        .delete(widget.torrent.hash, removeData, removeOrganized);
    _torrentsState.remove(widget.torrent);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

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
