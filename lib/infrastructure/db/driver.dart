import 'package:shared_preferences/shared_preferences.dart';
import '../modularity/injectable.dart';

class Driver with Injectable {
  late SharedPreferences _prefs;

  Future<void> init(String prefix) async {
    SharedPreferences.setPrefix(prefix);
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> clear() {
    return _prefs.clear();
  }

  String? readString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> writeString(String key, String value) {
    return _prefs.setString(key, value);
  }
}
