import 'dart:developer';
import 'package:shoplist/shoplist/actions.dart';

import 'item_model.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/uid/uidgen.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class EditItemModel with Subscribable {
  final Uid referenceId = const Uid(LIST_ID_TYPE, "reference");
  Uid editListId = Uid.invalid;
  Function? onChanged;

  final serv = Inject<IShopListService>();
  final dispatcher = Inject<ActionsDispatcher>();
  final List<ShopItemV> _reference = [];
  final Set<Uid> _current = {};
  final List<ShopItemV> _filtered = [];
  String _searchString = "";
  ShopItemV? _newItem;

  void _makeItems(list) {
    _reference.clear();
    for (var it in list.items) {
      _reference.add(ShopItemV(it.id, title: it.title, checked: it.checked));
    }
  }

  void _makeCurrent(list) {
    _current.clear();
    for (var i in list.items) {
      _current.add(i.id);
    }
  }

  void init() async {
    var list = await serv().shopList(referenceId);
    _makeItems(list);

    list = await serv().shopList(editListId);
    _makeCurrent(list);

    serv().listChanged().onReceive(this, (name, list) async {
      if (name == referenceId) {
        list = list ?? await serv().shopList(name);
        _makeItems(list);
      }

      if (name == editListId) {
        list = list ?? await serv().shopList(name);
        _makeCurrent(list);
      }

      _update();
    });

    _update();
  }

  void deinit() {
    unsubscribe();
  }

  List<ShopItemV> items() {
    return _filtered;
  }

  void _resort(List<ShopItemV> l) {
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
    for (var i in _reference) {
      i.checked = _current.contains(i.id);
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
      _newItem = ShopItemV(Uid.invalid, title: _searchString);
      _filtered.add(_newItem!);
    }

    onChanged!();
  }

  void search(String val) {
    _searchString = val;
    _update();
  }

  void changeItem(ShopItemV item, bool isAdd) async {
    Uid itemId = Uid.invalid;
    if (_newItem == item) {
      _newItem = null;
      itemId = UIDGen.newID(LIST_ID_TYPE);
      dispatcher().dispatch(addItem(referenceId, itemId, item.title, isAdd));
    } else {
      itemId = item.id;
    }

    if (isAdd) {
      dispatcher().dispatch(addItem(editListId, itemId, item.title, false));
    } else {
      dispatcher().dispatch(removeItem(editListId, itemId));
    }
  }
}
