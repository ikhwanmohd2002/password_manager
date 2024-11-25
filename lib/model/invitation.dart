import 'package:password_manager/model/customUser.dart';
import 'package:password_manager/model/team.dart';

class Invitation {
  int id;
  Team team;
  int recipient;
  CustomUser sender;
  String status;
  DateTime? expiration_date;

  Invitation(
    this.id,
    this.team,
    this.recipient,
    this.sender,
    this.status,
    this.expiration_date,
  );

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
        json["id"],
        Team.fromJson(json['team']),
        json["recipient"],
        CustomUser.fromJson(json['sender']),
        json["status"],
        DateTime.parse(json['expiration_date']),
      );

  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "team": team.toString(),
        "recipient": recipient.toString(),
        "sender": sender.toString(),
        "status": status,
      };
}
