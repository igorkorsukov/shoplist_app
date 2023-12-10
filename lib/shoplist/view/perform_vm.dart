import 'dart:developer';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/inject.dart';
import '../services/shoplistservice.dart';
import 'item_vm.dart';

class ShopListModel with Subscribable {
  Function? onChanged;
  String name = "develop2";

  final serv = Inject<ShopListService>();
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
    serv().readShopList(name).then((list) {
      _makeItems(list);
      _resort();
      onChanged!();
    });

    serv().listChanged().onReceive(this, (listName, list) async {
      if (name != listName) {
        return;
      }

      list = list ?? await serv().readShopList(name);
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
    serv().checkItem(name, item.id, val);
  }

  void removeDone() {
    serv().removeDone(name);
  }

  void removeAll() {
    serv().removeAll(name);
  }
}
