import 'package:atsign_atmosphere_app/services/hive/hive_db.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();
  static HiveService _instance = HiveService._();
  factory HiveService() => _instance;
  HiveDataProvider _hiveDataProvider;
  bool _isAutoAccept;

  init() async {
    _hiveDataProvider = HiveDataProvider();
    await Hive.initFlutter();
  }

  isAutoAccept() => _isAutoAccept;

  updateIsAccept(bool value) async {
    await _hiveDataProvider.insertData('isAutoAccept', {'isAutoAccept': value});
    _isAutoAccept = value;
  }

  Future<bool> getIsAccept() async {
    var res = await _hiveDataProvider.readData('isAutoAccept');
    if (res['isAutoAccept'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
