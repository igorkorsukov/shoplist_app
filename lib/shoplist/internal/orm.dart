import 'dart:convert';
import 'dart:ui';
import 'package:shoplist/infrastructure/db/storeobject.dart';
import 'package:shoplist/infrastructure/uid/uid.dart';
import '../types.dart';

const Uid CATEGORIES_OBJ_ID = Uid(CATEGORY_ID_TYPE, "categories_obj");

// list
extension ShopItemOrm on ShopItem {
  String toPayload() {
    Map<String, dynamic> jsn = {
      'categoryId': categoryId.toString(),
      'title': title,
      'checked': checked,
    };
    return json.encode(jsn);
  }

  ShopItem fromPayload(String payload) {
    assert(id.isValid());
    var jsn = json.decode(payload) as Map<String, dynamic>;
    categoryId = Uid.fromString(jsn['categoryId'] as String);
    title = jsn['title'] as String;
    checked = jsn['checked'] as bool;
    return this;
  }
}

extension ShopListOrm on ShopList {
  StoreObject toStoreObject() {
    StoreObject obj = StoreObject(id);
    obj.add(StoreRecord(const Uid(STORE_ID_TYPE, "title"), type: 'title', payload: title));
    obj.add(StoreRecord(const Uid(STORE_ID_TYPE, "comment"), type: 'comment', payload: comment));
    for (var it in items) {
      obj.add(StoreRecord(it.id, type: 'item', payload: it.toPayload()));
    }
    return obj;
  }

  ShopList fromStoreObject(StoreObject obj) {
    assert(id.isValid());
    for (var r in obj.records.values) {
      switch (r.type) {
        case 'title':
          title = r.payload;
          break;
        case 'comment':
          comment = r.payload;
          break;
        case 'item':
          items.add(ShopItem(r.id).fromPayload(r.payload));
      }
    }
    return this;
  }
}

// categories
extension CategoryOrm on Category {
  String toPayload() {
    Map<String, dynamic> jsn = {
      'title': title,
      'color': color.value,
    };
    return json.encode(jsn);
  }

  Category fromPayload(String payload) {
    assert(id.isValid());
    var jsn = json.decode(payload) as Map<String, dynamic>;
    title = jsn['title'] as String;
    color = Color(jsn['color'] as int);
    return this;
  }
}

extension CategoriesOrm on Categories {
  StoreObject toStoreObject() {
    StoreObject obj = StoreObject(CATEGORIES_OBJ_ID);
    forEach((key, cat) {
      obj.add(StoreRecord(cat.id, type: 'category', payload: cat.toPayload()));
    });
    return obj;
  }

  Categories fromStoreObject(StoreObject obj) {
    for (var r in obj.records.values) {
      switch (r.type) {
        case 'category':
          this[r.id] = Category(r.id).fromPayload(r.payload);
      }
    }
    return this;
  }
}
