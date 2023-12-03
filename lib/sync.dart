import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
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
      log("catch: $e");
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
    log("try sync...");
    if (_needSync == _synced) {
      log("no need sync");
      return;
    }

    _setStatus(SyncStatus.running);

    try {
      List<String> names = [referenceName, editListName];
      for (var name in names) {
        var jsn = _store.loadItemsJson(name);
        var data = utf8.encode(jsn);
        await _ydfs.writeFile('app:/shoplist/$name.json', data, overwrite: true);
      }

      _synced = _needSync;
      _setStatus(SyncStatus.synced);
    } catch (e) {
      log("catch: $e");
      _setStatus(SyncStatus.notsynced);
    }

    log("sync finished");
  }
}
