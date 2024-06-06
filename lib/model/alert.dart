class Alert {
  int? alert_id;
  int? user_id;
  String? type;
  String? description;
  String? status;
  DateTime? dateTime;

  Alert(
      {this.alert_id,
      this.user_id,
      this.status,
      this.type,
      this.description,
      this.dateTime});

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        user_id: int.parse(json['user_id']),
        alert_id: int.parse(json['alert_id']),
        type: json['type'],
        status: json['status'],
        description: json['description'],
        dateTime: DateTime.parse(json['dateTime']),
      );
}
