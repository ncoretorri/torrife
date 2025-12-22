import 'package:flutter/material.dart';
import 'package:torri/main.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/utils/backend.dart';

class TorrentsState extends ChangeNotifier {
  List<TorrentData> torrents = [];
  final List<TorrentData> _temp = [];

  Future load() async {
    torrents = await getIt<Backend>().getTorrentInfos();
    for (final torrent in torrents) {
      _temp.add(torrent);
    }
    notifyListeners();
  }

  void remove(TorrentData torrent) {
    torrents.remove(torrent);
    notifyListeners();
  }

  void updateStatus(TorrentData torrent, String status) {
    torrent.status = status;
    notifyListeners();
  }

  void group(bool group) {
    if (group) {
      List<TorrentData> list = [];
  
      for (final torrent in torrents) {
        TorrentData? parent;
        for (final torrent2 in list) {
          if (torrent.displayName == torrent2.displayName) {
            parent = torrent2;
            break;
          }
        }

        if (parent == null) {
          torrent.children = [];
          torrent.children.add(torrent);
          list.add(torrent);
        }
        else {
          parent.children.add(torrent);
        }
      }

      torrents = list;
    }
    else {
      torrents = _temp;
      for (final torrent in _temp) {
        torrent.children = [];
      }
    }

    notifyListeners();
  }
}
