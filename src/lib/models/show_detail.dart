class ShowDetail {
  final String title;
  final String year;
  final String others;
  final String description;
  final List<Comment> comments;

  ShowDetail(
      this.title, this.year, this.others, this.description, this.comments);

  factory ShowDetail.fromJson(Map<String, dynamic> json) => ShowDetail(
      json["title"],
      json["year"],
      json["others"],
      json["description"],
      List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))));
}

class Comment {
  final String sender;
  final String message;

  Comment(this.sender, this.message);

  factory Comment.fromJson(Map<String, dynamic> json) =>
      Comment(json["sender"], json["message"]);
}
