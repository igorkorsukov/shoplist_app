import 'package:test/test.dart';

import 'package:shoplist/warp/uid/uid.dart';
import 'package:shoplist/warp/db/internal/syncservice.dart';
import 'package:shoplist/warp/db/internal/objectsstore.dart';

import 'mocks/localstore_mock.dart';
import 'mocks/cloudstore_mock.dart';
import 'mocks/verstampservice_mock.dart';

class Client {
  final localStore = LocalStoreMock();
  final store = ObjectsStore();
  final sync = SyncService();

  Future<void> setup(CloudStoreMock cloud, VerstampServiceMock verstamp) async {
    store.localStore.set(localStore);
    store.verstampService.set(verstamp);
    sync.store.set(store);
    sync.cloud.set(cloud);
    await sync.init();
  }
}

void main() {
  final cloud = CloudStoreMock();
  final verstamp = VerstampServiceMock();
  verstamp.setMode(VerstampMode.increment);
  final client_1 = Client();
  final client_2 = Client();

  setUp(() async {
    await client_1.setup(cloud, verstamp);
    await client_2.setup(cloud, verstamp);
  });

  test('write / read object', () async {
    const String OBJ_1 = "obj1";
    const Uid id_1 = Uid("id_1");
    const Uid id_2 = Uid("id_2");
    const Uid id_3 = Uid("id_3");
    StoreObject obj1_1 = StoreObject(OBJ_1);
    obj1_1.records[id_1] = StoreRecord(id_1, type: "item", payload: "value1");
    obj1_1.records[id_2] = StoreRecord(id_2, type: "item", payload: "value2");

    // [client 1] write obj to local store and sync
    {
      await client_1.store.put(obj1_1);
      await client_1.sync.sync();

      expect(cloud.data.length, 2);

      StoreObject? obj1_2 = await client_1.store.get(OBJ_1);
      expect(obj1_2, isNotNull);
      expect(obj1_2, equals(obj1_1));

      await client_1.sync.sync();

      StoreObject? obj1_3 = await client_1.store.get(OBJ_1);
      expect(obj1_3, isNotNull);
      expect(obj1_3, equals(obj1_1));
    }

    // [client 2] read, sync and read obj again
    {
      StoreObject? obj2_1 = await client_2.store.get(OBJ_1);
      expect(obj2_1, isNull);

      await client_2.sync.sync();
      obj2_1 = await client_2.store.get(OBJ_1);

      expect(obj2_1, isNotNull);
      expect(obj2_1, equals(obj1_1));
    }

    // modify and sync
    {
      obj1_1.records[id_3] = StoreRecord(id_3, type: "item", payload: "value3");
      await client_1.store.put(obj1_1);
      await client_1.sync.sync();

      await client_2.sync.sync();
      StoreObject? obj2_1 = await client_2.store.get(OBJ_1);
      expect(obj2_1, isNotNull);
      expect(obj2_1, equals(obj1_1));
    }

    // delete and sync
    {
      obj1_1.records.remove(id_1);
      await client_1.store.put(obj1_1);
      await client_1.sync.sync();

      await client_2.sync.sync();
      StoreObject? obj2_1 = await client_2.store.get(OBJ_1);
      expect(obj2_1, isNotNull);
      expect(obj2_1, equals(obj1_1));
    }
  });
}
