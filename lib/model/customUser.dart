class CustomUser {
  final int id;
  final String username;

  CustomUser({required this.id, required this.username});

  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      id: json['id'],
      username: json['username'],
    );
  }
}
