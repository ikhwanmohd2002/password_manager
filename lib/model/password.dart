class Password {
  int? password_id;
  int? user_id;
  String? password_title;
  String? website_url;
  String? password_content;
  DateTime? last_updated;
  DateTime? last_retrieved;

  Password({
    this.password_id,
    this.user_id,
    this.password_title,
    this.website_url,
    this.password_content,
    this.last_updated,
    this.last_retrieved,
  });

  Map<String, dynamic> toJson() => {
        "password_id": password_id.toString(),
        "user_id": user_id.toString(),
        "password_title": password_title,
        "website_url": website_url,
        "password_content": password_content,
      };

  factory Password.fromJson(Map<String, dynamic> json) => Password(
        password_id: int.parse(json['password_id']),
        user_id: int.parse(json['user_id']),
        password_title: json['password_title'],
        website_url: json['website_url'],
        password_content: json['password_content'],
        last_updated: DateTime.parse(json['last_updated']),
        last_retrieved: DateTime.parse(json['last_retrieved']),
      );
}
