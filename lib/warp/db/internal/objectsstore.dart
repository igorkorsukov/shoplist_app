import 'dart:convert';
import 'package:shoplist/warp/async/channel.dart';
import 'package:shoplist/warp/uid/uid.dart';
import 'package:shoplist/warp/modularity/inject.dart';
import '../iobjectsstore.dart';
import '../ilocalstore.dart';
import '../iverstampservice.dart';

export '../iobjectsstore.dart';

class ObjectsStore extends IObjectsStore {
  final _objectChanged = Channel<StoreObject>();
  final localStore = Inject<ILocalStore>();
  final verstampService = Inject<IVerstampService>();

  ObjectsStore();

  @override
  Channel<StoreObject> objectChanged() => _objectChanged;

  @override
  Future<bool> put(StoreObject obj) async {
    // timestamp and deleted
    StoreObject mergedObj = StoreObject(obj.name);
    {
      var vs = verstampService().verstamp();
      var currentObj = await get(obj.name, includeDeletedRecs: true);

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

    var jsn = mergedObj.toJson();
    var str = json.encode(jsn);
    var ret = await localStore().put(mergedObj.name, str);
    _objectChanged.send(mergedObj);
    return ret;
  }

  @override
  Future<StoreObject?> get(String name, {bool includeDeletedRecs = false}) async {
    String? raw = await localStore().get(name);
    if (raw == null) {
      return null;
    }
    var jsn = json.decode(raw) as List<dynamic>;
    return StoreObject.fromJson(name, jsn, includeDeletedRecs: includeDeletedRecs);
  }

  @override
  Future<bool> del(String name) async {
    return false;
  }
}
