class Torrent {
  final String id;
  final String? href;
  final String name;
  final String? uploadedDate;
  final String size;
  final String? seeders;
  final String? subtitle;
  final String? imdb;
  final String type;
  final String? imdbLink;

  Torrent(this.id, this.href, this.name, this.uploadedDate, this.size,
      this.seeders, this.subtitle, this.imdb, this.type, this.imdbLink);

  bool isSerie() => type.contains("ser");

  factory Torrent.fromJson(Map<String, dynamic> json) => Torrent(
      json["id"],
      json["href"],
      json["name"],
      json["uploadedDate"],
      json["size"],
      json["seeders"],
      json["subtitle"],
      json["imdb"],
      json["type"],
      json["imdbLink"]);
}
