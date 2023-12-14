import '../../infrastructure/uid/id.dart';

class ShopItem {
  Id id = Id();
  String title = "";
  bool checked = false;
  ShopItem(this.id, {this.title = "", this.checked = false});
}

class ShopList {
  Id id = Id();
  String name = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList(this.id, {this.name = "", this.comment = ""});

  ShopList.empty();
}
