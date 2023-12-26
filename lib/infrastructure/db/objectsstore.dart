import 'dart:convert';
import '../subscription/channel.dart';
import '../uid/uid.dart';
import '../modularity/injectable.dart';
import '../modularity/inject.dart';
import 'ilocalstore.dart';
import 'verstamp.dart';
import 'storeobject.dart';

class ObjectsStore with Injectable {
  @override
  String interfaceId() => "IObjectsStore";

  bool _inited = false;
  final Uid _objID = const Uid(STORE_ID_TYPE, "object_ids"); // ID of internal object
  Set<Uid> _objectIDs = {};
  final _objectChanged = Channel2<String, StoreObject>();
  final localStore = Inject<ILocalStore>();
  final verstamp = Inject<Verstamp>();

  ObjectsStore();

  Channel2<String /*sender*/, StoreObject> objectChanged() => _objectChanged;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _inited = true;
  }

  Future<bool> clear() => localStore().clear();

  Future<Set<Uid>> _readObjectIDs() async {
    var obj = await readObject(_objID);
    if (obj == null) {
      return {_objID};
    }

    _objectIDs.clear();
    _objectIDs.add(_objID);
    obj.records.forEach((id, r) {
      _objectIDs.add(id);
    });

    return _objectIDs;
  }

  void _writeObjectIDs(Set<Uid> ids) {
    var obj = StoreObject(_objID);
    for (var id in ids) {
      obj.add(StoreRecord(id));
    }
    writeObject("localstore", obj);
  }

  Future<Set<Uid>> objectIDs() async {
    if (_objectIDs.isEmpty) {
      _objectIDs = await _readObjectIDs();
    }
    return _objectIDs;
  }

  Future<StoreObject?> readObject(Uid objId, {bool deleted = false}) async {
    String? raw = await localStore().read(objId.toString());
    if (raw == null) {
      return null;
    }
    var jsn = json.decode(raw) as List<dynamic>;
    return StoreObject.fromJson(objId, jsn, deleted: deleted);
  }

  Future<bool> writeObject(String service, StoreObject obj) async {
    // timestamp and deleted
    StoreObject mergedObj = StoreObject(obj.id);
    {
      var vs = verstamp().verstamp();
      var currentObj = await readObject(obj.id, deleted: true);

      // new object
      if (currentObj == null) {
        mergedObj = obj;

        mergedObj.records.forEach((id, r) {
          //! NOTE If verstamp set outside (ex sync), don't touch it
          if (r.verstamp == 0) {
            r.verstamp = vs;
          }
        });
      }
      // update object
      else {
        Set<Uid> unitedIDs = currentObj.records.keys.toSet();
        unitedIDs.addAll(obj.records.keys);

        for (Uid id in unitedIDs) {
          StoreRecord? cr = currentObj.records[id];
          StoreRecord? nr = obj.records[id];

          // new record
          if (cr == null) {
            assert(nr != null);
            //! NOTE If verstamp set outside (ex sync), don't touch it
            if (nr!.verstamp == 0) {
              nr.verstamp = vs;
            }
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

    // ids
    {
      if (mergedObj.id == _objID) {
        _objectIDs.clear();
      } else {
        var ids = await objectIDs();
        if (!ids.contains(mergedObj.id)) {
          ids.add(mergedObj.id);
          _writeObjectIDs(ids);
        }
      }
    }

    var jsn = mergedObj.toJson();
    var str = json.encode(jsn);
    var ret = await localStore().write(mergedObj.id.toString(), str);
    _objectChanged.send(service, mergedObj);
    return ret;
  }
}
