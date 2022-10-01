import 'dart:convert';

enum HistoryType { send, received }

class FilesModel {
  String name;
  String handle;
  String date;
  double totalSize;
  HistoryType historyType;

  List<FilesDetail> files;

  FilesModel(
      {this.name,
      this.handle,
      this.date,
      this.files,
      this.historyType,
      this.totalSize});

  FilesModel.fromJson(json) {
    name = json['name'].toString();
    handle = json['handle'].toString();
    date = json['date'].toString();

    totalSize = double.parse(json['total_size'].toString());

    if (json['files'] != null) {
      files = [];
      json['files'].forEach((v) {
        files.add(FilesDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['handle'] = handle;
    data['date'] = date;
    data['total_size'] = totalSize;
    if (files != null) {
      data['files'] = files.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FilesDetail {
  String fileName;
  String filePath;
  double size;
  String type;

  FilesDetail({this.fileName, this.size, this.type, this.filePath});

  FilesDetail.fromJson(json) {
    if (json.runtimeType == String) {
      json = jsonDecode(json);
    }
    fileName = json['file_name'].toString();
    size = double.parse(json['size'].toString());
    type = json['type'].toString();
    filePath = json['file_path'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_name'] = fileName;
    data['size'] = size;
    data['type'] = type;
    data['file_path'] = filePath;
    return data;
  }
}
