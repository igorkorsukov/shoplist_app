import 'dart:developer';
import 'types.dart';
import 'store.dart';
import 'subscription/subscribable.dart';

class ShopListModel extends Subscribable {
  Function? onChanged;

  int _counter = 0;
  final Store _store = Store.instance;
  List<Item> _items = [];

  ShopListModel({
    this.onChanged,
  }) {
    log("ctor: ShopListModel");
  }

  void init() {
    _store.loadItems().then((list) {
      _items = list;
      _resort();
      onChanged!();
    });

    _store.itemAdded.onReceive(this, (v) {
      _items.add(v);
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

  void addNew() {
    _counter++;
    _items.add(Item(title: "item $_counter"));
    onChanged!();
  }

  void checkItem(item, val) {
    item.checked = val;
    _resort();
    onChanged!();
  }
}
