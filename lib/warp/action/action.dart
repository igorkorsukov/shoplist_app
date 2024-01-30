typedef ActionCode = String;
typedef ActionArgs = Map<String, dynamic>;

abstract class Action {
  final ActionCode code;
  Action(this.code);
}
