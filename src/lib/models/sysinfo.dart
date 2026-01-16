class SysInfo {
  List<Storage> storages = [];

  SysInfo(this.storages);

  factory SysInfo.fromJson(Map<String, dynamic> json) => SysInfo(
      List<Storage>.from(json["storages"].map((j) => Storage.fromJson(j))));
}

class Storage {
  final String name;
  final num freeSpace;
  final num totalSize;

  Storage(this.name, this.freeSpace, this.totalSize);

  factory Storage.fromJson(Map<String, dynamic> json) =>
      Storage(json["name"], json["freeSpace"], json["totalSize"]);
}
