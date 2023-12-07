import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/item_vm.dart';
import '../../infrastructure/subscription/channel.dart';

class Store {
  final Channel<DateTime> dataChanged = Channel<DateTime>();
  final Channel<ShopList> listChanged = Channel<ShopList>();
  final Channel<(String name, ShopItem item)> itemAdded = Channel<(String name, ShopItem item)>();
  final Channel<(String name, ShopItem item)> itemRemoved = Channel<(String name, ShopItem item)>();

  bool _inited = false;
  final Map<String, ShopList> _cache = {};
  late SharedPreferences _prefs;

  Store._internal();

  static final Store instance = Store._internal();

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    // _prefs.clear();
    _inited = true;
  }

  Future<ShopList> loadShopList(name) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      list.name = name;
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

  Future<void> _writeList(ShopList list) async {
    assert(list.name.isNotEmpty);
    list.timestamp = DateTime.timestamp();
    var jsn = list.toJson();
    _prefs.setString(list.name, json.encode(jsn));
    dataChanged.send(list.timestamp);
  }

  Future<void> addItem(String name, ShopItem item) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      list.name = name;
      list.items.add(item);
      _cache[name] = list;

      _writeList(list);

      itemAdded.send((name, item));
    } catch (e) {
      log("[Store] addItem: $e");
    }
  }

  Future<void> updateItem(String name, ShopItem item) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      if (list.items.isEmpty) {
        return;
      }
      var idx = list.items.indexWhere((e) => e.title == item.title);
      list.items[idx] = item;
      _cache[name] = list;

      _writeList(list);
    } catch (e) {
      log("[Store] addItem: $e");
    }
  }

  Future<void> removeItem(String name, ShopItem item) async {
    try {
      ShopList list = _cache[name] ?? ShopList();
      if (list.items.isEmpty) {
        return;
      }
      list.items.removeWhere((e) => e.title == item.title);
      _cache[name] = list;

      _writeList(list);

      itemRemoved.send((name, item));
    } catch (e) {
      log("[Store] removeItem: $e");
    }
  }

  Future<void> updateList(ShopList list) async {
    try {
      _cache[list.name] = list;

      _writeList(list);

      listChanged.send(list);
    } catch (e) {
      log("[Store] removeItem: $e");
    }
  }
}
