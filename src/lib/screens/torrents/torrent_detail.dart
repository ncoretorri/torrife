import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/hnr.dart';
import 'package:torri/models/progress.dart';
import 'package:torri/models/torrent_content.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/screens/torrents/masks.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:torri/utils/backend.dart';
import 'package:provider/provider.dart';

class NodeData {
  final String title;
  final TorrentContent? data;
  List<NodeData> children = [];

  bool get isLeaf => data != null;

  bool? get downloading {
    if (isLeaf) {
      return data!.wanted;
    }

    if (children.isNotEmpty) {
      if (children.every((x) => x.downloading == true)) {
        return true;
      }

      if (children.every((x) => x.downloading == false)) {
        return false;
      }
    }

    return null;
  }

  set downloading(bool? value) {
    if (isLeaf) {
      data!.wanted = value == true ? true : false;
    } else {
      for (var x in children) {
        x.downloading = value;
      }
    }
  }

  bool get hasError {
    if (isLeaf) {
      return data!.hasError;
    }

    if (children.isNotEmpty) {
      return children.any((x) => x.hasError);
    }

    return false;
  }

  set hasError(bool value) {
    if (isLeaf) {
      data!.hasError = value;
    }
  }

  NodeData(this.title, this.data);
}

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
          if (widget.hnr == null)
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
                      if (_progress.status == "Downloading")
                        Text("eta: ${calculateEta()}")
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  if (widget.torrent.torrentType == "Serie")
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: openMasks,
                          child: Text("Maszkok"),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
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

  Future announce() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().announce(widget.torrent.hash);

    setState(() {
      _loading = false;
    });
  }

  Future reset() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().reset();

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

  Future navigationPressed(int index) async {
    setState(() {
      _loading = true;
    });

    var backend = getIt<Backend>();
    switch (index) {
      case 0:
        var errors = await backend.check(widget.torrent.hash);
        setErrors(tree, errors);
        updateTree();
        if (errors.isNotEmpty && mounted) {
          showError(context);
        }
        break;

      case 1:
        List<int> active = [];
        List<int> inActive = [];
        loadDownloadStatus(tree, active, inActive);
        await backend.update(widget.torrent.hash, active, inActive);
        break;

      case 2:
        showAlertDialog(context);
        break;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void loadDownloadStatus(
      TreeNode<NodeData> node, List<int> active, List<int> inActive) {
    if (node.data != null && node.data!.isLeaf) {
      if (node.data!.downloading == true) {
        active.add(node.data!.data!.index);
      } else {
        inActive.add(node.data!.data!.index);
      }
    }

    for (var n in node.childrenAsList) {
      loadDownloadStatus(n as TreeNode<NodeData>, active, inActive);
    }
  }

  void setErrors(TreeNode<NodeData> node, List<int> errors) {
    if (node.data != null && node.data!.isLeaf) {
      node.data!.hasError = errors.contains(node.data!.data!.index);
    }

    for (var n in node.childrenAsList) {
      setErrors(n as TreeNode<NodeData>, errors);
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Mégsem"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Mehet"),
      onPressed: () => deleteTorrent(),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Törlés"),
      content: Text("Biztos törlöd a torrentet?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showError(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Mégsem"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Hiba"),
      content: Text("Hiányzó maszk"),
      actions: [
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future deleteTorrent() async {
    _removing = true;

    setState(() {
      _loading = true;
    });

    Navigator.of(context).pop();

    await getIt<Backend>().delete(widget.torrent.hash);
    _torrentsState.remove(widget.torrent);

    if (mounted) {
      Navigator.of(context).pop();
    }
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

  void openMasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Masks(torrent: widget.torrent)),
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
}
