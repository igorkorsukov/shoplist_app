import 'modularity/modulesetup.dart';
import 'modularity/ioc.dart';
import 'db/driver.dart';
import 'db/localstorage.dart';
import 'db/syncservice.dart';

class InfrastructureModule extends ModuleSetup {
  final _pstore = Driver();
  final _store = LocalStorage();
  final _sync = SyncService();

  @override
  String moduleName() => "infrastructure";

  @override
  void registerExports() {
    ioc().reg<Driver>(_pstore);
    ioc().reg<LocalStorage>(_store);
    ioc().reg<SyncService>(_sync);
  }

  @override
  Future<void> onInit() async {
    await _pstore.init("com.kors.shoplist.");
    await _store.init();
    await _sync.init();
  }
}
