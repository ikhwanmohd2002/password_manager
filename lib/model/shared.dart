class SharedModel {
  final String message;
  final SharedPasswordItem item;

  SharedModel({required this.message, required this.item});

  factory SharedModel.fromJson(Map<String, dynamic> json) {
    return SharedModel(
      message: json['message'],
      item: SharedPasswordItem.fromJson(json['item']),
    );
  }
}

class SharedPasswordItem {
  final String login_username;
  final String login_password;

  SharedPasswordItem(
      {required this.login_username, required this.login_password});

  factory SharedPasswordItem.fromJson(Map<String, dynamic> json) {
    return SharedPasswordItem(
      login_username: json['login_username'],
      login_password: json['login_password'],
    );
  }
}
