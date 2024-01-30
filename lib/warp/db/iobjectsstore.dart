import 'package:shoplist/warp/modularity/injectable.dart';
import 'package:shoplist/warp/async/channel.dart';
import 'storeobject.dart';

export 'storeobject.dart';

abstract class IObjectsStore with Injectable {
  @override
  String interfaceId() => "IObjectsStore";

  Channel<StoreObject> objectChanged();

  Future<bool> put(StoreObject obj);
  Future<StoreObject?> get(String name, {bool includeDeletedRecs = false});
  Future<bool> del(String name);
}
