typedef ActionCode = String;
typedef ActionArgs = Map<String, dynamic>;

class Action {
  ActionCode code;
  ActionArgs args;

  Action(this.code, this.args);
}

Action makeAction(ActionCode code, [ActionArgs args = const {}]) {
  return Action(code, args);
}
