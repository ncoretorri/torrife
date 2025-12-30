import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:torri/models/mono_settings.dart';
import 'package:torri/models/progress.dart';
import 'package:torri/models/seriemask.dart';
import 'package:torri/models/show_detail.dart';
import 'package:torri/models/sysinfo.dart';
import 'package:torri/models/torrent_content.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Backend {
  late Dio _client;

  Backend() {
    _client = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)));
  }

  Future<ShowDetail> getTorrentInfo(String? imdbLink) async {
    var baseUrl = await _getBaseUrl();

    var response = await _client
        .post("$baseUrl/torrent/info", data: {'imdbLink': imdbLink});
    var info = ShowDetail.fromJson(response.data);
    return info;
  }

  Future<List<TorrentData>> getTorrentInfos() async {
    var baseUrl = await _getBaseUrl();

    var response = await _client.get("$baseUrl/torrent");
    List<dynamic> list = response.data;
    return list.map((json) => TorrentData.fromJson(json)).toList();
  }

  Future<List<TorrentContent>> getContent(String hash) async {
    var baseUrl = await _getBaseUrl();

    var response = await _client.get("$baseUrl/torrent/$hash");
    List<dynamic> list = response.data;
    return list.map((json) => TorrentContent.fromJson(json)).toList();
  }

  Future<List<int>> check(String hash) async {
    var baseUrl = await _getBaseUrl();
    var response = await _client.post("$baseUrl/torrent/check",
        data: {'hash': hash},
        options: Options(
            receiveDataWhenStatusError: true,
            validateStatus: (status) => status == 400 || status == 200));
    if (response.statusCode == 400) {
      return List<int>.from(response.data);
    }
    return [];
  }

  Future update(String hash, List<int> active, List<int> inActive) async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/update",
        data: {'hash': hash, 'active': active, 'inActive': inActive});
  }

  Future pause(String hash) async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/pause/$hash");
  }

  Future start(String hash) async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/start/$hash");
  }

  Future stop(String hash) async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/stop/$hash");
  }

  Future delete(String hash) async {
    var baseUrl = await _getBaseUrl();
    await _client.delete("$baseUrl/torrent/$hash");
  }

  Future reset() async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/restart");
  }

  Future startAll() async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/startall");
  }

  Future stopAll() async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/stopall");
  }

  Future pauseAll() async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/pauseall");
  }

  Future addTorrent(Uint8List bytes, String type, String ncoreId, String title,
      String year, bool start, bool addToKodi, bool stream) async {
    var baseUrl = await _getBaseUrl();
    var formData = FormData.fromMap({
      'externalId': ncoreId,
      'addToKodi': addToKodi,
      'title': title,
      'type': type,
      'year': year,
      'start': start,
      'stream': stream,
      'file': MultipartFile.fromBytes(bytes,
          filename: 'torrent',
          contentType: MediaType('application', 'x-bittorrent'))
    });

    await _client.post("$baseUrl/torrent", data: formData);
  }

  Future<SysInfo> info() async {
    var baseUrl = await _getBaseUrl();
    var response = await _client.get("$baseUrl/info");
    return SysInfo.fromJson(response.data);
  }

  Future<Progress> getProgress(String hash) async {
    var baseUrl = await _getBaseUrl();
    var response = await _client.get("$baseUrl/torrent/progress/$hash");
    return Progress.fromJson(response.data);
  }

  Future announce(String hash) async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/announce", data: {'hash': hash});
  }

  Future<List<SerieMask>> getMasks(String hash) async {
    var baseUrl = await _getBaseUrl();
    var response = await _client.get("$baseUrl/SerieMasks/$hash");
    List<dynamic> list = response.data;
    return list.map((json) => SerieMask.fromJson(json)).toList();
  }

  Future updateMasks(String hash, List<SerieMask> masks) async {
    var baseUrl = await _getBaseUrl();
    _client.options.validateStatus = (status) => status == 200 || status == 400;
    var data = {"hash": hash, "serieMasks": masks};
    await _client.put("$baseUrl/SerieMasks",
        data: jsonEncode(data),
        options: Options(headers: {"Content-Type": "application/json"}));
  }

  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    var backendUrl = prefs.getString('backendUrl') ?? '';
    return backendUrl;
  }

  Future<MonoSettings> getMonoSettings() async {
    var baseUrl = await _getBaseUrl();
    var response = await _client.get("$baseUrl/settings");
    return MonoSettings.fromJson(response.data);
  }

  Future updateSettings(MonoSettings settings) async {
    var baseUrl = await _getBaseUrl();
    await _client.put("$baseUrl/settings",
        data: jsonEncode(settings),
        options: Options(headers: {"Content-Type": "application/json"}));
  }
}
