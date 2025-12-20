import 'package:flutter/material.dart';
import 'package:torri/main.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/utils/backend.dart';

class TorrentsState extends ChangeNotifier {
  List<TorrentData> torrents = [];

  Future load() async {
    torrents = await getIt<Backend>().getTorrentInfos();
    notifyListeners();
  }

  void removeAt(int index) {
    torrents.removeAt(index);
    notifyListeners();
  }

  void updateStatus(int index, String status) {
    torrents[index].status = status;
    notifyListeners();
  }
}
