class SharedPassword {
  int? shared_password_id;
  int? shared_user_id;
  String? status;

  int? password_id;
  int? user_id;
  String? password_title;
  String? website_url;
  String? password_content;
  DateTime? last_updated;
  DateTime? last_retrieved;

  String? user_name;
  String? user_email;
  String? user_master_password;

  SharedPassword({
    this.shared_password_id,
    this.shared_user_id,
    this.status,
    this.password_id,
    this.user_id,
    this.password_title,
    this.website_url,
    this.password_content,
    this.last_updated,
    this.last_retrieved,
    this.user_name,
    this.user_email,
    this.user_master_password,
  });

  Map<String, dynamic> toJson() => {
        "password_id": password_id.toString(),
        "user_id": user_id.toString(),
        "password_title": password_title,
        "website_url": website_url,
        "password_content": password_content,
      };

  factory SharedPassword.fromJson(Map<String, dynamic> json) => SharedPassword(
        password_id: int.parse(json['password_id']),
        user_id: int.parse(json['user_id']),
        shared_password_id: int.parse(json['shared_password_id']),
        shared_user_id: int.parse(json['shared_user_id']),
        status: json['status'],
        password_title: json['password_title'],
        website_url: json['website_url'],
        password_content: json['password_content'],
        last_updated: DateTime.parse(json['last_updated']),
        last_retrieved: DateTime.parse(json['last_retrieved']),
        user_name: json["user_name"],
        user_email: json["user_email"],
        user_master_password: json["user_master_password"],
      );
}
