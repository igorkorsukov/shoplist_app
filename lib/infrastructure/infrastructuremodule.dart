import 'modularity/modulesetup.dart';
import 'modularity/ioc.dart';

import 'db/ilocalstore.dart';
import 'db/internal/platform/general/localstore.dart';

//import 'db/localstore.dart';
import 'db/verstamp.dart';
import 'db/objectsstore.dart';
import 'db/syncservice.dart';
import 'db/cloudfs.dart';
import 'action/dispatcher.dart';

class InfrastructureModule extends ModuleSetup {
  final _localScore = LocalStore();
  final _store = ObjectsStore();
  final _sync = SyncService();
  final _dispatcher = ActionsDispatcher();

  @override
  String moduleName() => "infrastructure";

  @override
  void registerExports() {
    ioc().reg<Verstamp>(Verstamp());
    ioc().reg<ILocalStore>(_localScore);
    ioc().reg<ObjectsStore>(_store);
    ioc().reg<CloudFS>(CloudFS());
    ioc().reg<SyncService>(_sync);
    ioc().reg<ActionsDispatcher>(_dispatcher);
  }

  @override
  Future<void> onInit() async {
    await _localScore.init("com.kors.shoplist");
    await _store.init();
    await _sync.init();

    //_sync.startSync();
  }
}
