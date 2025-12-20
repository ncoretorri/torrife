class ShowDetail {
  final String title;
  final int year;
  final String description;

  ShowDetail(this.title, this.year, this.description);

  factory ShowDetail.fromJson(Map<String, dynamic> json) =>
      ShowDetail(json["title"], json["year"], json["description"]);
}
