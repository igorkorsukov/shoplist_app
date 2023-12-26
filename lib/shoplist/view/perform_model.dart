import 'dart:developer';
import 'dart:ui';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/uid/uid.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class ShopItem {
  Uid id;
  String title;
  bool checked;
  Color color;
  ShopItem(this.id, {required this.title, required this.checked, required this.color});
}

class ShopListModel with Subscribable {
  Function? onChanged;
  Uid performId = const Uid(PERFORM_ID_TYPE, "shoplist");

  final serv = Inject<IShopListService>();
  Reference _reference = Reference();
  Categories _categories = Categories();
  Perform _perform = Perform(Uid.invalid);
  final List<ShopItem> _items = [];

  ShopListModel({
    this.onChanged,
  });

  void _makeItems(Reference ref, Categories cats, Perform perf) {
    _items.clear();
    for (PerformItem it in perf.items) {
      ReferenceItem? refItem = ref.item(it.refId);
      if (refItem == null) {
        log("not valid ref id: ${it.refId}");
        continue;
      }
      Category cat = cats.category(refItem.categoryId);

      _items.add(ShopItem(it.id, title: refItem.title, checked: it.checked, color: cat.color));
    }

    _resort();
    onChanged!();
  }

  Future<void> init() async {
    // load
    _reference = await serv().reference();
    _categories = await serv().categories();
    _perform = await serv().perform(performId);

    // update
    _makeItems(_reference, _categories, _perform);

    // subscribe
    serv().referenceChanged().onReceive(this, (Reference ref) async {
      _reference = ref;
      _makeItems(_reference, _categories, _perform);
    });

    serv().categoriesChanged().onReceive(this, (Categories cats) async {
      _categories = cats;
      _makeItems(_reference, _categories, _perform);
    });

    serv().performChanged().onReceive(this, (Perform perf) async {
      if (perf.id == performId) {
        _perform = perf;
        _makeItems(_reference, _categories, _perform);
      }
    });
  }

  void deinit() {
    unsubscribe();
  }

  void _resort() {
    _items.sort((a, b) {
      if (a.checked != b.checked) {
        return a.checked ? 1 : -1;
      } else if (a.color != b.color) {
        return a.color.value.compareTo(b.color.value);
      }
      return a.title.compareTo(b.title);
    });
  }

  List<ShopItem> items() {
    return _items;
  }
}
