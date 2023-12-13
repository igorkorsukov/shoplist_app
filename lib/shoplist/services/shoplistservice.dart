import '../../infrastructure/uid/id.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/uid/uidgen.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/modularity/injectable.dart';
import 'shoplsitrepository.dart';
import 'shoplist.dart';

class ShopListService with Injectable {
  final repo = Inject<ShopListRepository>();

  ShopListService();

  Channel2<ID, ShopList?> listChanged() => repo().listChanged();

  Future<ShopList> readShopList(name) async {
    return repo().readShopList(name);
  }

  Future<void> checkItem(ID listId, ID itemId, bool val) async {
    ShopList list = await repo().readShopList(listId);
    ShopItem item = list.items.firstWhere((e) => e.id == itemId);
    item.checked = val;
    repo().writeShopList(list);
  }

  Future<void> removeDone(ID listId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.removeWhere((e) => e.checked == true);
    repo().writeShopList(list);
  }

  Future<void> removeAll(ID listId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.clear();
    repo().writeShopList(list);
  }

  Future<ID> addItem(ID listID, ShopItem item) async {
    ShopList list = await repo().readShopList(listID);

    if (!item.id.isValid()) {
      item.id = UIDGen.newID();
    }

    list.items.add(item);
    await repo().writeShopList(list);
    return item.id;
  }

  Future<void> removeItem(ID listID, ID itemID) async {
    ShopList list = await repo().readShopList(listID);
    list.items.removeWhere((e) => e.id == itemID);
    repo().writeShopList(list);
  }
}
