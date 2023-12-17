import 'dart:ui';
import 'package:flutter/material.dart';
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

Categories defaultCategories() {
  List<Category> list = [
    Category(const Uid(CATEGORY_ID_TYPE, "cat1"), color: Colors.pink),
    Category(const Uid(CATEGORY_ID_TYPE, "cat2"), color: Colors.red),
    Category(const Uid(CATEGORY_ID_TYPE, "cat3"), color: Colors.deepOrange),
    Category(const Uid(CATEGORY_ID_TYPE, "cat4"), color: Colors.lime),
    Category(const Uid(CATEGORY_ID_TYPE, "cat5"), color: Colors.lightGreen),
    Category(const Uid(CATEGORY_ID_TYPE, "cat6"), color: Colors.teal),
  ];

  Categories cats = {};
  for (var c in list) {
    cats[c.id] = c;
  }

  return cats;
}
