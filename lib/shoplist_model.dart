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
      onChanged!();
    });

    _store.itemAdded.onReceive(this, (v) {
      _items.add(v);
      onChanged!();
    });
  }

  void deinit() {
    unsubscribe();
  }

  List<Item> items() {
    return _items;
  }

  void addNew() {
    _counter++;
    _items.add(Item(title: "item $_counter"));
    onChanged!();
  }
}
