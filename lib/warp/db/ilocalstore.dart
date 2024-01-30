import 'package:shoplist/warp/modularity/injectable.dart';

abstract class ILocalStore with Injectable {
  @override
  String interfaceId() => "ILocalStore";

  Future<bool> put(String key, String value);
  Future<String?> get(String key);
  Future<bool> del(String key);
}
