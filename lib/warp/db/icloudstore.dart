import 'package:shoplist/warp/modularity/injectable.dart';

abstract class ICloudStore with Injectable {
  @override
  String interfaceId() => "ICloudStore";

  Future<void> put(final String name, final Object data, {bool overwrite = false});
  Future<List<int> /*bytes*/ > get(final String name, {bool maybeNotExists = false});
  Future<void> del(final String name);
}
