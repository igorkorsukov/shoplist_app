class ShopItem {
  String title = "";
  bool checked = false;
  ShopItem({this.title = "", this.checked = false});

  ShopItem clone() {
    return ShopItem(title: title, checked: checked);
  }
}

class ShopList {
  String name = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList({this.name = "", this.comment = ""});

  ShopList clone() {
    var l = ShopList(name: name, comment: comment);
    l.items = items.map((i) => i.clone()).toList();
    return l;
  }
}
