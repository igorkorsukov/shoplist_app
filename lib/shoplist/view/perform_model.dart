import 'dart:developer';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/uid/uid.dart';
import '../ishoplistservice.dart';
import '../types.dart';
import 'item_model.dart';

class ShopListModel with Subscribable {
  Function? onChanged;
  Uid listId = const Uid(LIST_ID_TYPE, "shoplist");

  final serv = Inject<IShopListService>();
  final List<ShopItemV> _items = [];

  ShopListModel({
    this.onChanged,
  });

  void _makeItems(list) {
    _items.clear();
    for (var it in list.items) {
      _items.add(ShopItemV(it.id, title: it.title, checked: it.checked, color: CATEGORY_DEFAULT_COLOR));
    }
  }

  Future<void> init() async {
    serv().shopList(listId).then((list) {
      _makeItems(list);
      _resort();
      onChanged!();
    });

    serv().listChanged().onReceive(this, (Uid id, ShopList list) async {
      if (listId != id) {
        return;
      }

      _makeItems(list);
      _resort();
      onChanged!();
    });
  }

  void deinit() {
    unsubscribe();
  }

  void _resort() {
    _items.sort((a, b) {
      if (a.checked != b.checked) {
        return a.checked ? 1 : -1;
      }
      return a.title.compareTo(b.title);
    });
  }

  List<ShopItemV> items() {
    return _items;
  }
}
