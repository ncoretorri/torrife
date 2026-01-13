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

  Future delete(String hash, bool removeData, bool removeOrganized) async {
    var baseUrl = await _getBaseUrl();
    var data = {
      "removeData": removeData,
      "removeOrganized": removeOrganized,
    };
    await _client.delete("$baseUrl/torrent/$hash",
        data: jsonEncode(data),
        options: Options(headers: {"Content-Type": "application/json"}));
  }

  Future organize(String hash) async {
    var baseUrl = await _getBaseUrl();
    await _client.post("$baseUrl/torrent/organize/$hash");
  }

  Future addTorrent(
      Uint8List bytes,
      String storage,
      String type,
      String ncoreId,
      String title,
      String year,
      bool start,
      bool organizeFiles,
      bool stream) async {
    var baseUrl = await _getBaseUrl();
    var formData = FormData.fromMap({
      'externalId': ncoreId,
      'organizeFiles': organizeFiles,
      'title': title,
      'type': type,
      'year': year,
      'start': start,
      'stream': stream,
      'storage': storage,
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

  Future<List<SerieMask>> getMasks(String hash) async {
    var baseUrl = await _getBaseUrl();
    var response = await _client.get("$baseUrl/SerieMasks/$hash");
    List<dynamic> list = response.data;
    return list.map((json) => SerieMask.fromJson(json)).toList();
  }

  Future<UpdateMasksResponse> updateMasks(
      String hash, List<SerieMask> masks) async {
    var baseUrl = await _getBaseUrl();
    var data = {"hash": hash, "serieMasks": masks};
    var response = await _client.put("$baseUrl/SerieMasks",
        data: jsonEncode(data),
        options: Options(headers: {"Content-Type": "application/json"}));
    return UpdateMasksResponse.fromJson(response.data);
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

  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    var backendUrl = prefs.getString('backendUrl') ?? '';
    return backendUrl;
  }
}

class UpdateMasksResponse {
  final bool hasMissingRegex;

  UpdateMasksResponse(this.hasMissingRegex);

  factory UpdateMasksResponse.fromJson(Map<String, dynamic> json) =>
      UpdateMasksResponse(json["hasMissingRegex"]);
}
