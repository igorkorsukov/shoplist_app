import 'package:uuid/uuid.dart';
import 'id.dart';

class UIDGen {
  static final _uuid = Uuid();

  static Id newID() {
    return Id(_uuid.v1());
  }
}
