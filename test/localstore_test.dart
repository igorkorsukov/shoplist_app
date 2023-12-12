import 'package:test/test.dart';
import 'package:shoplist/infrastructure/db/verstamp.dart';
import 'package:shoplist/infrastructure/subscription/subscribable.dart';

import 'package:shoplist/infrastructure/db/localstorage.dart';
import 'package:shoplist/infrastructure/db/storeobject.dart';
import 'package:shoplist/infrastructure/uid/id.dart';

import 'mocks/driver_mock.dart';

// flutter test --coverage
// genhtml -o ./coverage/report ./coverage/lcov.info

class ObjectChangedSubscribable with Subscribable {
  int triggered = 0;
  String service = "";
  String objectName = "";

  void clear() {
    triggered = 0;
    service = "";
    objectName = "";
  }

  void onTriggered(String serv, String name) {
    triggered += 1;
    service = serv;
    objectName = name;
  }
}

void main() {
  final driver = DriverMock();
  final verstamp = Verstamp();
  final store = LocalStorage();

  setUp(() async {
    verstamp.setMode(VerstampMode.fixed);
    store.driver.set(driver);
    store.verstamp.set(verstamp);
    await store.init();
  });

  test('write / read object', () {
    final ID id_1 = ID("id_1");
    final ID id_2 = ID("id_2");
    final ID id_3 = ID("id_3");
    StoreObject obj = StoreObject();
    obj.records[id_1] = StoreRecord(id_1, type: "item", payload: "value1");
    obj.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    // write object
    {
      verstamp.setValue(2);
      store.writeObject("test", "obj1", obj);
      expect(driver.data.length, 2);
      expect(driver.data["object_names"], "obj1");
    }

    // read object and check verstamps
    {
      StoreObject? obj2 = store.readObject("obj1");
      expect(obj2, isNotNull);
      expect(obj2!.records[id_1]!.verstamp, equals(2));
      expect(obj2.records[id_2]!.verstamp, equals(2));
    }

    // change and write object
    {
      obj.records[id_1]!.payload = "value1 changed";
      verstamp.setValue(3);
      store.writeObject("test", "obj1", obj);
    }

    // read object and check new verstamp for changed record
    {
      StoreObject? obj3 = store.readObject("obj1");
      expect(obj3, isNotNull);
      expect(obj3!.records[id_1]!.verstamp, equals(3));
      expect(obj3.records[id_2]!.verstamp, equals(2));
    }

    // remove one record and write object
    {
      obj.records.remove(id_1);
      verstamp.setValue(4);
      store.writeObject("test", "obj1", obj);
    }

    // read object without removed record
    {
      StoreObject? obj4 = store.readObject("obj1");
      expect(obj4, isNotNull);
      expect(obj4!.records[id_1], isNull);
      expect(obj4.records[id_2]!.verstamp, equals(2));
    }

    // read object with removed record
    {
      StoreObject? obj5 = store.readObject("obj1", deleted: true);
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
      store.writeObject("test", "obj1", obj);
    }

    // read object, should be same as obj5
    {
      StoreObject? obj6 = store.readObject("obj1", deleted: true);
      expect(obj6, isNotNull);
      expect(obj6!.records[id_1]!.verstamp, equals(4));
      expect(obj6.records[id_1]!.deleted, isTrue);
      expect(obj6.records[id_2]!.verstamp, equals(2));
    }

    // add new record
    {
      obj.records[id_3] = StoreRecord(id_3, type: "item", payload: "value3");
      verstamp.setValue(6);
      store.writeObject("test", "obj1", obj);
    }

    // read object
    {
      StoreObject? obj7 = store.readObject("obj1", deleted: true);
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
    final ID id_1 = ID("id_1");
    final ID id_2 = ID("id_2");
    StoreObject obj = StoreObject();
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
      store.writeObject("test", "obj1", obj);
      await waitAsync();
      expect(subsc.triggered, 1);
      expect(subsc.service, "test");
      expect(subsc.objectName, "obj1");
    }

    // write object 1 again
    {
      subsc.clear();
      store.writeObject("test", "obj1", obj);
      await waitAsync();
      expect(subsc.triggered, 1);
      expect(subsc.service, "test");
      expect(subsc.objectName, "obj1");
    }
  });
}