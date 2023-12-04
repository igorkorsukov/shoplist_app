import 'dart:developer';
import 'item_model.dart';
import 'store.dart';

class EditItemModel {
  final String referenceName = "reference";
  final String editListName = "develop";
  Function? onChanged;

  final _store = Store.instance;
  ShopList _reference = ShopList();
  final Set<String> _current = {};
  final List<ShopItem> _filtered = [];
  String _searchString = "";

  void init() async {
    _reference = (await _store.loadShopList(referenceName)).clone();
    _sortByTitle(_reference.items);

    var list = await _store.loadShopList(editListName);
    for (var i in list.items) {
      _current.add(i.title);
    }

    _update();
  }

  void _sortByTitle(List<ShopItem> l) {
    l.sort((a, b) {
      return a.title.compareTo(b.title);
    });
  }

  List<ShopItem> items() {
    return _filtered;
  }

  void _update() {
    _filtered.clear();

    bool needAddNew = true;
    for (var i in _reference.items) {
      i.checked = _current.contains(i.title);
      if (_searchString.isEmpty) {
        _filtered.add(i);
      } else {
        var t = i.title.toLowerCase();
        var s = _searchString.toLowerCase();
        if (t.contains(s)) {
          _filtered.add(i);
        }

        if (t == s) {
          needAddNew = false;
        }
      }
    }

    if (_searchString.isNotEmpty && needAddNew) {
      _filtered.add(ShopItem(title: _searchString, isNew: true));
    }

    onChanged!();
  }

  void search(String val) {
    log("search: $val");
    _searchString = val;
    _update();
  }

  void changeItem(ShopItem item, bool isAdd) async {
    item.checked = isAdd;

    if (item.isNew) {
      item.isNew = false;
      _reference.items.add(item);
      _sortByTitle(_reference.items);
      _store.addItem(referenceName, item);
    }

    if (isAdd) {
      await _store.addItem(editListName, item);
      _current.add(item.title);
    } else {
      ShopItem editListItem = item.clone();
      editListItem.checked = false;
      await _store.removeItem(editListName, editListItem);
      _current.remove(item.title);
    }

    _update();
  }

  void addNewItem(String title) {
    // var item = Item(title: title);
    // _items.add(item);
    // _store.addItem(editListName, item);
    // onChanged!();
  }
}
