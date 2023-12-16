import 'package:flutter/widgets.dart';

import '../infrastructure/uid/uid.dart';

const String LIST_ID_TYPE = "list";
const String CATEGORY_ID_TYPE = "category";

class ShopItem {
  Uid id = Uid.invalid;
  Uid categoryId = Uid.invalid;
  String title = "";
  bool checked = false;
  ShopItem(this.id, {this.categoryId = Uid.invalid, this.title = "", this.checked = false});
}

class ShopList {
  Uid id = Uid.invalid;
  String name = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList(this.id, {this.name = "", this.comment = ""});

  ShopList.empty();
}

class Category {
  Uid id = Uid.invalid;
  String title = "";
  Color? color;
  Category(this.id, {this.title = "", this.color});
}

typedef Categories = Map<Uid, Category>;
