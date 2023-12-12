import 'package:shoplist/infrastructure/db/driver.dart';

class DriverMock implements Driver {
  final Map<String, String> data = {};

  @override
  Future<void> init(String prefix) async {}

  @override
  Future<bool> clear() {
    data.clear();
    return Future.value(true);
  }

  @override
  String? readString(String key) {
    return data[key];
  }

  @override
  Future<bool> writeString(String key, String value) {
    data[key] = value;
    return Future.value(true);
  }
}
