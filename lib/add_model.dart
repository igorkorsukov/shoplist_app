import 'dart:developer';
import 'item_model.dart';
import 'store.dart';

class EditItemModel {
  final String referenceName = "reference";
  final String editListName = "develop";
  Function? onChanged;

  final _store = Store.instance;
  List<Item> _reference = [];
  final Set<String> _current = {};
  final List<Item> _filtered = [];
  String _searchString = "";

  void init() async {
    await _store.newList(referenceName);
    await _store.newList(editListName);

    _reference = await _store.loadItems(referenceName);
    _sortByTitle(_reference);

    var list = await _store.loadItems(editListName);
    for (var i in list) {
      _current.add(i.title);
    }

    _update();
  }

  void _sortByTitle(List<Item> l) {
    l.sort((a, b) {
      return a.title.compareTo(b.title);
    });
  }

  List<Item> items() {
    return _filtered;
  }

  void _update() {
    _filtered.clear();
    for (var i in _reference) {
      i.checked = _current.contains(i.title);
      if (_searchString.isEmpty) {
        _filtered.add(i);
      } else if (i.title.toLowerCase().contains(_searchString)) {
        _filtered.add(i);
      }
      onChanged!();
    }
  }

  void search(String val) {
    _searchString = val.toLowerCase();
    _update();
  }

  void changeItem(item, isAdd) async {
    item.checked = isAdd;

    if (isAdd) {
      await _store.addItem(editListName, item);
      _current.add(item.title);
    } else {
      await _store.removeItem(editListName, item);
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
