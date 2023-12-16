import 'dart:developer';
import 'package:shoplist/shoplist/actions.dart';

import 'item_model.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/uid/id.dart';
import '../../infrastructure/uid/uidgen.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import '../services/shoplistservice.dart';

class EditItemModel with Subscribable {
  final Id referenceID = Id("reference");
  Id editListId = Id("shoplist");
  Function? onChanged;

  final serv = Inject<ShopListService>();
  final dispatcher = Inject<ActionsDispatcher>();
  final List<ShopItemV> _reference = [];
  final Set<Id> _current = {};
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
    var list = await serv().readShopList(referenceID);
    _makeItems(list);

    list = await serv().readShopList(editListId);
    _makeCurrent(list);

    serv().listChanged().onReceive(this, (name, list) async {
      if (name == referenceID) {
        list = list ?? await serv().readShopList(name);
        _makeItems(list);
      }

      if (name == editListId) {
        list = list ?? await serv().readShopList(name);
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
      _newItem = ShopItemV(Id(""), title: _searchString);
      _filtered.add(_newItem!);
    }

    onChanged!();
  }

  void search(String val) {
    _searchString = val;
    _update();
  }

  void changeItem(ShopItemV item, bool isAdd) async {
    Id itemId = Id();
    if (_newItem == item) {
      _newItem = null;
      itemId = UIDGen.newID();
      dispatcher().dispatch(addItem(referenceID, itemId, item.title, isAdd));
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