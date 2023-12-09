class ID {
  String _val = "";

  ID([String v = ""]) {
    _val = v;
  }

  ID.zero();

  @override
  String toString() => _val;

  bool isValid() => _val.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is ID && _val == other._val;
  }

  @override
  int get hashCode => _val.hashCode;
}
