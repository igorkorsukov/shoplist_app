import '../infrastructure/uid/id.dart';

class ShopItem {
  Id id = Id.invalid;
  Id categoryId = Id.invalid;
  String title = "";
  bool checked = false;
  ShopItem(this.id, {this.categoryId = Id.invalid, this.title = "", this.checked = false});
}

class ShopList {
  Id id = Id.invalid;
  String name = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList(this.id, {this.name = "", this.comment = ""});

  ShopList.empty();
}
