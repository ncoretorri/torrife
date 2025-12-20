class TorrentContent {
  final int index;
  final String name;
  final num size;
  final num percentComplete;
  bool wanted;
  bool hasError;

  TorrentContent(this.index, this.name, this.wanted, this.size,
      this.percentComplete, this.hasError);

  factory TorrentContent.fromJson(Map<String, dynamic> json) => TorrentContent(
      json["index"],
      json["name"],
      json["wanted"],
      json["size"],
      json["percentComplete"],
      json["hasError"]);
}
