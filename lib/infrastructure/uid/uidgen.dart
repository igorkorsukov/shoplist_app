import 'package:uuid/uuid.dart';
import 'id.dart';

class UIDGen {
  static final _uuid = Uuid();

  static ID newID() {
    return ID(_uuid.v1());
  }
}
