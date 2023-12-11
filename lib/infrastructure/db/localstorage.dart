import 'dart:convert';
import '../subscription/channel.dart';
import '../uid/id.dart';
import '../modularity/injectable.dart';
import '../modularity/inject.dart';
import 'driver.dart';
import 'verstamp.dart';
import 'storeobject.dart';

class LocalStorage with Injectable {
  bool _inited = false;
  final String _namesKey = "object_names";
  Set<String> _names = {};
  final _objectChanged = Channel2<String, String>();
  final driver = Inject<Driver>();
  final verstamp = Inject<Verstamp>();

  LocalStorage();

  Channel2<String /*service*/, String /*objName*/ > objectChanged() => _objectChanged;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    //_prefs.clear();
    _inited = true;
  }

  Future<bool> clear() => driver().clear();

  Set<String> _readNames() {
    // var str = _prefs.getString(_namesKey);
    // if (str == null) {
    //   return {};
    // }
    // return str.split('|').toSet();
    //! TODO
    return {"reference2", "develop2"};
  }

  void _writeNames(Set<String> names) {
    var str = names.join('|');
    driver().writeString(_namesKey, str);
  }

  Set<String> objectNames() {
    if (_names.isEmpty) {
      _names = _readNames();
    }
    return _names;
  }

  StoreObject? readObject(String name, {bool deleted = false}) {
    String? raw = driver().readString(name);
    if (raw == null) {
      return null;
    }
    var jsn = json.decode(raw) as List<dynamic>;
    return StoreObject.fromJson(jsn, deleted: deleted);
  }

  Future<bool> writeObject(String service, String name, StoreObject obj) {
    // timestamp and deleted
    StoreObject mergedObj = StoreObject();
    {
      var vs = verstamp().verstamp();
      var currentObj = readObject(name, deleted: true);

      // new object
      if (currentObj == null) {
        mergedObj = obj;

        mergedObj.records.forEach((id, r) {
          r.verstamp = vs;
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
            nr!.verstamp = vs;
            mergedObj.records[id] = nr;
          }
          // deleted record if not deleted
          else if (nr == null) {
            if (!cr.deleted) {
              cr.deleted = true;
              cr.verstamp = vs;
            }
            mergedObj.records[id] = cr;
          }
          // check update
          else {
            assert(cr.verstamp != 0);

            // no change
            if (nr.deleted == cr.deleted && nr.payload == cr.payload) {
              nr.verstamp = cr.verstamp;
              mergedObj.records[id] = nr;
            }
            // changed
            else {
              nr.verstamp = vs;
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

    var jsn = mergedObj.toJson();
    var str = json.encode(jsn);
    var ret = driver().writeString(name, str);
    _objectChanged.send(service, name);
    return ret;
  }
}
