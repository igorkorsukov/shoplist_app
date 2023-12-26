import 'package:shoplist/infrastructure/modularity/inject.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class CategoriesModel {
  Function? onChanged;

  final serv = Inject<IShopListService>();
  List<Category> _categories = [];

  Future<void> init() async {
    var cats = await serv().categories();
    _categories = cats.toList();
    onChanged!();
  }

  List<Category> categories() {
    return _categories;
  }
}
