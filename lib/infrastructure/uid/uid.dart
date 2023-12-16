class Uid {
  static const Uid invalid = Uid("", "");

  final String _type;
  final String _val;

  const Uid(this._type, this._val);

  bool isValid() => _type.isNotEmpty && _val.isNotEmpty;

  String get type => _type;

  @override
  String toString() => "$_type|$_val";

  static Uid fromString(String str) {
    var pair = str.split('|');
    if (pair.length == 2) {
      return Uid(pair[0], pair[1]);
    } else {
      assert(pair.length == 2);
      return Uid.invalid;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Uid && _type == other._type && _val == other._val;
  }

  @override
  int get hashCode => Object.hash(_type, _val);
}
