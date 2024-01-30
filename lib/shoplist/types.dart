import 'package:flutter/material.dart';
import '../warp/uid/uid.dart';

const Color CATEGORY_DEFAULT_COLOR = Color(0xff607D8B);
const Category DEFAULT_CATEGORY = Category(Uid("default_category"), color: CATEGORY_DEFAULT_COLOR);

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
  String name;
  String title = "";
  String comment = "";
  List<PerformItem> items = [];

  Perform(this.name, {this.title = "", this.comment = ""});

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

  bool isEmpty() => _cats.isEmpty;

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
    Category(Uid("cat1"), color: Colors.pink),
    Category(Uid("cat2"), color: Colors.red),
    Category(Uid("cat3"), color: Colors.deepOrange),
    Category(Uid("cat4"), color: Colors.amber),
    Category(Uid("cat5"), color: Colors.lime),
    Category(Uid("cat6"), color: Colors.green),
    Category(Uid("cat7"), color: Colors.teal),
    Category(Uid("cat8"), color: Colors.cyan),
    Category(Uid("cat9"), color: Colors.blue),
    Category(Uid("cat10"), color: Colors.indigo),
    Category(Uid("cat11"), color: Colors.purple),
    Category(Uid("cat12"), color: Colors.brown),
  ];

  return Categories.fromList(list);
}
