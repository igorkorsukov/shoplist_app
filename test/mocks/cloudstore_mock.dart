import 'package:shoplist/warp/db/icloudstore.dart';

class CloudStoreMock extends ICloudStore {
  final Map<String, List<int>> data = {};

  @override
  Future<void> put(final String name, final Object obj, {bool overwrite = false}) async {
    if (overwrite == false && data[name] != null) {
      assert(data[name] == null);
    }
    data[name] = obj as List<int>;
  }

  @override
  Future<List<int> /*bytes*/ > get(final String name, {bool maybeNotExists = false}) async {
    List<int>? bytes = data[name];
    if (bytes == null && maybeNotExists == false) {
      assert(bytes != null);
    }
    return Future.value(bytes ?? []);
  }

  @override
  Future<void> del(final String name) async {
    data.remove(name);
    return;
  }
}
