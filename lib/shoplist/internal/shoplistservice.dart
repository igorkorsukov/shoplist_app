import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/modularity/inject.dart';
import 'shoplsitrepository.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class ShopListService extends IShopListService {
  final repo = Inject<ShopListRepository>();

  ShopListService();

  void init() {}

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

  @override
  Future<void> changeItemCategory(Uid listId, Uid itemId, Uid categoryId) async {
    ShopList list = await repo().readShopList(listId);
    ShopItem item = list.items.firstWhere((e) => e.id == itemId);
    item.categoryId = categoryId;
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
