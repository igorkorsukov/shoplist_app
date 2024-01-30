class Uid {
  static const Uid invalid = Uid("");

  final String _val;

  const Uid(this._val);

  bool isValid() => _val.isNotEmpty;

  @override
  String toString() => _val;

  static Uid fromString(String str) {
    return Uid(str);
  }

  @override
  bool operator ==(Object other) {
    return other is Uid && _val == other._val;
  }

  @override
  int get hashCode => _val.hashCode;
}
