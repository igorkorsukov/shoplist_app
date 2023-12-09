import '../../infrastructure/uid/id.dart';

class ShopItem {
  ID id = ID();
  String title = "";
  bool checked = false;
  ShopItem(this.id, {this.title = "", this.checked = false});
}

class ShopList {
  ID id = ID();
  String name = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList(this.id, {this.name = "", this.comment = ""});

  ShopList.empty();
}
