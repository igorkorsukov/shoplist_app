import '../../infrastructure/uid/id.dart';

class ShopItem {
  ID id = ID();
  String title = "";
  bool checked = false;
  ShopItem(this.id, {this.title = "", this.checked = false});

  ShopItem clone() {
    return ShopItem(id, title: title, checked: checked);
  }
}

class ShopList {
  ID id = ID();
  String name = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList(this.id, {this.name = "", this.comment = ""});

  ShopList.empty();

  ShopList clone() {
    var l = ShopList(id, name: name, comment: comment);
    l.items = items.map((i) => i.clone()).toList();
    return l;
  }
}
