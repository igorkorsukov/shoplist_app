class Verstamp {
  final int _startTS = DateTime(2022, 12, 22).millisecondsSinceEpoch;
  int? _fixed;

  void setFixed(int ts) {
    _fixed = ts;
  }

  int verstamp() {
    return _fixed ?? (DateTime.now().millisecondsSinceEpoch - _startTS);
  }
}
