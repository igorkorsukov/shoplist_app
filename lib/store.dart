import 'dart:developer';
import 'dart:convert';
import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_model.dart';
import 'subscription/channel.dart';

class Store {
  final Channel<(String name, Item item)> _itemAdded = Channel<(String name, Item item)>();
  final Channel<(String name, Item item)> _itemRemoved = Channel<(String name, Item item)>();

  bool _inited = false;
  final Map<String, List<Item>> _cache = {};
  late SharedPreferences _prefs;

  Store._internal();

  static final Store instance = Store._internal();
  Channel<(String, Item)> get itemAdded => _itemAdded;
  Channel<(String, Item)> get itemRemoved => _itemRemoved;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _inited = true;
  }

  List<Item> _deserialize(String jsn) {
    var obj = json.decode(jsn) as Map;
    var list = obj["items"] as List;

    var items = <Item>[];
    for (var it in list) {
      var itObj = it as Map;
      var item = Item();
      item.title = itObj["title"];
      items.add(item);
    }

    return items;
  }

  String _serialize(List<Item> items) {
    var list = <Map<String, dynamic>>[];
    for (var it in items) {
      Map<String, dynamic> itObj = {
        'title': it.title,
      };
      list.add(itObj);
    }

    Map<String, dynamic> obj = {'items': list};

    return json.encode(obj);
  }

  String loadItemsJson(String name) {
    return _prefs.getString(name) ?? "";
  }

  Future<UnmodifiableListView<Item>> loadItems(name) async {
    try {
      List<Item> items = _cache[name] ?? [];
      if (items.isNotEmpty) {
        return UnmodifiableListView(items);
      }

      String jsn = loadItemsJson(name);
      if (jsn.isEmpty) {
        return UnmodifiableListView(items);
      }

      items = _deserialize(jsn);
      _cache[name] = items;
      return UnmodifiableListView(items);
    } catch (e) {
      log("catch: $e");
      rethrow;
    }
  }

  Future<void> _writeItems(String name, List<Item> items) async {
    try {
      var jsn = _serialize(items);
      _prefs.setString(name, jsn);
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<void> addItem(String name, Item item) async {
    try {
      List<Item> items = _cache[name] ?? [];
      items.add(item);
      _cache[name] = items;

      _writeItems(name, items);

      _itemAdded.send((name, item));
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<void> removeItem(String name, Item item) async {
    try {
      List<Item> items = _cache[name] ?? [];
      items.removeWhere((e) => e.title == item.title);
      _cache[name] = items;

      _writeItems(name, items);

      _itemRemoved.send((name, item));
    } catch (e) {
      log("catch: $e");
    }
  }
}
