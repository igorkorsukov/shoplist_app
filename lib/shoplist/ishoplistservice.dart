import 'package:shoplist/infrastructure/modularity/injectable.dart';
import 'package:shoplist/infrastructure/subscription/channel.dart';
import 'package:shoplist/infrastructure/uid/uid.dart';
import 'types.dart';

abstract class IShopListService with Injectable {
  @override
  String interfaceId() => "IShopListService";

  // Reference
  Channel<Reference> referenceChanged();
  Future<Reference> reference();
  Future<void> addReferenceItem(ReferenceItem item);
  Future<void> changeItemCategory(Uid refItemId, Uid categoryId);
  Future<void> removeRefItem(Uid refItemId);

  // Categories
  Channel<Categories> categoriesChanged();
  Future<Categories> categories();
  Future<void> addCategory(Category cat);
  Future<void> removeCategory(Uid catId);

  // Perform
  Channel<Perform> performChanged();
  Future<Perform> perform(Uid listId);
  Future<void> addPerformItem(Uid listId, PerformItem item);
  Future<void> checkPerformItem(Uid listId, Uid itemId, bool val);
  Future<void> removePerformItem(Uid listId, Uid itemId);

  Future<void> removePerformDone(Uid listId);
  Future<void> removePerformAll(Uid listId);
}
