import 'package:shoplist/warp/modularity/injectable.dart';
import 'package:shoplist/warp/async/channel.dart';
import 'package:shoplist/warp/uid/uid.dart';
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
  Future<Perform> perform(String name);
  Future<void> addPerformItem(String name, PerformItem item);
  Future<void> checkPerformItem(String name, Uid itemId, bool val);
  Future<void> removePerformItem(String name, Uid itemId);

  Future<void> removePerformDone(String name);
  Future<void> removePerformAll(String name);
}
