import '../../infrastructure/uid/id.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import 'shoplsitrepository.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class ShopListService extends IShopListService with Actionable {
  final repo = Inject<ShopListRepository>();
  final dispatcher = Inject<ActionsDispatcher>();

  ShopListService();

  void init() {
    dispatcher().reg(this, "add_item", (Action act) {
      addItem(act.args["listId"] as Id,
          ShopItem(act.args["itemId"] as Id, title: act.args["title"], checked: act.args["checked"]));
    });

    dispatcher().reg(this, "remove_item", (Action act) {
      removeItem(act.args["listId"] as Id, act.args["itemId"] as Id);
    });

    dispatcher().reg(this, "check_item", (Action act) {
      checkItem(act.args["listId"] as Id, act.args["itemId"] as Id, act.args["val"] as bool);
    });

    dispatcher().reg(this, "remove_done", (Action act) {
      removeDone(act.args["listId"] as Id);
    });

    dispatcher().reg(this, "remove_all", (Action act) {
      removeAll(act.args["listId"] as Id);
    });
  }

  Channel2<Id, ShopList?> listChanged() => repo().listChanged();

  Future<ShopList> readShopList(name) async {
    return repo().readShopList(name);
  }

  Future<void> checkItem(Id listId, Id itemId, bool val) async {
    ShopList list = await repo().readShopList(listId);
    ShopItem item = list.items.firstWhere((e) => e.id == itemId);
    item.checked = val;
    repo().writeShopList(list);
  }

  Future<void> removeDone(Id listId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.removeWhere((e) => e.checked == true);
    repo().writeShopList(list);
  }

  Future<void> removeAll(Id listId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.clear();
    repo().writeShopList(list);
  }

  Future<void> addItem(Id listID, ShopItem item) async {
    assert(item.id.isValid());

    ShopList list = await repo().readShopList(listID);

    list.items.add(item);

    await repo().writeShopList(list);
  }

  Future<void> removeItem(Id listId, Id itemId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.removeWhere((e) => e.id == itemId);
    repo().writeShopList(list);
  }
}
