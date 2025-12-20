import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:torri/models/torrent.dart';
import 'package:torri/utils/ncore_parser.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NcoreState extends ChangeNotifier {
  List<Torrent> _torrents = [];
  Function(Uint8List)? _callback;

  String _searchTerm = '';
  String _orderBy = '';
  bool _hasNextPage = false;
  int _page = 1;

  late WebViewController controller;
  bool loggedIn = false;
  List<String> hnrIds = [];

  UnmodifiableListView<Torrent> get torrents => UnmodifiableListView(_torrents);
  bool get hasNextPage => _hasNextPage;

  NcoreState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0")
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: pageLoaded,
      ))
      ..addJavaScriptChannel('TorrentFile',
          onMessageReceived: torrentFileDownloaded)
      ..addJavaScriptChannel('TorrentList',
          onMessageReceived: torrentListLoaded)
      ..loadRequest(Uri.parse('https://ncore.pro/hitnrun.php'));
  }

  Future getTorrentFile(Torrent torrent, Function(Uint8List) callback) async {
    _callback = callback;
    await NcoreParser.startDownloadTorrentFile(controller, torrent);
  }

  Future<void> torrentFileDownloaded(JavaScriptMessage message) async {
    if (_callback != null) {
      var bytes = base64.decode(message.message);
      _callback!(bytes);
    }
  }

  Future<void> pageLoaded(String url) async {
    if (!url.startsWith('https://ncore.pro')) {
      loggedIn = false;
      notifyListeners();
      loadHnrs();
      return;
    }

    if (url.startsWith("https://ncore.pro/login.php")) {
      loggedIn = false;

      await NcoreParser.prepareLoginScreen(controller);
    } else {
      if (url.startsWith("https://ncore.pro/torrents.php")) {
        await NcoreParser.parseTorrents(controller);
      } else if (url.startsWith("https://ncore.pro/hitnrun.php")) {
        hnrIds = await NcoreParser.getHnRTorrentIds(controller);
        print(hnrIds);
      }

      loggedIn = true;
    }

    notifyListeners();
  }

  Future loadHnrs() async {
    await controller.loadRequest(Uri.parse('https://ncore.pro/hitnrun.php'));
  }

  Future startSearch(String searchTerm, String orderBy) async {
    _page = 1;
    _searchTerm = searchTerm;
    _orderBy = orderBy;
    var uri = createUri();
    await controller.loadRequest(uri);
  }

  void torrentListLoaded(JavaScriptMessage p1) {
    dynamic l = jsonDecode(p1.message);
    var torrents =
        List<Torrent>.from(l["torrents"].map((item) => Torrent.fromJson(item)));

    if (_page == 1) {
      _torrents = torrents;
    } else {
      _torrents.addAll(torrents);
    }

    _hasNextPage = l["hasNextPage"];
    notifyListeners();
  }

  Future loadNextPage() async {
    if (_hasNextPage) {
      _page++;

      var uri = createUri();
      await controller.loadRequest(uri);
    }
  }

  Uri createUri() {
    var link = 'https://ncore.pro/torrents.php?';

    if (_page != 1) {
      link = '${link}oldal=$_page&';
    }

    link =
        '${link}tipus=kivalasztottak_kozott&kivalasztott_tipus=xvid_hun,xvid,hd_hun,hd,xvidser_hun,xvidser,hdser_hun,hdser';

    if (_searchTerm.isNotEmpty) {
      link = '$link&mire=$_searchTerm&miben=name';
    }

    link = '$link&miszerint=$_orderBy&hogyan=DESC';
    log(link);

    return Uri.parse(link);
  }
}
