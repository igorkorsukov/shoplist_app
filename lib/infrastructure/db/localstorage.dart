import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'storeobject.dart';

class LocalStorage {
  bool _inited = false;
  late SharedPreferences _prefs;

  LocalStorage._internal();

  static LocalStorage instance() => LocalStorage._internal();

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    // _prefs.clear();
    _inited = true;
  }

  Future<bool> clear() => _prefs.clear();

  String? readRaw(String key) => _prefs.getString(key);
  Future<bool> writeRaw(String key, String value) => _prefs.setString(key, value);

  StoreObject? readObject(String key) {
    String? raw = _prefs.getString(key);
    if (raw == null) {
      return null;
    }
    var jsn = json.decode(raw) as List<dynamic>;
    return StoreObject.fromJson(jsn);
  }

  Future<bool> writeObject(String key, StoreObject obj) {
    var jsn = obj.toJson();
    var str = json.encode(jsn);
    return _prefs.setString(key, str);
  }
}