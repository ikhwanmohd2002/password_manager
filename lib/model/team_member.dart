class TeamMember {
  int id;
  int user;
  String username;
  int team;
  String role;
  String team_name;

  TeamMember(
    this.id,
    this.user,
    this.username,
    this.team,
    this.role,
    this.team_name,
  );

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        json["id"],
        json["user"],
        json["username"],
        json["team"],
        json["role"],
        json["team_name"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id.toString(),
      'user': user.toString(),
      'username': username,
      'team': team.toString(),
      'role': role,
      'team_name': team_name,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }
}
