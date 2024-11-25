class Team {
  int id;
  String name;
  DateTime? created_at;
  String creator;

  Team(
    this.id,
    this.name,
    this.created_at,
    this.creator,
  );

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        json["id"],
        json["name"],
        DateTime.parse(json['created_at']),
        json["creator"],
      );

  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "name": name.toString(),
        "creator": creator,
      };
}
