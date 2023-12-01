import 'sync.dart';

class SyncModel {
  final Sync _sync = Sync.instance;

  void init() async {
    await _sync.init();
    _sync.startSync();
  }
}
