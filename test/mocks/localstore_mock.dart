import 'package:shoplist/warp/db/ilocalstore.dart';

class LocalStoreMock extends ILocalStore {
  final Map<String, String> data = {};

  @override
  Future<bool> put(String key, String value) async {
    data[key] = value;
    return true;
  }

  @override
  Future<String?> get(String key) async {
    return data[key];
  }

  @override
  Future<bool> del(String key) async {
    data.remove(key);
    return true;
  }
}
