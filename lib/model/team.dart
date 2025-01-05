class Team {
  int id;
  String name;
  DateTime? created_at;
  String creator;
  int? totalTeamMembers;

  Team(
      {required this.id,
      required this.name,
      this.created_at,
      required this.creator,
      this.totalTeamMembers});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      creator: json['creator'],
      totalTeamMembers: json['totalTeamMembers'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "name": name.toString(),
        "creator": creator,
      };
}
