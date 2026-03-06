class TorrentProgress {
  final num progress;
  final int peers;
  final int leechs;
  final int seeds;
  final num uploadRate;
  final num downloadRate;
  final String status;

  TorrentProgress(this.progress, this.peers, this.leechs, this.seeds,
      this.uploadRate, this.downloadRate, this.status);

  factory TorrentProgress.fromJson(Map<String, dynamic> json) =>
      TorrentProgress(
          json["progress"],
          json["peers"],
          json["leechs"],
          json["seeds"],
          json["uploadRate"],
          json["downloadRate"],
          json["status"]);
}
