import 'dart:developer';
import 'item_model.dart';
import 'store.dart';
import 'subscription/subscribable.dart';

class ShopListModel extends Subscribable {
  Function? onChanged;
  String name = "develop";

  final Store _store = Store.instance;
  ShopList _list = ShopList();

  ShopListModel({
    this.onChanged,
  });

  void init() async {
    await _store.init();

    _store.loadShopList(name).then((list) {
      _list = list.clone();
      _resort();
      onChanged!();
    });

    _store.listChanged.onReceive(this, (list) {
      _list = list.clone();
      _resort();
      onChanged!();
    });

    _store.itemAdded.onReceive(this, (p) {
      if (name != p.$1) {
        return;
      }
      log("added: ${p.$2.title}");
      ShopItem item = p.$2.clone();
      item.checked = false;
      _list.items.add(item);
      _resort();
      onChanged!();
    });

    _store.itemRemoved.onReceive(this, (p) {
      if (name != p.$1) {
        return;
      }
      log("removed: ${p.$2.title}");
      _list.items.removeWhere((e) => e.title == p.$2.title);
      _resort();
      onChanged!();
    });
  }

  void deinit() {
    unsubscribe();
  }

  void _resort() {
    _list.items.sort((a, b) {
      if (a.checked != b.checked) {
        return a.checked ? 1 : -1;
      }
      return a.title.compareTo(b.title);
    });
  }

  List<ShopItem> items() {
    return _list.items;
  }

  void checkItem(item, val) {
    item.checked = val;
    _store.updateItem(name, item);
    _resort();
    onChanged!();
  }
}
