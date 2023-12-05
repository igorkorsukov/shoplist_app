import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import 'package:shoplist/item_model.dart';
import 'subscription/subscribable.dart';
import 'subscription/channel.dart';
import 'store.dart';

enum SyncStatus { notsynced, running, synced }

class Sync extends Subscribable {
  final String referenceName = "reference";
  final String editListName = "develop";

  SyncStatus status = SyncStatus.notsynced;
  final statusChanged = Channel<SyncStatus>();

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

    _inited = true;

    _store.itemAdded.onReceive(this, (v) {
      _needSync += 1;
      _setStatus(SyncStatus.notsynced);
    });

    _store.itemRemoved.onReceive(this, (v) {
      _needSync += 1;
      _setStatus(SyncStatus.notsynced);
    });

    try {
      await _ydfs.makeDir('app:/shoplist');
    } catch (e) {
      log("[Sync] init: $e");
    }
  }

  void _setStatus(SyncStatus s) {
    status = s;
    statusChanged.send(s);
  }

  void startSync() async {
    if (status == SyncStatus.running) {
      return;
    }

    _timer?.cancel();

    await sync();

    _timer = Timer(_interval, startSync);
  }

  void stopSync() {
    _timer?.cancel();
  }

  Future<void> sync() async {
    log("[Sync] try sync...");
    if (_needSync == _synced) {
      log("[Sync] no need sync");
      return;
    }

    _setStatus(SyncStatus.running);

    List<String> names = [referenceName, editListName];

    try {
      for (var name in names) {
        // get remote list
        ShopList remoteList = ShopList();
        var bytes = await _ydfs.readFile('app:/shoplist/$name.json', maybeNotExists: true);
        if (bytes.isNotEmpty) {
          var str = utf8.decode(bytes);
          var jsn = json.decode(str);
          remoteList = ShopList.fromJson(jsn);
        }

        // get local
        ShopList localList = await _store.loadShopList(name);

        // merge
        ShopList mergedList = _merge(remoteList, localList);

        // write merged list
        {
          var jsn = mergedList.toJson();
          var str = json.encode(jsn);
          bytes = utf8.encode(str);
          await _ydfs.writeFile('app:/shoplist/$name.json', bytes, overwrite: true);
        }
      }

      _synced = _needSync;
      _setStatus(SyncStatus.synced);
    } catch (e) {
      log("[Sync] sync: $e");
      _setStatus(SyncStatus.notsynced);
    }

    log("[Sync] sync finished");
  }

  ShopList _merge(ShopList remoteList, ShopList localList) {
    //! TODO
    ShopList list = localList.clone();
    return list;
  }
}