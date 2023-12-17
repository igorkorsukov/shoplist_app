import 'package:shoplist/shoplist/internal/orm.dart';

import '../../infrastructure/db/localstorage.dart';
import '../../infrastructure/db/storeobject.dart';
import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/injectable.dart';
import '../../infrastructure/modularity/inject.dart';
import '../types.dart';

class ShopListRepository with Subscribable, Injectable {
  @override
  String interfaceId() => "IShopListRepository";

  final store = Inject<LocalStorage>();
  final _listChanged = Channel2<Uid, ShopList>();
  final _categoriesChanged = Channel<Categories>();
  bool _inited = false;

  ShopListRepository();

  // list
  Channel2<Uid, ShopList> listChanged() => _listChanged;

  Future<void> init() async {
    if (_inited) {
      return;
    }
    _inited = true;

    store().objectChanged().onReceive(this, (String sender, StoreObject obj) {
      if (interfaceId() == sender) {
        return;
      }

      switch (obj.id.type) {
        case LIST_ID_TYPE:
          _listChanged.send(obj.id, ShopList(obj.id).fromStoreObject(obj));
          break;
        case CATEGORY_ID_TYPE:
          _categoriesChanged.send(Categories().fromStoreObject(obj));
          break;
      }
    });
  }

  Future<ShopList> readShopList(Uid listId) async {
    StoreObject? obj = store().readObject(listId);
    if (obj == null) {
      return ShopList.empty();
    }

    ShopList list = ShopList(listId).fromStoreObject(obj);
    return list;
  }

  Future<void> writeShopList(ShopList list) async {
    StoreObject obj = list.toStoreObject();
    await store().writeObject(interfaceId(), obj);
    _listChanged.send(list.id, list);
  }

  // categories
  Channel<Categories> categoriesChanged() => _categoriesChanged;

  Future<Categories> readCategories() async {
    StoreObject? obj = store().readObject(CATEGORIES_OBJ_ID);
    if (obj == null) {
      return Categories();
    }

    Categories categories = Categories().fromStoreObject(obj);
    return categories;
  }

  Future<void> writeCategories(Categories categories) async {
    StoreObject obj = categories.toStoreObject();
    await store().writeObject(interfaceId(), obj);
    _categoriesChanged.send(categories);
  }
}
