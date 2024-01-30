import 'package:test/test.dart';
import 'package:shoplist/warp/db/internal/verstampservice.dart';
import 'package:shoplist/warp/async/subscribable.dart';
import 'package:shoplist/warp/uid/uid.dart';

import 'package:shoplist/warp/db/internal/objectsstore.dart';

import 'mocks/localstore_mock.dart';
import 'mocks/verstampservice_mock.dart';

// flutter test --coverage
// genhtml -o ./coverage/report ./coverage/lcov.info

class ObjectChangedSubscribable with Subscribable {
  int triggered = 0;
  StoreObject object = StoreObject("");

  void clear() {
    triggered = 0;
    object = StoreObject("");
  }

  void onTriggered(StoreObject obj) {
    triggered += 1;
    object = obj;
  }
}

void main() {
  final localStore = LocalStoreMock();
  final verstamp = VerstampServiceMock();
  final store = ObjectsStore();

  setUp(() async {
    verstamp.setMode(VerstampMode.fixed);
    store.localStore.set(localStore);
    store.verstampService.set(verstamp);
  });

  test('write / read object', () async {
    const String OBJ_1 = "obj1";
    const Uid id_1 = Uid("id_1");
    const Uid id_2 = Uid("id_2");
    const Uid id_3 = Uid("id_3");
    StoreObject obj = StoreObject(OBJ_1);
    obj.add(StoreRecord(id_1, type: "item", payload: "value1"));
    obj.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    // write object
    {
      verstamp.setValue(2);
      store.put(obj);
      expect(localStore.data.length, 2);
    }

    // read object and check verstamps
    {
      StoreObject? obj2 = await store.get(OBJ_1);
      expect(obj2, isNotNull);
      expect(obj2!.records[id_1]!.verstamp, equals(2));
      expect(obj2.records[id_2]!.verstamp, equals(2));
    }

    // change and write object
    {
      obj.records[id_1]!.payload = "value1 changed";
      verstamp.setValue(3);
      await store.put(obj);
    }

    // read object and check new verstamp for changed record
    {
      StoreObject? obj3 = await store.get(OBJ_1);
      expect(obj3, isNotNull);
      expect(obj3!.records[id_1]!.verstamp, equals(3));
      expect(obj3.records[id_2]!.verstamp, equals(2));
    }

    // remove one record and write object
    {
      obj.records.remove(id_1);
      verstamp.setValue(4);
      await store.put(obj);
    }

    // read object without removed record
    {
      StoreObject? obj4 = await store.get(OBJ_1);
      expect(obj4, isNotNull);
      expect(obj4!.records[id_1], isNull);
      expect(obj4.records[id_2]!.verstamp, equals(2));
    }

    // read object with removed record
    {
      StoreObject? obj5 = await store.get(OBJ_1, includeDeletedRecs: true);
      expect(obj5, isNotNull);
      expect(obj5!.records[id_1]!.verstamp, equals(4));
      expect(obj5.records[id_1]!.deleted, isTrue);
      expect(obj5.records[id_2]!.verstamp, equals(2));

      // now obj is obj5
      obj = obj5;
    }

    // write with record marked as deleted
    {
      verstamp.setValue(5);
      await store.put(obj);
    }

    // read object, should be same as obj5
    {
      StoreObject? obj6 = await store.get(OBJ_1, includeDeletedRecs: true);
      expect(obj6, isNotNull);
      expect(obj6!.records[id_1]!.verstamp, equals(4));
      expect(obj6.records[id_1]!.deleted, isTrue);
      expect(obj6.records[id_2]!.verstamp, equals(2));
    }

    // add new record
    {
      obj.records[id_3] = StoreRecord(id_3, type: "item", payload: "value3");
      verstamp.setValue(6);
      await store.put(obj);
    }

    // read object
    {
      StoreObject? obj7 = await store.get(OBJ_1, includeDeletedRecs: true);
      expect(obj7, isNotNull);
      expect(obj7!.records[id_1]!.verstamp, equals(4));
      expect(obj7.records[id_1]!.deleted, isTrue);
      expect(obj7.records[id_2]!.verstamp, equals(2));
      expect(obj7.records[id_3]!.verstamp, equals(6));
    }
  });

  test('object changed notify', () async {
    const String OBJ_1 = "obj1";
    const Uid id_1 = Uid("id_1");
    const Uid id_2 = Uid("id_2");
    StoreObject obj = StoreObject(OBJ_1);
    obj.records[id_1] = StoreRecord(id_1, type: "item", payload: "value1");
    obj.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    ObjectChangedSubscribable subsc = ObjectChangedSubscribable();
    store.objectChanged().onReceive(subsc, subsc.onTriggered);

    verstamp.setValue(2);

    waitAsync() async {
      await Future.delayed(const Duration(seconds: 1));
    }

    // write object 1
    {
      subsc.clear();
      await store.put(obj);
      await waitAsync();
      expect(subsc.triggered, 1);
      expect(subsc.object.name, OBJ_1);
    }

    // write object 1 again
    {
      subsc.clear();
      await store.put(obj);
      await waitAsync();
      expect(subsc.triggered, 1);
      expect(subsc.object.name, OBJ_1);
    }
  });
}
