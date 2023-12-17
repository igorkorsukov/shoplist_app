import '../infrastructure/modularity/modulesetup.dart';
import '../infrastructure/modularity/ioc.dart';
import 'internal/shoplsitrepository.dart';
import 'internal/shoplistservice.dart';
import 'internal/shoplistactionscontroller.dart';
import 'ishoplistservice.dart';

class ShopListModule extends ModuleSetup {
  final _repo = ShopListRepository();
  final _serv = ShopListService();
  final _controller = ShopListActionsController();

  @override
  String moduleName() => "shoplist";

  @override
  void registerExports() {
    ioc().reg<ShopListRepository>(_repo);
    ioc().reg<IShopListService>(_serv);
  }

  @override
  Future<void> onInit() async {
    await _repo.init();
    _serv.init();
    _controller.init();
  }
}
