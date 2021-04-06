class NotificationPayload {
  String name;

  String file;

  double size;

  NotificationPayload({this.name, this.file, this.size});

  NotificationPayload.fromJson(Map<String, dynamic> json) {
    name = json['name'].toString();

    file = json['file'].toString();

    size = double.parse(json['size'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;

    data['file'] = this.file;

    data['size'] = this.size;

    return data;
  }
}
