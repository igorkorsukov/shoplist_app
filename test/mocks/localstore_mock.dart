import 'package:shoplist/infrastructure/db/ilocalstore.dart';

class LocalStoreMock extends ILocalStore {
  final Map<String, String> data = {};

  @override
  Future<void> init(String prefix) async {}

  @override
  Future<bool> clear() {
    data.clear();
    return Future.value(true);
  }

  @override
  Future<List<String>> keys() async {
    return data.keys.toList();
  }

  @override
  Future<bool> write(String key, String value) async {
    data[key] = value;
    return true;
  }

  @override
  Future<String?> read(String key) async {
    return data[key];
  }

  @override
  Future<bool> remove(String key) async {
    data.remove(key);
    return true;
  }
}
