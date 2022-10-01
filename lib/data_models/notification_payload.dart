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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    data['file'] = file;

    data['size'] = size;

    return data;
  }
}
