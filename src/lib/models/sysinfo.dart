class SysInfo {
  final num freeSpace;

  SysInfo(this.freeSpace);

  factory SysInfo.fromJson(Map<String, dynamic> json) =>
      SysInfo(json["freeSpace"]);
}
