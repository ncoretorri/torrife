class ShowDetail {
  final String title;
  final int year;
  final String description;
  final String fullData;

  ShowDetail(this.title, this.year, this.description, this.fullData);

  factory ShowDetail.fromJson(Map<String, dynamic> json) => ShowDetail(
      json["title"], json["year"], json["description"], json["fullData"]);
}
