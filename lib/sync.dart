import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import 'subscription/subscribable.dart';
import 'store.dart';

class Sync extends Subscribable {
  final String referenceName = "reference";
  final String editListName = "develop";

  bool _inited = false;
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);
  final Store _store = Store.instance;
  int _needSync = 0;
  int _synced = -1;
  final Duration _interval = const Duration(seconds: 10);
  Timer? _timer;

  Sync._internal();

  static final Sync instance = Sync._internal();

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _store.itemAdded.onReceive(this, (v) {
      _needSync += 1;
    });

    _store.itemRemoved.onReceive(this, (v) {
      _needSync += 1;
    });

    try {
      await _ydfs.makeDir('app:/shoplist');
    } catch (e) {
      log("catch: $e");
    }

    _inited = true;
  }

  void startSync() async {
    await sync();
    _timer = Timer(_interval, startSync);
  }

  void stopSync() {
    _timer?.cancel();
  }

  Future<void> sync() async {
    log("try sync...");
    if (_needSync == _synced) {
      log("no need sync");
      return;
    }

    try {
      List<String> names = [referenceName, editListName];
      for (var name in names) {
        var jsn = _store.loadItemsJson(name);
        var data = utf8.encode(jsn);
        await _ydfs.writeFile('app:/shoplist/$name.json', data, overwrite: true);
      }

      _synced = _needSync;
    } catch (e) {
      log("catch: $e");
    }

    log("sync finished");
  }
}
