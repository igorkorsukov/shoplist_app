import 'dart:ui';
import '../infrastructure/uid/uid.dart';

const String LIST_ID_TYPE = "list";
const String CATEGORY_ID_TYPE = "category";
const Color CATEGORY_DEFAULT_COLOR = Color(0xff607D8B);

class ShopItem {
  Uid id = Uid.invalid;
  Uid categoryId = Uid.invalid;
  String title = "";
  bool checked = false;
  ShopItem(this.id, {this.categoryId = Uid.invalid, this.title = "", this.checked = false});
}

class ShopList {
  Uid id = Uid.invalid;
  String title = "";
  String comment = "";
  List<ShopItem> items = [];

  ShopList(this.id, {this.title = "", this.comment = ""});

  ShopList.empty();
}

class Category {
  Uid id;
  String title;
  Color color;
  Category(this.id, {this.title = "", this.color = CATEGORY_DEFAULT_COLOR});
}

typedef Categories = Map<Uid, Category>;
