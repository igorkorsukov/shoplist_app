import 'package:shoplist/infrastructure/modularity/injectable.dart';
import 'package:shoplist/infrastructure/subscription/channel.dart';
import 'package:shoplist/infrastructure/uid/uid.dart';
import 'types.dart';

abstract class IShopListService with Injectable {
  @override
  String interfaceId() => "IShopListService";

  // lists
  Channel2<Uid, ShopList> listChanged();

  Future<ShopList> shopList(Uid listId);

  Future<void> addItem(Uid listId, ShopItem item);
  Future<void> checkItem(Uid listId, Uid itemId, bool val);
  Future<void> removeItem(Uid listId, Uid itemId);

  Future<void> removeDone(Uid listId);
  Future<void> removeAll(Uid listId);

  // categories
  Channel<Categories?> categoriesChanged();
  Future<Categories> categories();
  Future<void> addCategory(Category catg);
  Future<void> removeCategory(Uid catgId);
}
