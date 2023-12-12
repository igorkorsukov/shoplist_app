import 'package:shoplist/infrastructure/db/cloudfs.dart';

class CloudFSMock implements CloudFS {
  final Map<String, List<int>> data = {};

  @override
  Future<void> makeDir(String path) async {
    return;
  }

  @override
  Future<List<int> /*bytes*/ > readFile(final String path, {bool maybeNotExists = false}) async {
    List<int>? bytes = data[path];
    if (bytes == null && maybeNotExists == false) {
      assert(bytes != null);
    }
    return Future.value(bytes ?? []);
  }

  @override
  Future<void> writeFile(final String path, final Object obj, {bool overwrite = false}) async {
    if (overwrite == false && data[path] != null) {
      assert(data[path] == null);
    }
    data[path] = obj as List<int>;
  }
}
