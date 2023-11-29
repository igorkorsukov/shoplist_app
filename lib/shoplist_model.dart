import 'dart:developer';
import 'item_model.dart';
import 'store.dart';
import 'subscription/subscribable.dart';

class ShopListModel extends Subscribable {
  Function? onChanged;

  String name = "develop";
  final Store _store = Store.instance;
  List<Item> _items = [];

  ShopListModel({
    this.onChanged,
  }) {
    _store.newList(name);
  }

  void init() {
    _store.loadItems(name).then((list) {
      _items = list;
      _resort();
      onChanged!();
    });

    _store.itemAdded.onReceive(this, (v) {
      Item item = v;
      item.checked = false;
      _items.add(item);
      _resort();
      onChanged!();
    });

    _store.itemRemoved.onReceive(this, (v) {
      log("removed: ${v.title}");
      _items.removeWhere((e) => e.title == v.title);
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

  List<Item> items() {
    return _items;
  }

  void checkItem(item, val) {
    item.checked = val;
    _resort();
    onChanged!();
  }
}
