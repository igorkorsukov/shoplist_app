import 'modularity/modulesetup.dart';
import 'modularity/ioc.dart';

import 'db/internal/verstampservice.dart';
import 'db/internal/platform/general/localstore.dart';
import 'db/internal/objectsstore.dart';
import 'db/internal/cloudstore.dart';
import 'db/internal/syncservice.dart';

import 'action/dispatcher.dart';

class InfrastructureModule extends ModuleSetup {
  final _verstampService = VerstampService();
  final _localScore = LocalStore();
  final _objectsStore = ObjectsStore();
  final _cloudStore = CloudStore();
  final _syncService = SyncService();
  final _dispatcher = ActionsDispatcher();

  @override
  String moduleName() => "warp";

  @override
  void registerExports() {
    ioc().reg<IVerstampService>(_verstampService);
    ioc().reg<ILocalStore>(_localScore);
    ioc().reg<IObjectsStore>(_objectsStore);
    ioc().reg<ICloudStore>(_cloudStore);
    ioc().reg<ISyncService>(_syncService);
    ioc().reg<ActionsDispatcher>(_dispatcher);
  }

  @override
  Future<void> onInit() async {
    await _localScore.init("com.kors.shoplist");
    await _cloudStore.init("app:/shoplist");
    await _syncService.init();
  }
}
