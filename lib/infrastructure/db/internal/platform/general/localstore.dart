import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../ilocalstore.dart';

class LocalStore extends ILocalStore {
  Directory _dir = Directory.systemTemp;

  LocalStore();

  @override
  Future<void> init(String prefix) async {
    var docs = await getApplicationDocumentsDirectory();
    log("ApplicationDocumentsDirectory: ${docs.path}");
    _dir = Directory("${docs.path}/$prefix");
    var exists = await _dir.exists();
    if (!exists) {
      _dir.create(recursive: true);
    }
  }

  @override
  Future<bool> clear() async {
    await _dir.delete(recursive: true);
    return true;
  }

  @override
  Future<List<String>> keys() async {
    await for (var entity in _dir.list(recursive: true, followLinks: false)) {
      print(entity.path);
    }
    return [];
  }

  @override
  Future<bool> write(String key, String value) async {
    log("write $key: $value");
    var file = File('${_dir.path}/$key');
    file.writeAsStringSync(value, flush: true);
    return true;
  }

  @override
  Future<String?> read(String key) async {
    var file = File('${_dir.path}/$key');
    bool exists = await file.exists();
    if (!exists) {
      return null;
    }
    return file.readAsString();
  }

  @override
  Future<bool> remove(String key) async {
    var file = File('${_dir.path}/$key');
    bool exists = await file.exists();
    if (!exists) {
      return true;
    }
    await file.delete();
    return true;
  }
}
