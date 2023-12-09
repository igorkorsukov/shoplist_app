import '../services/syncservice.dart';
import '../../infrastructure/subscription/subscribable.dart';

class SyncModel extends Subscribable {
  Function(SyncStatus)? onStatusChanged;

  final Sync _sync = Sync.instance;

  SyncModel({
    this.onStatusChanged,
  });

  void init() async {
    _sync.statusChanged.onReceive(this, (v) {
      onStatusChanged!(v);
    });
  }

  void deinit() {
    unsubscribe();
  }

  SyncStatus status() => _sync.status;

  void startSync() {
    _sync.startSync();
  }
}
