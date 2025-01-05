import 'package:password_manager/model/customUser.dart';
import 'package:password_manager/model/vault_info.dart';

class Request {
  int id;
  CustomUser requester;
  VaultInfo team_vault;
  String action;
  String item_type;
  ItemData item_data;
  String status;
  String created_at;
  CustomUser? authorized_by;
  String? authorized_at;

  Request({
    required this.id,
    required this.requester,
    required this.team_vault,
    required this.action,
    required this.item_type,
    required this.item_data,
    required this.status,
    required this.created_at,
    this.authorized_by,
    this.authorized_at,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      requester: CustomUser.fromJson(json['requester']),
      team_vault: VaultInfo.fromJson(json['team_vault']),
      action: json['action'],
      item_type: json['item_type'],
      item_data: ItemData.fromJson(json['item_data']),
      status: json['status'],
      created_at: json['created_at'],
      authorized_by: json['authorized_by'] != null
          ? CustomUser.fromJson(json['authorized_by'])
          : null, // Handle null for authorized_by
      authorized_at: json['authorized_at'], // Handle null for authorized_at
    );
  }
}

class ItemData {
  int? id;
  int? vault;
  String? login_password;
  String? login_username;
  String? file_name;

  ItemData(
      {this.id,
      this.vault,
      this.login_password,
      this.login_username,
      this.file_name});

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['vault'] ?? ''), // Safely parse to int
      vault: json['vault'] is int
          ? json['vault']
          : int.tryParse(json['vault'] ?? ''), // Safely parse to int
      login_password: json['login_password'],
      login_username: json['login_username'],
      file_name: json['file_name'],
    );
  }
}
