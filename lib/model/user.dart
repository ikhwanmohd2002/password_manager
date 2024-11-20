class User {
  int id;
  String username;
  String email;
  String password1;
  String password2;

  User(
    this.id,
    this.username,
    this.email,
    this.password1,
    this.password2,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
        int.parse(json["id"]),
        json["username"],
        json["email"],
        json["password1"],
        json["password2"],
      );

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'username': username,
        'email': email,
        'password1': password1,
        'password2': password2,
      };
}
