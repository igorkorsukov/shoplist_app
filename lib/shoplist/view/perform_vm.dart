import 'dart:developer';
import 'item_vm.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../services/shoplistservice.dart';
import 'item_vm.dart';

class ShopListModel extends Subscribable {
  Function? onChanged;
  String name = "develop2";

  final ShopListService _serv = ShopListService.instance();
  final List<ShopItemV> _items = [];

  ShopListModel({
    this.onChanged,
  });

  void _makeItems(list) {
    _items.clear();
    for (var it in list.items) {
      _items.add(ShopItemV(it.id, title: it.title, checked: it.checked));
    }
  }

  void init() async {
    _serv.readShopList(name).then((list) {
      _makeItems(list);
      _resort();
      onChanged!();
    });

    _serv.listChanged().onReceive(this, (listName, list) async {
      if (name != listName) {
        return;
      }

      list = list ?? await _serv.readShopList(name);
      _makeItems(list);
      _resort();
      onChanged!();
    });
  }

  void deinit() {
    unsubscribe();
  }

  void _resort() {
    _items.sort((a, b) {
      if (a.checked != b.checked) {
        return a.checked ? 1 : -1;
      }
      return a.title.compareTo(b.title);
    });
  }

  List<ShopItemV> items() {
    return _items;
  }

  void checkItem(item, val) {
    _serv.checkItem(name, item.id, val);
  }

  void removeDone() {
    _serv.removeDone(name);
  }

  void removeAll() {
    _serv.removeAll(name);
  }
}
