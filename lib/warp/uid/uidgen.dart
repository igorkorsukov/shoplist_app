import 'package:uuid/uuid.dart';
import 'uid.dart';

class UIDGen {
  static final _uuid = Uuid();

  static Uid newID() {
    return Uid(_uuid.v1());
  }
}
