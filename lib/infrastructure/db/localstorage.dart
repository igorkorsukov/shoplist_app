import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../subscription/channel.dart';
import '../uid/id.dart';
import 'storeobject.dart';

class LocalStorage {
  bool _inited = false;
  late SharedPreferences _prefs;
  final String _namesKey = "object_names";
  Set<String> _names = {};
  final _objectChanged = Channel2<String, String>();

  LocalStorage._internal();
  static final LocalStorage _instance = LocalStorage._internal();
  static LocalStorage instance() => LocalStorage._instance;

  Channel2<String /*service*/, String /*objName*/ > objectChanged() => _objectChanged;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    SharedPreferences.setPrefix("com.kors.shoplist.");
    _prefs = await SharedPreferences.getInstance();
    //_prefs.clear();
    _inited = true;
  }

  Future<bool> clear() => _prefs.clear();

  Set<String> _readNames() {
    var str = _prefs.getString(_namesKey);
    if (str == null) {
      return {};
    }
    return str.split('|').toSet();
  }

  void _writeNames(Set<String> names) {
    var str = names.join('|');
    _prefs.setString(_namesKey, str);
  }

  Set<String> objectNames() {
    if (_names.isEmpty) {
      _names = _readNames();
    }
    return _names;
  }

  StoreObject? readObject(String name) {
    String? raw = _prefs.getString(name);
    if (raw == null) {
      return null;
    }
    var jsn = json.decode(raw) as List<dynamic>;
    return StoreObject.fromJson(jsn);
  }

  Future<bool> writeObject(String service, String name, StoreObject obj) {
    // timestamp and deleted
    {
      StoreObject mergedObj = StoreObject();
      var currentObj = readObject(name);

      // new object
      if (currentObj == null) {
        obj.records.forEach((id, r) {
          r.timestamp = DateTime.timestamp();
        });
      }
      // update object
      else {
        Set<ID> unitedIDs = currentObj.records.keys.toSet();
        unitedIDs.addAll(obj.records.keys);

        for (ID id in unitedIDs) {
          StoreRecord? cr = currentObj.records[id];
          StoreRecord? nr = obj.records[id];

          // new record
          if (cr == null) {
            assert(nr != null);
            nr!.timestamp = DateTime.timestamp();
            mergedObj.records[id] = nr;
          }
          // deleted record
          else if (nr == null) {
            cr.deleted = true;
            cr.timestamp = DateTime.timestamp();
            mergedObj.records[id] = cr;
          }
          // check update
          else {
            assert(cr.timestamp.year != 1970);

            // no change
            if (nr.payload == cr.payload) {
              nr.timestamp = cr.timestamp;
              mergedObj.records[id] = nr;
            }
            // changed
            else {
              nr.timestamp = DateTime.timestamp();
              mergedObj.records[id] = nr;
            }
          }
        }
      }
    }

    // names
    {
      if (!_names.contains(name)) {
        _names.add(name);
        _writeNames(_names);
      }
    }

    var jsn = obj.toJson();
    var str = json.encode(jsn);
    var ret = _prefs.setString(name, str);
    _objectChanged.send(service, name);
    return ret;
  }
}
