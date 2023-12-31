import 'package:test/test.dart';
import 'package:shoplist/infrastructure/db/verstamp.dart';
import 'package:shoplist/infrastructure/subscription/subscribable.dart';

import 'package:shoplist/infrastructure/db/objectsstore.dart';
import 'package:shoplist/infrastructure/db/storeobject.dart';
import 'package:shoplist/infrastructure/uid/uid.dart';

import 'mocks/localstore_mock.dart';

// flutter test --coverage
// genhtml -o ./coverage/report ./coverage/lcov.info

class ObjectChangedSubscribable with Subscribable {
  int triggered = 0;
  String sender = "";
  StoreObject object = StoreObject(Uid.invalid);

  void clear() {
    triggered = 0;
    sender = "";
    object = StoreObject(Uid.invalid);
  }

  void onTriggered(String sendr, StoreObject obj) {
    triggered += 1;
    sender = sendr;
    object = obj;
  }
}

void main() {
  final driver = LocalStoreMock();
  final verstamp = Verstamp();
  final store = ObjectsStore();

  setUp(() async {
    verstamp.setMode(VerstampMode.fixed);
    store.localStore.set(driver);
    store.verstamp.set(verstamp);
    await store.init();
  });

  test('write / read object', () {
    const Uid obj1 = Uid(STORE_ID_TYPE, "obj1");
    const Uid id_1 = Uid(STORE_ID_TYPE, "id_1");
    const Uid id_2 = Uid(STORE_ID_TYPE, "id_2");
    const Uid id_3 = Uid(STORE_ID_TYPE, "id_3");
    StoreObject obj = StoreObject(obj1);
    obj.add(StoreRecord(id_1, type: "item", payload: "value1"));
    obj.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    // write object
    {
      verstamp.setValue(2);
      store.writeObject("test", obj);
      expect(driver.data.length, 2);
    }

    // read object and check verstamps
    {
      StoreObject? obj2 = store.readObject(obj1);
      expect(obj2, isNotNull);
      expect(obj2!.records[id_1]!.verstamp, equals(2));
      expect(obj2.records[id_2]!.verstamp, equals(2));
    }

    // change and write object
    {
      obj.records[id_1]!.payload = "value1 changed";
      verstamp.setValue(3);
      store.writeObject("test", obj);
    }

    // read object and check new verstamp for changed record
    {
      StoreObject? obj3 = store.readObject(obj1);
      expect(obj3, isNotNull);
      expect(obj3!.records[id_1]!.verstamp, equals(3));
      expect(obj3.records[id_2]!.verstamp, equals(2));
    }

    // remove one record and write object
    {
      obj.records.remove(id_1);
      verstamp.setValue(4);
      store.writeObject("test", obj);
    }

    // read object without removed record
    {
      StoreObject? obj4 = store.readObject(obj1);
      expect(obj4, isNotNull);
      expect(obj4!.records[id_1], isNull);
      expect(obj4.records[id_2]!.verstamp, equals(2));
    }

    // read object with removed record
    {
      StoreObject? obj5 = store.readObject(obj1, deleted: true);
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
      store.writeObject("test", obj);
    }

    // read object, should be same as obj5
    {
      StoreObject? obj6 = store.readObject(obj1, deleted: true);
      expect(obj6, isNotNull);
      expect(obj6!.records[id_1]!.verstamp, equals(4));
      expect(obj6.records[id_1]!.deleted, isTrue);
      expect(obj6.records[id_2]!.verstamp, equals(2));
    }

    // add new record
    {
      obj.records[id_3] = StoreRecord(id_3, type: "item", payload: "value3");
      verstamp.setValue(6);
      store.writeObject("test", obj);
    }

    // read object
    {
      StoreObject? obj7 = store.readObject(obj1, deleted: true);
      expect(obj7, isNotNull);
      expect(obj7!.records[id_1]!.verstamp, equals(4));
      expect(obj7.records[id_1]!.deleted, isTrue);
      expect(obj7.records[id_2]!.verstamp, equals(2));
      expect(obj7.records[id_3]!.verstamp, equals(6));
    }

    // clear
    {
      store.clear();
      expect(driver.data.length, 0);
    }
  });

  test('object changed notify', () async {
    const Uid obj1 = Uid(STORE_ID_TYPE, "obj1");
    const Uid id_1 = Uid(STORE_ID_TYPE, "id_1");
    const Uid id_2 = Uid(STORE_ID_TYPE, "id_2");
    StoreObject obj = StoreObject(obj1);
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
      store.writeObject("test", obj);
      await waitAsync();
      expect(subsc.triggered, 1);
      expect(subsc.sender, "test");
      expect(subsc.object.id, obj1);
    }

    // write object 1 again
    {
      subsc.clear();
      store.writeObject("test", obj);
      await waitAsync();
      expect(subsc.triggered, 1);
      expect(subsc.sender, "test");
      expect(subsc.object.id, obj1);
    }
  });
}
