import 'dart:developer';
import 'dart:convert';
import '../../infrastructure/db/localstorage.dart';
import '../../infrastructure/db/storeobject.dart';
import '../../infrastructure/uid/id.dart';
import 'shoplist.dart';

class ShopListRepository {
  final LocalStorage _store = LocalStorage.instance();

  ShopItem _itemFromJson(String id, String payload) {
    var jsn = json.decode(payload) as Map<String, dynamic>;
    return ShopItem(ID(id), title: jsn['title'] as String, checked: jsn['checked'] as bool);
  }

  String _itemToJson(ShopItem item) {
    Map<String, dynamic> jsn = {
      'title': item.title,
      'checked': item.checked,
    };
    return json.encode(jsn);
  }

  ShopList fromStoreObject(StoreObject obj) {
    ShopList list = ShopList.empty();
    for (var r in obj.resords) {
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

  StoreObject toStoreObject(ShopList list) {
    StoreObject obj = StoreObject();
    obj.resords.add(StoreRecord(type: 'name', id: "name", payload: list.name));
    obj.resords.add(StoreRecord(type: 'comment', id: "comment", payload: list.comment));
    for (var it in list.items) {
      obj.resords.add(StoreRecord(type: 'item', id: it.id.toString(), payload: _itemToJson(it)));
    }
    return obj;
  }

  Future<ShopList> readShopList(name) async {
    StoreObject? obj = _store.readObject(name);
    if (obj == null) {
      return ShopList.empty();
    }

    ShopList list = fromStoreObject(obj);
    return list;
  }

  Future<void> writeShopList(ShopList list) async {
    StoreObject obj = toStoreObject(list);
    _store.writeObject(list.name, obj);
  }
}
