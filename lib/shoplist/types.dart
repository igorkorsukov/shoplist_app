import 'dart:ui';
import 'package:flutter/material.dart';
import '../infrastructure/uid/uid.dart';

const String REFERENCE_ID_TYPE = "reference";
const String CATEGORY_ID_TYPE = "category";
const String PERFORM_ID_TYPE = "perform";

const Color CATEGORY_DEFAULT_COLOR = Color(0xff607D8B);
const Category DEFAULT_CATEGORY = Category(Uid(CATEGORY_ID_TYPE, "default_category"), color: CATEGORY_DEFAULT_COLOR);

class ReferenceItem {
  Uid id = Uid.invalid;
  Uid categoryId;
  String title;
  ReferenceItem(this.id, {this.categoryId = Uid.invalid, this.title = ""});
}

class Reference {
  final Map<Uid, ReferenceItem> _items = {};

  Reference();

  Reference.fromList(List<ReferenceItem> list) {
    for (var it in list) {
      _items[it.id] = it;
    }
  }

  List<ReferenceItem> items() => _items.values.toList();

  ReferenceItem? item(Uid itemId) => _items[itemId];

  void add(ReferenceItem item) {
    _items[item.id] = item;
  }

  void remove(Uid refItemId) {
    _items.remove(refItemId);
  }
}

class PerformItem {
  Uid id = Uid.invalid;
  Uid refId = Uid.invalid; // ref item id
  bool checked;
  PerformItem(this.id, this.refId, {this.checked = false});
}

class Perform {
  Uid id = Uid.invalid;
  String title = "";
  String comment = "";
  List<PerformItem> items = [];

  Perform(this.id, {this.title = "", this.comment = ""});

  PerformItem? item(Uid itemId) => items.firstWhere((e) => e.id == itemId);
}

class Category {
  final Uid id;
  final String title;
  final Color color;
  const Category(this.id, {this.title = "", this.color = CATEGORY_DEFAULT_COLOR});
}

class Categories {
  final Map<Uid, Category> _cats = {};

  Categories();
  Categories.fromList(List<Category> list) {
    for (var c in list) {
      _cats[c.id] = c;
    }
  }

  List<Category> toList() => _cats.values.toList();

  Category category(Uid categoryId) => _cats[categoryId] ?? DEFAULT_CATEGORY;

  void add(Category cat) {
    _cats[cat.id] = cat;
  }

  void remove(Uid catId) {
    _cats.remove(catId);
  }
}

Categories defaultCategories() {
  const List<Category> list = [
    Category(Uid(CATEGORY_ID_TYPE, "cat1"), color: Colors.pink),
    Category(Uid(CATEGORY_ID_TYPE, "cat2"), color: Colors.red),
    Category(Uid(CATEGORY_ID_TYPE, "cat3"), color: Colors.deepOrange),
    Category(Uid(CATEGORY_ID_TYPE, "cat4"), color: Colors.lime),
    Category(Uid(CATEGORY_ID_TYPE, "cat5"), color: Colors.lightGreen),
    Category(Uid(CATEGORY_ID_TYPE, "cat6"), color: Colors.teal),
  ];

  return Categories.fromList(list);
}
