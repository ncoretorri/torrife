class SysInfo {
  final num freeSpace;
  final String publicIp;

  SysInfo(this.freeSpace, this.publicIp);

  factory SysInfo.fromJson(Map<String, dynamic> json) =>
      SysInfo(json["freeSpace"], json["publicIp"]);
}
