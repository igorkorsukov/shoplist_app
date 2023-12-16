import 'package:uuid/uuid.dart';
import 'uid.dart';

class UIDGen {
  static final _uuid = Uuid();

  static Uid newID(String type) {
    return Uid(type, _uuid.v1());
  }
}
