import 'package:shoplist/warp/db/iobjectsstore.dart';
import 'package:shoplist/warp/async/channel.dart';
import 'package:shoplist/warp/async/subscribable.dart';
import 'package:shoplist/warp/modularity/injectable.dart';
import 'package:shoplist/warp/modularity/inject.dart';
import '../types.dart';
import 'orm.dart';

class ShopListRepository with Subscribable, Injectable {
  @override
  String interfaceId() => "IShopListRepository";

  final store = Inject<IObjectsStore>();
  final _referenceChanged = Channel<Reference>();
  final _categoriesChanged = Channel<Categories>();
  final _performChanged = Channel<Perform>();
  bool _inited = false;

  ShopListRepository();

  Future<void> init() async {
    if (_inited) {
      return;
    }
    _inited = true;

    store().objectChanged().onReceive(this, (StoreObject obj) {
      switch (obj.name) {
        case REFERENCE_OBJ:
          _referenceChanged.send(Reference().fromStoreObject(obj));
          break;
        case CATEGORIES_OBJ:
          _categoriesChanged.send(Categories().fromStoreObject(obj));
          break;
        case PERFORM_OBJ:
          _performChanged.send(Perform(obj.name).fromStoreObject(obj));
          break;
      }
    });
  }

  // Reference
  Channel<Reference> referenceChanged() => _referenceChanged;

  Future<Reference> readReference() async {
    StoreObject? obj = await store().get(REFERENCE_OBJ);
    if (obj == null) {
      return Reference();
    }
    Reference ref = Reference().fromStoreObject(obj);
    return ref;
  }

  Future<void> writeReference(Reference ref) async {
    StoreObject obj = ref.toStoreObject();
    await store().put(obj);
    _referenceChanged.send(ref);
  }

  // Categories
  Channel<Categories> categoriesChanged() => _categoriesChanged;

  Future<Categories> readCategories() async {
    StoreObject? obj = await store().get(CATEGORIES_OBJ);
    if (obj == null) {
      return Categories();
    }
    Categories categories = Categories().fromStoreObject(obj);
    return categories;
  }

  Future<void> writeCategories(Categories categories) async {
    StoreObject obj = categories.toStoreObject();
    await store().put(obj);
    _categoriesChanged.send(categories);
  }

  // Perform
  Channel<Perform> performChanged() => _performChanged;

  Future<Perform> readPerform(String name) async {
    StoreObject? obj = await store().get(name);
    if (obj == null) {
      return Perform("");
    }
    Perform list = Perform(name).fromStoreObject(obj);
    return list;
  }

  Future<void> writePerform(Perform list) async {
    StoreObject obj = list.toStoreObject();
    await store().put(obj);
    _performChanged.send(list);
  }
}
