class ShopItem {
  String title = "";
  bool checked = false;
  ShopItem({this.title = "", this.checked = false});

  ShopItem clone() {
    return ShopItem(title: title, checked: checked);
  }

  factory ShopItem.fromJson(Map<String, dynamic> data) {
    return ShopItem(
      title: data['title'] as String,
      checked: data['checked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'checked': checked,
    };
  }
}

class ShopList {
  String name = "";
  String comment = "";
  List<ShopItem> items = [];
  DateTime timestamp = DateTime.utc(1970);

  ShopList({this.name = "", this.comment = ""});

  ShopList clone() {
    var l = ShopList(name: name, comment: comment);
    l.items = items.map((i) => i.clone()).toList();
    return l;
  }

  factory ShopList.fromJson(Map<String, dynamic> data) {
    final itemsData = data['items'] as List<dynamic>?;
    var l = ShopList(name: data['name'] as String, comment: data['comment'] as String);
    l.items = itemsData!.map((itemData) => ShopItem.fromJson(itemData as Map<String, dynamic>)).toList();
    l.timestamp = DateTime.parse(data['timestamp'] as String);
    return l;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'comment': comment,
      'items': items.map((item) => item.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
