import 'package:shoplist/infrastructure/modularity/injectable.dart';
import 'package:shoplist/infrastructure/subscription/channel.dart';
import 'package:shoplist/infrastructure/uid/id.dart';
import 'types.dart';

abstract class IShopListService with Injectable {
  @override
  String interfaceId() => "IShopListService";

  Channel2<Id, ShopList?> listChanged();

  Future<ShopList> readShopList(name);

  Future<void> addItem(Id listID, ShopItem item);
  Future<void> checkItem(Id listId, Id itemId, bool val);
  Future<void> removeItem(Id listId, Id itemId);

  Future<void> removeDone(Id listId);
  Future<void> removeAll(Id listId);
}
