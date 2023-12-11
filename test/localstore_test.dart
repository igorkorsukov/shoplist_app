import 'package:shoplist/infrastructure/db/verstamp.dart';
import 'package:test/test.dart';

import 'package:shoplist/infrastructure/db/driver.dart';
import 'package:shoplist/infrastructure/db/localstorage.dart';
import 'package:shoplist/infrastructure/db/storeobject.dart';
import 'package:shoplist/infrastructure/uid/id.dart';

class DriverMock implements Driver {
  final Map<String, String> data = {};

  @override
  Future<void> init(String prefix) async {}

  @override
  Future<bool> clear() {
    return Future.value(true);
  }

  @override
  String? readString(String key) {
    return data[key];
  }

  @override
  Future<bool> writeString(String key, String value) {
    data[key] = value;
    return Future.value(true);
  }
}

void main() {
  final driver = DriverMock();
  final verstamp = Verstamp();
  final store = LocalStorage();

  setUp(() async {
    store.driver.set(driver);
    store.verstamp.set(verstamp);
    await store.init();
  });

  test('write / read object', () {
    final ID id_1 = ID("id_1");
    final ID id_2 = ID("id_2");
    StoreObject obj = StoreObject();
    obj.records[id_1] = StoreRecord(id_1, type: "item", payload: "value1");
    obj.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    // write object
    {
      verstamp.setFixed(2);
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
      verstamp.setFixed(3);
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
      verstamp.setFixed(4);
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
      verstamp.setFixed(5);
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
  });
}
