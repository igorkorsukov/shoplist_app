import 'dart:developer';
import 'types.dart';
import 'store.dart';

class EditItemModel {
  final _store = Store.instance;

  void addItem(String title) {
    log("addItem: $title");
    _store.addItem(Item(title: title));
  }
}
