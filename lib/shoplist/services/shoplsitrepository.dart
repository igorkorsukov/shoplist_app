import 'dart:developer';
import 'dart:convert';
import '../../infrastructure/db/localstorage.dart';
import '../../infrastructure/db/storeobject.dart';
import 'shoplist.dart';

class ShopListRepository {
  final LocalStorage _store = LocalStorage.instance();

  ShopItem _itemFromJson(String str) {
    var jsn = json.decode(str) as Map<String, dynamic>;
    return ShopItem(title: jsn['title'] as String, checked: jsn['checked'] as bool);
  }

  String _itemToJson(ShopItem item) {
    Map<String, dynamic> jsn = {
      'title': item.title,
      'checked': item.checked,
    };
    return json.encode(jsn);
  }

  ShopList _fromStoreObject(StoreObject obj) {
    ShopList list = ShopList();
    for (var r in obj.resords) {
      switch (r.key) {
        case 'name':
          list.name = r.value;
          break;
        case 'comment':
          list.comment = r.value;
          break;
        case 'item':
          list.items.add(_itemFromJson(r.value));
      }
    }
    return list;
  }

  StoreObject toStoreObject(ShopList list) {
    StoreObject obj = StoreObject();
    obj.resords.add(StoreRecord(key: 'name', value: list.name));
    obj.resords.add(StoreRecord(key: 'comment', value: list.comment));
    for (var it in list.items) {
      obj.resords.add(StoreRecord(key: 'item', value: _itemToJson(it)));
    }
    return obj;
  }

  Future<ShopList> readShopList(name) async {
    StoreObject? obj = _store.readObject(name);
    if (obj == null) {
      return ShopList();
    }

    ShopList list = _fromStoreObject(obj);
    return list;
  }

  Future<void> writeShopList(ShopList list) async {
    StoreObject obj = toStoreObject(list);
    _store.writeObject(list.name, obj);
  }
}
