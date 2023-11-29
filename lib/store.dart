import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import 'item_model.dart';
import 'subscription/channel.dart';

class Store {
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);
  final Channel<Item> _itemAdded = Channel<Item>();
  final Channel<Item> _itemRemoved = Channel<Item>();

  Store._internal();

  static final Store instance = Store._internal();
  Channel<Item> get itemAdded => _itemAdded;
  Channel<Item> get itemRemoved => _itemRemoved;

  void init() async {
    try {
      await _ydfs.makeDir('app:/shoplist');
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<void> newList(name) async {
    try {
      await _ydfs.makeDir('app:/shoplist/$name');
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<List<Item>> loadItems(name) async {
    try {
      List<String> files = await _ydfs.scanFiles('app:/shoplist/$name');

      var items = <Item>[];
      for (var file in files) {
        var item = Item();
        item.title = file;
        items.add(item);
      }

      return items;
    } catch (e) {
      log("catch: $e");
      rethrow;
    }
  }

  Future<void> addItem(String name, Item item) async {
    try {
      await _ydfs.writeFile('app:/shoplist/$name/${item.title}', '{}');
      _itemAdded.send(item);
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<void> removeItem(String name, Item item) async {
    try {
      await _ydfs.remove('app:/shoplist/$name/${item.title}');
      _itemRemoved.send(item);
    } catch (e) {
      log("catch: $e");
    }
  }
}
