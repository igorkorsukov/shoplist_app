import 'dart:convert';
import 'dart:ui';
import 'package:shoplist/warp/db/storeobject.dart';
import 'package:shoplist/warp/uid/uid.dart';
import '../types.dart';

const String REFERENCE_OBJ = "reference";
const String CATEGORIES_OBJ = "categories";
const String PERFORM_OBJ = "perform";

// Reference
extension ReferenceItemOrm on ReferenceItem {
  String toPayload() {
    Map<String, dynamic> jsn = {
      'categoryId': categoryId.toString(),
      'title': title,
    };
    return json.encode(jsn);
  }

  ReferenceItem fromPayload(String payload) {
    assert(id.isValid());
    var jsn = json.decode(payload) as Map<String, dynamic>;
    categoryId = Uid.fromString(jsn['categoryId'] as String);
    title = jsn['title'] as String;
    return this;
  }
}

extension ReferenceOrm on Reference {
  StoreObject toStoreObject() {
    StoreObject obj = StoreObject(REFERENCE_OBJ);
    for (var it in items()) {
      obj.add(StoreRecord(it.id, payload: it.toPayload()));
    }
    return obj;
  }

  Reference fromStoreObject(StoreObject obj) {
    for (var r in obj.records.values) {
      add(ReferenceItem(r.id).fromPayload(r.payload));
    }
    return this;
  }
}

// Categories
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
    return Category(id, title: jsn['title'] as String, color: Color(jsn['color'] as int));
  }
}

extension CategoriesOrm on Categories {
  StoreObject toStoreObject() {
    StoreObject obj = StoreObject(CATEGORIES_OBJ);
    for (var cat in toList()) {
      obj.add(StoreRecord(cat.id, payload: cat.toPayload()));
    }
    return obj;
  }

  Categories fromStoreObject(StoreObject obj) {
    for (var r in obj.records.values) {
      add(Category(r.id).fromPayload(r.payload));
    }
    return this;
  }
}

// Perform
extension PerformItemOrm on PerformItem {
  String toPayload() {
    Map<String, dynamic> jsn = {
      'refId': refId.toString(),
      'checked': checked,
    };
    return json.encode(jsn);
  }

  PerformItem fromPayload(String payload) {
    assert(id.isValid());
    var jsn = json.decode(payload) as Map<String, dynamic>;
    refId = Uid.fromString(jsn['refId'] as String);
    checked = jsn['checked'] as bool;
    return this;
  }
}

extension PerformeOrm on Perform {
  StoreObject toStoreObject() {
    StoreObject obj = StoreObject(PERFORM_OBJ);
    obj.add(StoreRecord(const Uid("title"), type: 'title', payload: title));
    obj.add(StoreRecord(const Uid("comment"), type: 'comment', payload: title));
    for (var it in items) {
      obj.add(StoreRecord(it.id, type: 'item', payload: it.toPayload()));
    }
    return obj;
  }

  Perform fromStoreObject(StoreObject obj) {
    for (var r in obj.records.values) {
      switch (r.type) {
        case 'title':
          title = r.payload;
        case 'comment':
          comment = r.payload;
        case 'item':
          items.add(PerformItem(r.id, Uid.invalid).fromPayload(r.payload));
      }
    }
    return this;
  }
}
