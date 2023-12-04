import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_model.dart';
import 'subscription/channel.dart';

class Store {
  final Channel<(String name, ShopItem item)> _itemAdded = Channel<(String name, ShopItem item)>();
  final Channel<(String name, ShopItem item)> _itemRemoved = Channel<(String name, ShopItem item)>();

  bool _inited = false;
  final Map<String, ShopList> _cache = {};
  late SharedPreferences _prefs;

  Store._internal();

  static final Store instance = Store._internal();
  Channel<(String, ShopItem)> get itemAdded => _itemAdded;
  Channel<(String, ShopItem)> get itemRemoved => _itemRemoved;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    //_prefs.clear();
    _inited = true;
  }

  Future<ShopList> loadShopList(name) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      if (list.items.isNotEmpty) {
        return list;
      }

      String jsnStr = _prefs.getString(name) ?? "";
      if (jsnStr.isEmpty) {
        return list;
      }

      list = ShopList.fromJson(json.decode(jsnStr) as Map<String, dynamic>);
      _cache[name] = list;

      return list;
    } catch (e) {
      log("[Store] loadShopList: $e");
      return ShopList();
    }
  }

  Future<void> _writeItems(String name, ShopList list) async {
    var jsn = list.toJson();
    _prefs.setString(name, json.encode(jsn));
  }

  Future<void> addItem(String name, ShopItem item) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      list.items.add(item);
      _cache[name] = list;

      _writeItems(name, list);

      _itemAdded.send((name, item));
    } catch (e) {
      log("[Store] addItem: $e");
    }
  }

  Future<void> removeItem(String name, ShopItem item) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      list.items.removeWhere((e) => e.title == item.title);
      _cache[name] = list;

      _writeItems(name, list);

      _itemRemoved.send((name, item));
    } catch (e) {
      log("[Store] removeItem: $e");
    }
  }
}
