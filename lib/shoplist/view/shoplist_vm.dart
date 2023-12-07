import 'dart:developer';
import 'item_vm.dart';
import '../services/shoplsitrepository.dart';
import '../../infrastructure/subscription/subscribable.dart';

class ShopListModel extends Subscribable {
  Function? onChanged;
  String name = "develop";

  final ShopListRepository _store = ShopListRepository.instance;
  ShopList _list = ShopList();

  ShopListModel({
    this.onChanged,
  });

  void init() async {
    await _store.init();

    _store.readShopList(name).then((list) {
      _list = list.clone();
      _resort();
      onChanged!();
    });

    _store.listChanged.onReceive(this, (list) {
      if (name != list.name) {
        return;
      }
      _list = list.clone();
      _resort();
      onChanged!();
    });

    _store.itemAdded.onReceive(this, (p) {
      if (name != p.$1) {
        return;
      }
      log("added: ${p.$2.title}");
      _list.items.add(p.$2);
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

  void removeDone() {
    _list.items.removeWhere((e) => e.checked == true);
    _store.updateList(_list);
    _resort();
    onChanged!();
  }

  void removeAll() {
    _list.items.clear();
    _store.updateList(_list);
    _resort();
    onChanged!();
  }
}
