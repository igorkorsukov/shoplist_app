import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import '../icloudstore.dart';

export '../icloudstore.dart';

class CloudStore extends ICloudStore {
  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);
  String _path = "";

  Future<void> init(String path) async {
    _path = path;
    return _ydfs.makeDir(path);
  }

  @override
  Future<void> put(final String name, final Object data, {bool overwrite = false}) async {
    return _ydfs.writeFile("$_path/$name", data, overwrite: overwrite);
  }

  @override
  Future<List<int> /*bytes*/ > get(final String name, {bool maybeNotExists = false}) async {
    return _ydfs.readFile("$_path/$name", maybeNotExists: maybeNotExists);
  }

  @override
  Future<void> del(final String name) async {
    return _ydfs.remove("$_path/$name");
  }
}
