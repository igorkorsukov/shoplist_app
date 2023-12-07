import 'dart:developer';
import 'item_vm.dart';
import '../services/store.dart';

class EditItemModel {
  final String referenceName = "reference";
  final String editListName = "develop";
  Function? onChanged;

  final _store = Store.instance;
  ShopList _reference = ShopList();
  final Set<String> _current = {};
  final List<ShopItem> _filtered = [];
  String _searchString = "";
  ShopItem? _newItem;

  void init() async {
    _reference = (await _store.loadShopList(referenceName)).clone();

    var list = await _store.loadShopList(editListName);
    for (var i in list.items) {
      _current.add(i.title);
    }

    _update();
  }

  List<ShopItem> items() {
    return _filtered;
  }

  void _resort(List<ShopItem> l) {
    l.sort((a, b) {
      if (a.checked != b.checked) {
        return a.checked ? -1 : 1;
      }
      return a.title.compareTo(b.title);
    });
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

    _resort(_filtered);

    if (_searchString.isNotEmpty && needAddNew) {
      _newItem = ShopItem(title: _searchString);
      _filtered.add(_newItem!);
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

    if (_newItem == item) {
      _newItem = null;
      _reference.items.add(item);
      _store.addItem(referenceName, item);
    }

    if (isAdd) {
      ShopItem editListItem = item.clone();
      editListItem.checked = false;
      await _store.addItem(editListName, editListItem);
      _current.add(item.title);
    } else {
      await _store.removeItem(editListName, item);
      _current.remove(item.title);
    }

    _update();
  }
}
