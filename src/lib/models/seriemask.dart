class SerieMask {
  String mask;
  int? fixSeason;

  SerieMask(this.mask, this.fixSeason);

  factory SerieMask.fromJson(Map<String, dynamic> json) =>
      SerieMask(json["mask"], json["fixSeason"]);

  Map<String, dynamic> toJson() => {'mask': mask, 'fixSeason': fixSeason};
}
