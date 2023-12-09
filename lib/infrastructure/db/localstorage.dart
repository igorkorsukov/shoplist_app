import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'storeobject.dart';

class LocalStorage {
  bool _inited = false;
  late SharedPreferences _prefs;

  LocalStorage._internal();
  static final LocalStorage _instance = LocalStorage._internal();
  static LocalStorage instance() => LocalStorage._instance;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    //_prefs.clear();
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
    // timestamp
    {
      var currentObj = readObject(key);
      obj.records.forEach((id, r) {
        var cr = currentObj?.records[id];
        if (cr != null && cr.timestamp.year != 1970 && cr.payload == r.payload) {
          r.timestamp = cr.timestamp;
        } else {
          r.timestamp = DateTime.timestamp();
        }
      });
    }

    var jsn = obj.toJson();
    var str = json.encode(jsn);
    return _prefs.setString(key, str);
  }
}
