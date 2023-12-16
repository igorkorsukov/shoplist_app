import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';
import '../modularity/injectable.dart';

class CloudFS with Injectable {
  @override
  String interfaceId() => "ICloudFS";

  final _token = dotenv.env['YA_DISK_DEV_TOKEN'] ?? '';
  late final _ydfs = YandexDiskFS('https://cloud-api.yandex.net', _token);

  Future<void> makeDir(String path) async {
    return _ydfs.makeDir(path);
  }

  Future<List<int> /*bytes*/ > readFile(final String path, {bool maybeNotExists = false}) async {
    return _ydfs.readFile(path, maybeNotExists: maybeNotExists);
  }

  Future<void> writeFile(final String path, final Object data, {bool overwrite = false}) async {
    return _ydfs.writeFile(path, data, overwrite: overwrite);
  }
}
