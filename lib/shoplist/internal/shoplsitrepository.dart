import '../../infrastructure/db/objectsstore.dart';
import '../../infrastructure/db/storeobject.dart';
import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/injectable.dart';
import '../../infrastructure/modularity/inject.dart';
import '../types.dart';
import 'orm.dart';

class ShopListRepository with Subscribable, Injectable {
  @override
  String interfaceId() => "IShopListRepository";

  final store = Inject<ObjectsStore>();
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

    store().objectChanged().onReceive(this, (String sender, StoreObject obj) {
      if (interfaceId() == sender) {
        return;
      }

      switch (obj.id.type) {
        case REFERENCE_ID_TYPE:
          _referenceChanged.send(Reference().fromStoreObject(obj));
          break;
        case CATEGORY_ID_TYPE:
          _categoriesChanged.send(Categories().fromStoreObject(obj));
          break;
        case PERFORM_ID_TYPE:
          _performChanged.send(Perform(obj.id).fromStoreObject(obj));
          break;
      }
    });
  }

  // Reference
  Channel<Reference> referenceChanged() => _referenceChanged;

  Future<Reference> readReference() async {
    StoreObject? obj = await store().readObject(REFERENCE_OBJ_ID);
    if (obj == null) {
      return Reference();
    }
    Reference ref = Reference().fromStoreObject(obj);
    return ref;
  }

  Future<void> writeReference(Reference ref) async {
    StoreObject obj = ref.toStoreObject();
    await store().writeObject(interfaceId(), obj);
    _referenceChanged.send(ref);
  }

  // Categories
  Channel<Categories> categoriesChanged() => _categoriesChanged;

  Future<Categories> readCategories() async {
    StoreObject? obj = await store().readObject(CATEGORIES_OBJ_ID);
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

  // Perform
  Channel<Perform> performChanged() => _performChanged;

  Future<Perform> readPerform(Uid listId) async {
    StoreObject? obj = await store().readObject(listId);
    if (obj == null) {
      return Perform(Uid.invalid);
    }
    Perform list = Perform(listId).fromStoreObject(obj);
    return list;
  }

  Future<void> writePerform(Perform list) async {
    StoreObject obj = list.toStoreObject();
    await store().writeObject(interfaceId(), obj);
    _performChanged.send(list);
  }
}
