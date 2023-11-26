import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import 'types.dart';
import 'subscription/channel.dart';

class Store {
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);
  final Channel<Item> _itemAdded = Channel<Item>();

  Store._internal();

  static final Store instance = Store._internal();

  void init() async {
    try {
      await _ydfs.makeDir('app:/shoplist');
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<List<Item>> loadItems() async {
    try {
      List<String> files = await _ydfs.scanFiles('app:/favorites/');
      log("files: $files");

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

  Channel<Item> get itemAdded => _itemAdded;
  void addItem(Item item) async {
    try {
      await _ydfs.writeFile('app:/favorites/${item.title}', '{}');
      _itemAdded.send(item);
    } catch (e) {
      log("catch: $e");
    }
  }

  void deleteItem(Item item) async {
    try {
      await _ydfs.remove('app:/favorites/${item.title}');
    } catch (e) {
      log("catch: $e");
    }
  }
}
