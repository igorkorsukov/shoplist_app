class Id {
  String _val = "";

  Id([String v = ""]) {
    _val = v;
  }

  Id.zero();

  @override
  String toString() => _val;

  bool isValid() => _val.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is Id && _val == other._val;
  }

  @override
  int get hashCode => _val.hashCode;
}
