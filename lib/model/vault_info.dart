import 'package:password_manager/model/customUser.dart';

class VaultInfo {
  int id;
  CustomUser owner;
  int? team;
  String name;
  int? totalItems;

  VaultInfo(this.id, this.owner, this.team, this.name, this.totalItems);

  factory VaultInfo.fromJson(Map<String, dynamic> json) => VaultInfo(
        json["id"],
        CustomUser.fromJson(json['owner']),
        json["team"],
        json["name"],
        json["totalItems"],
      );
}
