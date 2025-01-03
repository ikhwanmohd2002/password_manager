import 'package:password_manager/model/file1.dart';

class LoginItem {
  final int id;
  final int vault;
  final String loginUsername;
  final String loginPassword;

  LoginItem({
    required this.id,
    required this.vault,
    required this.loginUsername,
    required this.loginPassword,
  });

  factory LoginItem.fromJson(Map<String, dynamic> json) {
    return LoginItem(
      id: json['id'],
      vault: json['vault'],
      loginUsername: json['login_username'],
      loginPassword: json['decrypted_password'],
    );
  }
}

class VaultItems {
  final List<LoginItem> loginItems;
  final List<File1> fileItems;

  VaultItems({required this.loginItems, required this.fileItems});

  factory VaultItems.fromJson(Map<String, dynamic> json) {
    return VaultItems(
      loginItems: (json['login_items'] as List)
          .map((item) => LoginItem.fromJson(item))
          .toList(),
      fileItems: (json['file_items'] as List)
          .map((item) => File1.fromJson(item))
          .toList(),
    );
  }
}
