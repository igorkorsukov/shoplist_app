import 'package:shoplist/infrastructure/modularity/injectable.dart';
import 'package:shoplist/infrastructure/uid/uid.dart';
import 'storeobject.dart';

abstract class IObjectsStore with Injectable {
  @override
  String interfaceId() => "IObjectsStore";

  Future<bool> clear();

  Future<StoreObject?> readObject(String name, Uid objId, {bool includeDeleted = false});

  Future<bool> writeObject(String sender, StoreObject obj);
}
