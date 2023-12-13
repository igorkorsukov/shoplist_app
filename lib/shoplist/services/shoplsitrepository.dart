import 'dart:developer';
import 'dart:convert';
import '../../infrastructure/db/localstorage.dart';
import '../../infrastructure/db/storeobject.dart';
import '../../infrastructure/uid/id.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/injectable.dart';
import '../../infrastructure/modularity/inject.dart';
import 'shoplist.dart';

class ShopListRepository with Subscribable, Injectable {
  final String serviceName = "shoplist";
  final store = Inject<LocalStorage>();
  final _listChanged = Channel2<ID, ShopList?>();
  bool _inited = false;

  ShopListRepository();

  Channel2<ID, ShopList?> listChanged() => _listChanged;

  Future<void> init() async {
    if (_inited) {
      return;
    }
    _inited = true;

    store().objectChanged().onReceive(this, (service, id) {
      if (serviceName == service) {
        return;
      }
      _listChanged.send(id, null);
    });
  }

  Future<ShopList> readShopList(ID listId) async {
    StoreObject? obj = store().readObject(listId);
    if (obj == null) {
      return ShopList.empty();
    }

    ShopList list = _fromStoreObject(obj);
    return list;
  }

  Future<void> writeShopList(ShopList list) async {
    StoreObject obj = _toStoreObject(list);
    await store().writeObject(serviceName, obj);
    _listChanged.send(list.id, list);
  }

  ShopItem _itemFromJson(ID id, String payload) {
    var jsn = json.decode(payload) as Map<String, dynamic>;
    return ShopItem(id, title: jsn['title'] as String, checked: jsn['checked'] as bool);
  }

  String _itemToJson(ShopItem item) {
    Map<String, dynamic> jsn = {
      'title': item.title,
      'checked': item.checked,
    };
    return json.encode(jsn);
  }

  ShopList _fromStoreObject(StoreObject obj) {
    ShopList list = ShopList(obj.id);
    for (var r in obj.records.values) {
      switch (r.type) {
        case 'name':
          list.name = r.payload;
          break;
        case 'comment':
          list.comment = r.payload;
          break;
        case 'item':
          list.items.add(_itemFromJson(r.id, r.payload));
      }
    }
    return list;
  }

  StoreObject _toStoreObject(ShopList list) {
    StoreObject obj = StoreObject(list.id);
    obj.add(StoreRecord(ID("name"), type: 'name', payload: list.name));
    obj.add(StoreRecord(ID("comment"), type: 'comment', payload: list.comment));
    for (var it in list.items) {
      obj.add(StoreRecord(it.id, type: 'item', payload: _itemToJson(it)));
    }
    return obj;
  }
}
