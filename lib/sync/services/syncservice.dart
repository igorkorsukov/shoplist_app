//import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/subscription/channel.dart';

var log = print;

enum SyncStatus { notsynced, running, synced }

class Sync extends Subscribable {
  final String referenceName = "reference";
  final String editListName = "develop";

  SyncStatus status = SyncStatus.notsynced;
  final statusChanged = Channel<SyncStatus>();

  bool _inited = false;
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);

  final Duration _interval = const Duration(seconds: 10);
  Timer? _timer;
  DateTime timestamp = DateTime.utc(1970);

  Sync._internal();

  static final Sync instance = Sync._internal();

  Future<void> init() async {
    if (_inited) {
      return;
    }

    _inited = true;

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

    // _timer?.cancel();

    // await sync();

    // _timer = Timer(_interval, startSync);
  }

  void stopSync() {
    _timer?.cancel();
  }

  Future<void> sync() async {
    log("[Sync] try sync...");
  }
}
