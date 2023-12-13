import 'modularity/modulesetup.dart';
import 'modularity/ioc.dart';
import 'db/driver.dart';
import 'db/verstamp.dart';
import 'db/localstorage.dart';
import 'db/syncservice.dart';
import 'db/cloudfs.dart';

class InfrastructureModule extends ModuleSetup {
  final _driver = Driver();
  final _store = LocalStorage();
  final _sync = SyncService();

  @override
  String moduleName() => "infrastructure";

  @override
  void registerExports() {
    ioc().reg<Verstamp>(Verstamp());
    ioc().reg<Driver>(_driver);
    ioc().reg<LocalStorage>(_store);
    ioc().reg<CloudFS>(CloudFS());
    ioc().reg<SyncService>(_sync);
  }

  @override
  Future<void> onInit() async {
    await _driver.init("com.kors.shoplist.");
    await _store.init();
    await _sync.init();

    _sync.startSync();
  }
}
