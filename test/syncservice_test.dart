import 'package:shoplist/infrastructure/db/objectsstore.dart';
import 'package:test/test.dart';

import 'package:shoplist/infrastructure/db/syncservice.dart';
import 'package:shoplist/infrastructure/db/verstamp.dart';
import 'package:shoplist/infrastructure/db/storeobject.dart';
import 'package:shoplist/infrastructure/uid/uid.dart';

import 'mocks/localstore_mock.dart';
import 'mocks/cloudfs_mock.dart';

class Client {
  final driver = LocalStoreMock();

  final store = ObjectsStore();
  final serv = SyncService();

  Future<void> setup(CloudFSMock cloud, Verstamp verstamp) async {
    store.localStore.set(driver);
    store.verstamp.set(verstamp);
    serv.store.set(store);
    serv.cloud.set(cloud);
    await store.init();
    await serv.init();
  }
}

void main() {
  final cloud = CloudFSMock();
  final verstamp = Verstamp();
  verstamp.setMode(VerstampMode.increment);
  final client_1 = Client();
  final client_2 = Client();

  setUp(() async {
    await client_1.setup(cloud, verstamp);
    await client_2.setup(cloud, verstamp);
  });

  test('write / read object', () async {
    const Uid obj1Id = Uid(STORE_ID_TYPE, "obj1");
    const Uid id_1 = Uid(STORE_ID_TYPE, "id_1");
    const Uid id_2 = Uid(STORE_ID_TYPE, "id_2");
    const Uid id_3 = Uid(STORE_ID_TYPE, "id_3");
    StoreObject obj1_1 = StoreObject(obj1Id);
    obj1_1.records[id_1] = StoreRecord(id_1, type: "item", payload: "value1");
    obj1_1.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    // [client 1] write obj to local store and sync
    {
      client_1.store.writeObject("test", obj1_1);
      await client_1.serv.sync();

      expect(cloud.data.length, 2);

      StoreObject? obj1_2 = client_1.store.readObject(obj1Id);
      expect(obj1_2, isNotNull);
      expect(obj1_2, equals(obj1_1));

      await client_1.serv.sync();

      StoreObject? obj1_3 = client_1.store.readObject(obj1Id);
      expect(obj1_3, isNotNull);
      expect(obj1_3, equals(obj1_1));
    }

    // [client 2] read, sync and read obj again
    {
      StoreObject? obj2_1 = client_2.store.readObject(obj1Id);
      expect(obj2_1, isNull);

      await client_2.serv.sync();
      obj2_1 = client_2.store.readObject(obj1Id);

      expect(obj2_1, isNotNull);
      expect(obj2_1, equals(obj1_1));
    }

    // modify and sync
    {
      obj1_1.records[id_3] = StoreRecord(id_3, type: "item", payload: "value3");
      client_1.store.writeObject("test", obj1_1);
      await client_1.serv.sync();

      await client_2.serv.sync();
      StoreObject? obj2_1 = client_2.store.readObject(obj1Id);
      expect(obj2_1, isNotNull);
      expect(obj2_1, equals(obj1_1));
    }

    // delete and sync
    {
      obj1_1.records.remove(id_1);
      client_1.store.writeObject("test", obj1_1);
      await client_1.serv.sync();

      await client_2.serv.sync();
      StoreObject? obj2_1 = client_2.store.readObject(obj1Id);
      expect(obj2_1, isNotNull);
      expect(obj2_1, equals(obj1_1));
    }
  });
}
