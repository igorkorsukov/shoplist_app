class Id {
  static const Id invalid = Id("");

  final String _val;

  const Id(this._val);

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
