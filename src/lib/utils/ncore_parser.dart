import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

import '../models/torrent.dart';

class NcoreParser {
  static Future<void> prepareLoginScreen(WebViewController webView) {
    return webView.runJavaScript('''
document.querySelector("input[name=ne_leptessen_ki]").checked = true;
var meta = document.createElement('meta');
meta.name = "viewport";
meta.content = "width=device-width, initial-scale=1";
document.getElementsByTagName('head')[0].appendChild(meta);
document.getElementById("login_all").style.margin = "0";
document.getElementById("login_all").style.width = "auto";
document.getElementById("login").style.paddingLeft = "0";
document.getElementById("login").style.paddingRight = "0";
''');
  }

  static Future parseTorrents(WebViewController webView) async {
    await webView.runJavaScript('''
var key = document.querySelector("#main_tartalom script").innerText.match(/&key=([^\\\\\\"]+)/)[1];
var host = window.location.hostname;
var torrents = Array.from(document.getElementsByClassName("box_torrent"), node => {
  var id = node.nextElementSibling.nextElementSibling.id;
  return {
    id: id,
    type: node.querySelector(".box_alap_img a").href.split("?tipus=")[1],
    href: "https://" + host + "/torrents.php?action=download&id=" + id + "&key=" + key,
		name: node.querySelector(".box_nev2 a").title,
    uploadedDate: node.querySelector(".box_feltoltve2").innerText.replace("\\n", " "),
    size: node.querySelector(".box_meret2").innerText,
    seeders: node.querySelector(".box_s2").innerText,
    subtitle: node.querySelector(".siterank span:first-child")?.title,
    imdb: node.querySelector(".siterank a.infolink")?.innerText.replace("[", "").replace("]", ""),
    imdbLink: node.querySelector(".siterank a.infolink")?.href.replace("https://dereferer.link/?", "")
  };
});
TorrentList.postMessage(JSON.stringify({
  hasNextPage: document.querySelector("#pager_top .active_link + a").href.indexOf("oldal=") != -1,
  torrents: torrents
}));
''');
  }

  static Future<void> startDownloadTorrentFile(
      WebViewController webView, Torrent torrent) async {
    var javascript = '''
(async() => {
  var result = await fetch("${torrent.href}");
  var blob = await result.blob();
  var base64Blob = await new Promise(r => {
    var reader = new FileReader();
    reader.onload = function() {
        var dataUrl = reader.result;
        var base64 = dataUrl.split(',')[1];
        r(base64)
    };
    reader.readAsDataURL(blob);
  });
  TorrentFile.postMessage(base64Blob);
})();
''';
    await webView.runJavaScript(javascript);
  }

  static Future<List<String>> getHnRTorrentIds(
      WebViewController webView) async {
    var result = await webView.runJavaScriptReturningResult('''
Array.from(document.getElementsByClassName("hnr_all"), node => {
  return {
    id: node.querySelector(".hnr_tname a").href.match(/id=(\\d+)/)[1]
  } 
}).concat(Array.from(document.getElementsByClassName("hnr_all2"), node => {
  return {
    id: node.querySelector(".hnr_tname a").href.match(/id=(\\d+)/)[1]
  } 
})).map(x => x.id);
''');

    Iterable<dynamic> torrentNames = jsonDecode(result as String);
    return List<String>.from(torrentNames.map((item) => item.toString()));
  }
}
