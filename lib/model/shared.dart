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

class SharedModelFile {
  final String message;
  final SharedFileItem item;

  SharedModelFile({required this.message, required this.item});

  factory SharedModelFile.fromJson(Map<String, dynamic> json) {
    return SharedModelFile(
      message: json['message'],
      item: SharedFileItem.fromJson(json['item']),
    );
  }
}

class SharedFileItem {
  final String file_name;
  final String file_download_link;

  SharedFileItem({required this.file_name, required this.file_download_link});

  factory SharedFileItem.fromJson(Map<String, dynamic> json) {
    return SharedFileItem(
      file_name: json['file_name'],
      file_download_link: json['file_download_link'],
    );
  }
}
