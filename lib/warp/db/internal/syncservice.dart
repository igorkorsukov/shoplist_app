import 'dart:developer';
import 'dart:convert';
import 'dart:async';

import 'package:shoplist/warp/async/subscribable.dart';
import 'package:shoplist/warp/async/channel.dart';
import 'package:shoplist/warp/uid/uid.dart';
import 'package:shoplist/warp/modularity/inject.dart';

import '../isyncservice.dart';
import '../icloudstore.dart';
import '../iobjectsstore.dart';

export '../isyncservice.dart';

class _MergeResult {
  StoreObject? obj;
  bool isRemoteChanged = false;
  bool isLocalChanged = false;
}

class SyncService extends ISyncService with Subscribable {
  final cloud = Inject<ICloudStore>();
  final store = Inject<IObjectsStore>();

  bool _inited = false;
  SyncStatus _status = SyncStatus.notsynced;
  final _statusChanged = Channel<SyncStatus>();

  final Duration _interval = const Duration(seconds: 10);
  Timer? _timer;
  SyncStatus _nextStatus = SyncStatus.notsynced;

  SyncService();

  Future<void> init() async {
    if (_inited) {
      return;
    }

    store().objectChanged().onReceive(this, (StoreObject obj) {
      if (_status == SyncStatus.running) {
        _nextStatus = SyncStatus.notsynced;
      } else {
        _setStatus(SyncStatus.notsynced);
      }
    });

    _inited = true;
  }

  @override
  SyncStatus status() => _status;

  @override
  Channel<SyncStatus> statusChanged() => _statusChanged;

  void _setStatus(SyncStatus s) {
    _status = s;
    _statusChanged.send(s);
  }

  @override
  Future<void> startPeriodicSync() async {
    if (_status == SyncStatus.running) {
      return;
    }

    _timer?.cancel();

    await sync();

    _timer = Timer(_interval, startPeriodicSync);
  }

  @override
  void stopPeriodicSync() {
    _timer?.cancel();
  }

  @override
  Future<void> sync() async {
    log("[Sync] try sync...");
    _setStatus(SyncStatus.running);
    _nextStatus = SyncStatus.synced;

    Set<Uid> objectIDs = await store().objectIDs();

    try {
      assert(objectIDs.isNotEmpty);

      if (objectIDs.length == 1) {
        await _syncObject(objectIDs.first);
        objectIDs = await store().objectIDs();
      }

      for (var objId in objectIDs) {
        await _syncObject(objId);
      }

      _setStatus(_nextStatus);
    } catch (e) {
      log("[Sync] sync: $e");
      _setStatus(SyncStatus.notsynced);
    }

    log("[Sync] sync finished");
  }

  Future<void> _syncObject(String name) async {
    // get remote object
    StoreObject? remoteObj;
    var bytes = await cloud().get('$name.json', maybeNotExists: true);
    if (bytes.isNotEmpty) {
      var str = utf8.decode(bytes);
      var jsn = json.decode(str);
      remoteObj = StoreObject.fromJson(name, jsn, includeDeletedRecs: true);
    }

    // get local
    StoreObject? localObj = await store().get(name, includeDeletedRecs: true);

    // merge
    _MergeResult mr = _merge(localObj, remoteObj);
    if (mr.obj == null) {
      return;
    }

    if (mr.isLocalChanged) {
      await store().put(mr.obj!);
    }

    if (mr.isRemoteChanged) {
      var jsn = mr.obj!.toJson();
      var str = json.encode(jsn);
      bytes = utf8.encode(str);
      await cloud().put('$name.json', bytes, overwrite: true);
    }
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

    assert(localObj.name == remoteObj.name);

    // actual merge
    res.obj = StoreObject(localObj.name);

    Set<Uid> unitedIDs = localObj.records.keys.toSet();
    unitedIDs.addAll(remoteObj.records.keys);

    for (Uid id in unitedIDs) {
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
        if (lr.verstamp == rr.verstamp) {
          // equal
          mr = lr;
        } else if (lr.verstamp > rr.verstamp) {
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
