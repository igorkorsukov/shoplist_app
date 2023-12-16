import '../../infrastructure/db/syncservice.dart';
import '../../infrastructure/subscription/subscribable.dart';
import '../../infrastructure/modularity/inject.dart';

class SyncModel with Subscribable {
  Function(SyncStatus)? onStatusChanged;

  final sync = Inject<SyncService>();

  SyncModel({
    this.onStatusChanged,
  });

  void init() async {
    sync().statusChanged.onReceive(this, (v) {
      onStatusChanged!(v);
    });
  }

  void deinit() {
    unsubscribe();
  }

  SyncStatus status() => sync().status;

  void startSync() {
    sync().startSync();
  }
}
