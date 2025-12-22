class Hnr {
  final String externalId;
  final String left;

  Hnr(this.externalId, this.left);

  factory Hnr.fromJson(Map<String, dynamic> json) =>
      Hnr(json["id"], json["left"]);
}