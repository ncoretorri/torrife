class TorrentData {
  final String displayName;
  final String torrentName;
  final String hash;
  final bool paused;
  num progress;
  final String externalId;
  final num size;
  String status;
  final String torrentType;
  final bool isProcessed;
  final bool organizeFiles;
  final String storage;
  bool hasError;
  List<TorrentData> children = [];

  TorrentData(
      this.displayName,
      this.torrentName,
      this.hash,
      this.progress,
      this.paused,
      this.externalId,
      this.size,
      this.status,
      this.torrentType,
      this.isProcessed,
      this.hasError,
      this.organizeFiles,
      this.storage);

  factory TorrentData.fromJson(Map<String, dynamic> json) => TorrentData(
      json["displayName"],
      json["torrentName"],
      json["hash"],
      json["progress"],
      json["paused"],
      json["externalId"],
      json["size"],
      json["status"],
      json["torrentType"],
      json["isProcessed"],
      json["hasError"],
      json["organizeFiles"],
      json["storage"]);
}
