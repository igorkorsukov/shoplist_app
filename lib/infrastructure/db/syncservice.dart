import 'dart:developer';
import 'dart:convert';
import 'dart:async';

import '../subscription/subscribable.dart';
import '../subscription/channel.dart';
import '../uid/uid.dart';
import '../modularity/inject.dart';
import '../modularity/injectable.dart';
import 'cloudfs.dart';
import 'objectsstore.dart';
import 'storeobject.dart';

enum SyncStatus { notsynced, running, synced }

class _MergeResult {
  StoreObject? obj;
  bool isRemoteChanged = false;
  bool isLocalChanged = false;
}

class SyncService with Subscribable, Injectable {
  @override
  String interfaceId() => "ISyncService";

  final String serviceName = "sync";
  SyncStatus status = SyncStatus.notsynced;
  final statusChanged = Channel<SyncStatus>();

  bool _inited = false;
  final cloud = Inject<CloudFS>();
  final store = Inject<ObjectsStore>();

  final Duration _interval = const Duration(seconds: 10);
  Timer? _timer;
  SyncStatus _nextStatus = SyncStatus.notsynced;

  SyncService();

  Future<void> init() async {
    if (_inited) {
      return;
    }

    store().objectChanged().onReceive(this, (service, name) {
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
      await cloud().makeDir('app:/shoplist');
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

  Future<void> _syncObject(Uid objId) async {
    // get remote object
    StoreObject? remoteObj;
    var bytes = await cloud().readFile('app:/shoplist/$objId.json', maybeNotExists: true);
    if (bytes.isNotEmpty) {
      var str = utf8.decode(bytes);
      var jsn = json.decode(str);
      remoteObj = StoreObject.fromJson(objId, jsn, deleted: true);
    }

    // get local
    StoreObject? localObj = await store().readObject(objId, deleted: true);

    // merge
    _MergeResult mr = _merge(localObj, remoteObj);
    if (mr.obj == null) {
      return;
    }

    if (mr.isLocalChanged) {
      await store().writeObject(serviceName, mr.obj!);
    }

    if (mr.isRemoteChanged) {
      var jsn = mr.obj!.toJson();
      var str = json.encode(jsn);
      bytes = utf8.encode(str);
      await cloud().writeFile('app:/shoplist/$objId.json', bytes, overwrite: true);
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

    assert(localObj.id == remoteObj.id);

    // actual merge
    res.obj = StoreObject(localObj.id);

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
