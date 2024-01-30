import 'package:shoplist/warp/modularity/inject.dart';
import 'package:shoplist/warp/async/subscribable.dart';
import 'package:shoplist/warp/db/isyncservice.dart';

// export SyncStatus
export 'package:shoplist/warp/db/isyncservice.dart';

class SyncModel with Subscribable {
  Function(SyncStatus)? onStatusChanged;

  final sync = Inject<ISyncService>();

  SyncModel({
    this.onStatusChanged,
  });

  void init() async {
    sync().statusChanged().onReceive(this, (v) {
      onStatusChanged!(v);
    });
  }

  void deinit() {
    unsubscribe();
  }

  SyncStatus status() => sync().status();

  void startSync() {
    sync().startPeriodicSync();
  }
}
