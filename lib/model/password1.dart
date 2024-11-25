class Password1 {
  int? id;
  int? vault;
  String? login_username;
  String? login_password;
  String? decrypted_password;

  Password1({
    this.id,
    this.vault,
    this.login_username,
    this.login_password,
    this.decrypted_password,
  });

  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "vault": vault.toString(),
        "login_username": login_username,
        "login_password": login_password,
      };

  factory Password1.fromJson(Map<String, dynamic> json) => Password1(
        id: json['id'],
        vault: json['vault'],
        login_username: json['login_username'],
        login_password: json['login_password'],
        decrypted_password: json['decrypted_password'],
      );
}
