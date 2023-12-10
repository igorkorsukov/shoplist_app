import '../../infrastructure/db/syncservice.dart';
import '../../infrastructure/subscription/subscribable.dart';

class SyncModel with Subscribable {
  Function(SyncStatus)? onStatusChanged;

  final SyncService _sync = SyncService();

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
