class SysInfo {
  final List<Storage> storages;
  final List<String> torrentEngines;

  SysInfo(this.storages, this.torrentEngines);

  factory SysInfo.fromJson(Map<String, dynamic> json) => SysInfo(
      List<Storage>.from(json["storages"].map((j) => Storage.fromJson(j))),
      List<String>.from(json["torrentEngines"].map((e) => e.toString())));
}

class Storage {
  final String name;
  final num freeSpace;
  final num totalSize;
  final List<String> torrentEngines;

  Storage(this.name, this.freeSpace, this.totalSize, this.torrentEngines);

  factory Storage.fromJson(Map<String, dynamic> json) => Storage(
      json["name"],
      json["freeSpace"],
      json["totalSize"],
      List<String>.from(json["torrentEngines"].map((e) => e.toString())));
}
