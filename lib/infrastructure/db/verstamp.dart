import '../modularity/injectable.dart';

enum VerstampMode { timestamp, increment, fixed }

class Verstamp with Injectable {
  VerstampMode _mode = VerstampMode.timestamp;
  final int _startTS = DateTime(2022, 12, 22).millisecondsSinceEpoch;
  int _value = 0;

  void setMode(mode) {
    _mode = mode;
  }

  void setValue(int v) {
    _value = v;
  }

  int verstamp() {
    switch (_mode) {
      case VerstampMode.timestamp:
        return (DateTime.now().millisecondsSinceEpoch - _startTS);
      case VerstampMode.increment:
        _value += 1;
        return _value;
      case VerstampMode.fixed:
        return _value;
    }
  }
}
