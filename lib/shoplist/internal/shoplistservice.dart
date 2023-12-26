import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/subscription/channel.dart';
import '../../infrastructure/modularity/inject.dart';
import 'shoplsitrepository.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class ShopListService extends IShopListService {
  final repo = Inject<ShopListRepository>();

  ShopListService();

  void init() {}

  // Reference
  @override
  Channel<Reference> referenceChanged() => repo().referenceChanged();

  @override
  Future<Reference> reference() async => repo().readReference();

  @override
  Future<void> addReferenceItem(ReferenceItem item) async {
    assert(item.id.isValid());
    Reference ref = await repo().readReference();
    ref.add(item);
    return repo().writeReference(ref);
  }

  @override
  Future<void> changeItemCategory(Uid refItemId, Uid categoryId) async {
    Reference ref = await repo().readReference();
    ReferenceItem? item = ref.item(refItemId);
    assert(item != null);
    item!.categoryId = categoryId;
    return repo().writeReference(ref);
  }

  @override
  Future<void> removeRefItem(Uid refItemId) async {
    Reference ref = await repo().readReference();
    ref.remove(refItemId);
    return repo().writeReference(ref);
  }

  // Categories
  @override
  Channel<Categories> categoriesChanged() => repo().categoriesChanged();

  @override
  Future<Categories> categories() async {
    Categories cats = await repo().readCategories();
    if (cats.isEmpty()) {
      cats = defaultCategories();
    }
    return cats;
  }

  @override
  Future<void> addCategory(Category cat) async {
    Categories cats = await repo().readCategories();
    cats.add(cat);
    return repo().writeCategories(cats);
  }

  @override
  Future<void> removeCategory(Uid catId) async {
    Categories cats = await repo().readCategories();
    cats.remove(catId);
    return repo().writeCategories(cats);
  }

  // Perform
  @override
  Channel<Perform> performChanged() => repo().performChanged();

  @override
  Future<Perform> perform(Uid listId) async => repo().readPerform(listId);

  @override
  Future<void> addPerformItem(Uid listId, PerformItem item) async {
    assert(item.id.isValid());
    Perform list = await repo().readPerform(listId);
    //! NOTE Id maybe not valid, if list not found
    list.id = listId;
    list.items.add(item);
    return repo().writePerform(list);
  }

  @override
  Future<void> checkPerformItem(Uid listId, Uid itemId, bool val) async {
    Perform list = await repo().readPerform(listId);
    PerformItem item = list.items.firstWhere((e) => e.id == itemId);
    item.checked = val;
    return repo().writePerform(list);
  }

  @override
  Future<void> removePerformItem(Uid listId, Uid itemId) async {
    Perform list = await repo().readPerform(listId);
    list.items.removeWhere((e) => e.id == itemId);
    return repo().writePerform(list);
  }

  @override
  Future<void> removePerformDone(Uid listId) async {
    Perform list = await repo().readPerform(listId);
    list.items.removeWhere((e) => e.checked == true);
    return repo().writePerform(list);
  }

  @override
  Future<void> removePerformAll(Uid listId) async {
    Perform list = await repo().readPerform(listId);
    list.items.clear();
    return repo().writePerform(list);
  }
}
