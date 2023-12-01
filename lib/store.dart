import 'dart:developer';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import 'item_model.dart';
import 'subscription/channel.dart';

class Store {
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);
  final Channel<(String name, Item item)> _itemAdded = Channel<(String name, Item item)>();
  final Channel<(String name, Item item)> _itemRemoved = Channel<(String name, Item item)>();

  final Map<String, List<Item>> _cache = {};

  Store._internal();

  static final Store instance = Store._internal();
  Channel<(String, Item)> get itemAdded => _itemAdded;
  Channel<(String, Item)> get itemRemoved => _itemRemoved;

  void init() async {
    try {
      await _ydfs.makeDir('app:/shoplist');
    } catch (e) {
      log("catch: $e");
    }
  }

  List<Item> _deserialize(List<int> bytes) {
    var str = utf8.decode(bytes);
    var obj = json.decode(str) as Map;
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

  List<int> _serialize(List<Item> items) {
    var list = <Map<String, dynamic>>[];
    for (var it in items) {
      Map<String, dynamic> itObj = {
        'title': it.title,
      };
      list.add(itObj);
    }

    Map<String, dynamic> obj = {'items': list};

    var str = json.encode(obj);
    return utf8.encode(str);
  }

  Future<UnmodifiableListView<Item>> loadItems(name) async {
    try {
      List<Item> items = _cache[name] ?? [];
      if (items.isNotEmpty) {
        return UnmodifiableListView(items);
      }

      bool exists = await _ydfs.exists('app:/shoplist/$name.json');
      if (!exists) {
        return UnmodifiableListView(items);
      }

      var data = await _ydfs.readFile('app:/shoplist/$name.json');
      items = _deserialize(data);
      _cache[name] = items;
      return UnmodifiableListView(items);
    } catch (e) {
      log("catch: $e");
      rethrow;
    }
  }

  Future<void> _writeItems(String name, List<Item> items) async {
    try {
      var data = _serialize(items);
      await _ydfs.remove('app:/shoplist/$name.json');
      _ydfs.writeFile('app:/shoplist/$name.json', data);
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
