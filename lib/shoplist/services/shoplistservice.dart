import '../../infrastructure/uid/id.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/uid/uidgen.dart';
import 'shoplsitrepository.dart';
import 'shoplist.dart';

class ShopListService {
  final _repo = ShopListRepository.instance();

  ShopListService._();
  static final _instance = ShopListService._();
  static ShopListService instance() => ShopListService._instance;

  Channel2<String, ShopList?> listChanged() => _repo.listChanged();

  Future<ShopList> readShopList(name) async {
    return _repo.readShopList(name);
  }

  Future<void> checkItem(String name, ID itemID, bool val) async {
    ShopList list = await _repo.readShopList(name);
    ShopItem item = list.items.firstWhere((e) => e.id == itemID);
    item.checked = val;
    _repo.writeShopList(list);
  }

  Future<void> removeDone(String name) async {
    ShopList list = await _repo.readShopList(name);
    list.items.removeWhere((e) => e.checked == true);
    _repo.writeShopList(list);
  }

  Future<void> removeAll(String name) async {
    ShopList list = await _repo.readShopList(name);
    list.items.clear();
    _repo.writeShopList(list);
  }

  Future<ID> addItem(String name, ShopItem item) async {
    ShopList list = await _repo.readShopList(name);
    if (!list.id.isValid()) {
      list.id = UIDGen.newID();
      list.name = name;
    }

    if (!item.id.isValid()) {
      item.id = UIDGen.newID();
    }

    list.items.add(item);
    await _repo.writeShopList(list);
    return item.id;
  }

  Future<void> removeItem(String name, ID itemID) async {
    ShopList list = await _repo.readShopList(name);
    list.items.removeWhere((e) => e.id == itemID);
    _repo.writeShopList(list);
  }
}
