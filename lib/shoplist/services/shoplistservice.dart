import '../../infrastructure/uid/id.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/uid/uidgen.dart';
import 'shoplsitrepository.dart';
import 'shoplist.dart';

class ShopListService {
  final ShopListRepository _repo = ShopListRepository();
  final Channel<ShopList> _listChanged = Channel<ShopList>();

  ShopListService._internal();
  static final ShopListService _instance = ShopListService._internal();
  static ShopListService instance() => ShopListService._instance;

  Channel<ShopList> listChanged() => _listChanged;

  Future<ShopList> readShopList(name) async {
    return _repo.readShopList(name);
  }

  Future<void> checkItem(String name, ID itemID, bool val) async {
    ShopList list = await _repo.readShopList(name);
    ShopItem item = list.items.firstWhere((e) => e.id == itemID);
    item.checked = val;
    await _repo.writeShopList(list);
    _listChanged.send(list);
  }

  Future<void> removeDone(String name) async {
    ShopList list = await _repo.readShopList(name);
    list.items.removeWhere((e) => e.checked == true);
    await _repo.writeShopList(list);
    _listChanged.send(list);
  }

  Future<void> removeAll(String name) async {
    ShopList list = await _repo.readShopList(name);
    list.items.clear();
    await _repo.writeShopList(list);
    _listChanged.send(list);
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
    _listChanged.send(list);
    return item.id;
  }

  Future<void> removeItem(String name, ID itemID) async {
    ShopList list = await _repo.readShopList(name);
    list.items.removeWhere((e) => e.id == itemID);
    await _repo.writeShopList(list);
    _listChanged.send(list);
  }
}
