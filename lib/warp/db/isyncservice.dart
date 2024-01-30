import 'package:shoplist/warp/modularity/injectable.dart';
import 'package:shoplist/warp/async/channel.dart';

enum SyncStatus { notsynced, running, synced }

abstract class ISyncService with Injectable {
  @override
  String interfaceId() => "ISyncService";

  SyncStatus status();
  Channel<SyncStatus> statusChanged();

  Future<void> sync();

  Future<void> startPeriodicSync();
  void stopPeriodicSync();
}
