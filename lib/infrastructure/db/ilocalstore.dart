import 'package:shoplist/infrastructure/modularity/injectable.dart';

abstract class ILocalStore with Injectable {
  @override
  String interfaceId() => "ILocalStore";

  Future<void> init(String prefix);

  Future<bool> clear();
  Future<List<String>> keys();

  Future<bool> write(String key, String value);
  Future<String?> read(String key);
  Future<bool> remove(String key);
}
