class Vault {
  int id;
  int owner;
  int? team;
  String name;

  Vault(
    this.id,
    this.owner,
    this.team,
    this.name,
  );

  factory Vault.fromJson(Map<String, dynamic> json) => Vault(
        json["id"],
        json["owner"],
        json["team"],
        json["name"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id.toString(),
      'owner': owner.toString(),
      'team': team?.toString(),
      'name': name,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }
}
