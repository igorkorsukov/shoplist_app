import '../infrastructure/modularity/modulesetup.dart';
import '../infrastructure/modularity/ioc.dart';
import 'services/shoplsitrepository.dart';
import 'services/shoplistservice.dart';

class ShopListModule extends ModuleSetup {
  final _repo = ShopListRepository();
  final _serv = ShopListService();

  @override
  String moduleName() => "shoplist";

  @override
  void registerExports() {
    ioc().reg<ShopListRepository>(_repo);
    ioc().reg<ShopListService>(_serv);
  }

  @override
  Future<void> onInit() async {
    await _repo.init();
    _serv.init();
  }
}
