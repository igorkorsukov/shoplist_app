import '../../infrastructure/uid/uid.dart';
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
      addItem(act.args["listId"] as Uid,
          ShopItem(act.args["itemId"] as Uid, title: act.args["title"], checked: act.args["checked"]));
    });

    dispatcher().reg(this, "remove_item", (Action act) {
      removeItem(act.args["listId"] as Uid, act.args["itemId"] as Uid);
    });

    dispatcher().reg(this, "check_item", (Action act) {
      checkItem(act.args["listId"] as Uid, act.args["itemId"] as Uid, act.args["val"] as bool);
    });

    dispatcher().reg(this, "remove_done", (Action act) {
      removeDone(act.args["listId"] as Uid);
    });

    dispatcher().reg(this, "remove_all", (Action act) {
      removeAll(act.args["listId"] as Uid);
    });
  }

  @override
  Channel2<Uid, ShopList> listChanged() => repo().listChanged();

  @override
  Future<ShopList> shopList(Uid listId) async {
    return repo().readShopList(listId);
  }

  @override
  Future<void> checkItem(Uid listId, Uid itemId, bool val) async {
    ShopList list = await repo().readShopList(listId);
    ShopItem item = list.items.firstWhere((e) => e.id == itemId);
    item.checked = val;
    repo().writeShopList(list);
  }

  @override
  Future<void> removeDone(Uid listId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.removeWhere((e) => e.checked == true);
    repo().writeShopList(list);
  }

  @override
  Future<void> removeAll(Uid listId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.clear();
    repo().writeShopList(list);
  }

  @override
  Future<void> addItem(Uid listId, ShopItem item) async {
    assert(item.id.isValid());

    ShopList list = await repo().readShopList(listId);

    //! NOTE Id maybe not valid, if list not found
    list.id = listId;

    list.items.add(item);

    await repo().writeShopList(list);
  }

  @override
  Future<void> removeItem(Uid listId, Uid itemId) async {
    ShopList list = await repo().readShopList(listId);
    list.items.removeWhere((e) => e.id == itemId);
    repo().writeShopList(list);
  }

  // categories
  @override
  Channel<Categories> categoriesChanged() => repo().categoriesChanged();

  @override
  Future<Categories> categories() async {
    return repo().readCategories();
  }

  @override
  Future<void> addCategory(Category cat) async {
    Categories cats = await repo().readCategories();
    cats[cat.id] = cat;
    repo().writeCategories(cats);
  }

  @override
  Future<void> removeCategory(Uid catId) async {
    Categories cats = await repo().readCategories();
    cats.remove(catId);
    repo().writeCategories(cats);
  }
}
