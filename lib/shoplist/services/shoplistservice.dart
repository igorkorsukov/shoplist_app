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

  Channel2<String, ShopList?> listChanged() => repo().listChanged();

  Future<ShopList> readShopList(name) async {
    return repo().readShopList(name);
  }

  Future<void> checkItem(String name, ID itemID, bool val) async {
    ShopList list = await repo().readShopList(name);
    ShopItem item = list.items.firstWhere((e) => e.id == itemID);
    item.checked = val;
    repo().writeShopList(list);
  }

  Future<void> removeDone(String name) async {
    ShopList list = await repo().readShopList(name);
    list.items.removeWhere((e) => e.checked == true);
    repo().writeShopList(list);
  }

  Future<void> removeAll(String name) async {
    ShopList list = await repo().readShopList(name);
    list.items.clear();
    repo().writeShopList(list);
  }

  Future<ID> addItem(String name, ShopItem item) async {
    ShopList list = await repo().readShopList(name);
    if (!list.id.isValid()) {
      list.id = UIDGen.newID();
      list.name = name;
    }

    if (!item.id.isValid()) {
      item.id = UIDGen.newID();
    }

    list.items.add(item);
    await repo().writeShopList(list);
    return item.id;
  }

  Future<void> removeItem(String name, ID itemID) async {
    ShopList list = await repo().readShopList(name);
    list.items.removeWhere((e) => e.id == itemID);
    repo().writeShopList(list);
  }
}
