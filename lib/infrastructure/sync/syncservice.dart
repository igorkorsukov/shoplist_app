//import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import '../subscription/subscribable.dart';
import '../subscription/channel.dart';
import '../db/localstorage.dart';
import '../db/storeobject.dart';
import '../uid/id.dart';

var log = print;

enum SyncStatus { notsynced, running, synced }

class _MergeResult {
  StoreObject? obj;
  bool isRemoteChanged = false;
  bool isLocalChanged = false;
}

class SyncService extends Subscribable {
  final String serviceName = "sync";
  SyncStatus status = SyncStatus.notsynced;
  final statusChanged = Channel<SyncStatus>();

  bool _inited = false;
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);
  final LocalStorage _store = LocalStorage.instance();

  final Duration _interval = const Duration(seconds: 10);
  Timer? _timer;
  SyncStatus _nextStatus = SyncStatus.notsynced;

  SyncService._internal();
  static final SyncService _instance = SyncService._internal();
  static SyncService instance() => SyncService._instance;

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _store.objectChanged().onReceive(this, (service, name) {
      if (serviceName == service) {
        return;
      }

      if (status == SyncStatus.running) {
        _nextStatus = SyncStatus.notsynced;
      } else {
        _setStatus(SyncStatus.notsynced);
      }
    });

    try {
      await _ydfs.makeDir('app:/shoplist');
    } catch (e) {
      log("[Sync] init: $e");
    }

    _inited = true;
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
    _setStatus(SyncStatus.running);
    _nextStatus = SyncStatus.synced;

    Set<String> names = _store.objectNames();

    try {
      for (var name in names) {
        // get remote object
        StoreObject? remoteObj;
        var bytes = await _ydfs.readFile('app:/shoplist/$name.json', maybeNotExists: true);
        if (bytes.isNotEmpty) {
          var str = utf8.decode(bytes);
          var jsn = json.decode(str);
          remoteObj = StoreObject.fromJson(jsn);
        }

        // get local
        StoreObject? localObj = _store.readObject(name);

        // merge
        _MergeResult mr = _merge(localObj, remoteObj);
        if (mr.obj == null) {
          return;
        }

        if (mr.isLocalChanged) {
          _store.writeObject(serviceName, name, mr.obj!);
        }

        if (mr.isRemoteChanged) {
          var jsn = mr.obj!.toJson();
          var str = json.encode(jsn);
          bytes = utf8.encode(str);
          await _ydfs.writeFile('app:/shoplist/$name.json', bytes, overwrite: true);
        }
      }

      _setStatus(_nextStatus);
    } catch (e) {
      log("[Sync] sync: $e");
      _setStatus(SyncStatus.notsynced);
    }

    log("[Sync] sync finished");
  }

  _MergeResult _merge(StoreObject? localObj, StoreObject? remoteObj) {
    var res = _MergeResult();

    // check null
    if (localObj == null) {
      res.isLocalChanged = true;
      res.obj = remoteObj;
      return res;
    } else if (remoteObj == null) {
      res.isRemoteChanged = true;
      res.obj = localObj;
      return res;
    }

    // actual merge
    res.obj = StoreObject();

    Set<ID> unitedIDs = localObj.records.keys.toSet();
    unitedIDs.addAll(remoteObj.records.keys);

    for (ID id in unitedIDs) {
      StoreRecord? lr = localObj.records[id];
      StoreRecord? rr = remoteObj.records[id];

      StoreRecord? mr;
      if (lr == null) {
        mr = rr;
        res.isLocalChanged = true;
      } else if (rr == null) {
        mr = lr;
        res.isRemoteChanged = true;
      } else {
        if (lr.timestamp == rr.timestamp) {
          // equal
          mr = lr;
        } else if (lr.timestamp.isAfter(rr.timestamp)) {
          mr = lr;
          res.isRemoteChanged = true;
        } else {
          mr = rr;
          res.isLocalChanged = true;
        }
      }

      assert(mr != null);
      if (mr != null) {
        res.obj!.records[mr.id] = mr;
      }
    }

    return res;
  }
}
