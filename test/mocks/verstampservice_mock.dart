import 'package:shoplist/warp/db/iverstampservice.dart';

enum VerstampMode { increment, fixed }

class VerstampServiceMock extends IVerstampService {
  VerstampMode _mode = VerstampMode.fixed;
  int _value = 0;

  void setMode(mode) {
    _mode = mode;
  }

  void setValue(int v) {
    _value = v;
  }

  @override
  int verstamp() {
    switch (_mode) {
      case VerstampMode.increment:
        _value += 1;
        return _value;
      case VerstampMode.fixed:
        return _value;
    }
  }
}
