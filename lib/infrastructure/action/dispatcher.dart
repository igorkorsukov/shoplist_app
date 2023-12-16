import 'action.dart';
import '../modularity/injectable.dart';

export 'action.dart';

mixin Actionable {}

typedef ActionCallBack = void Function(Action action);

class ActionsDispatcher with Injectable {
  @override
  String interfaceId() => "IActionsDispatcher";

  void reg(Actionable client, ActionCode code, ActionCallBack call) {
    _ActionRegistration r = _ActionRegistration(client, code, call);
    _registrations.add(r);
  }

  void dispatch(Action action) {
    for (var r in _registrations) {
      if (r.code == action.code) {
        r.callback(action);
      }
    }
  }

// private:
  final List<_ActionRegistration> _registrations = [];
}

class _ActionRegistration {
  Actionable client;
  ActionCode code;
  ActionCallBack callback;

  _ActionRegistration(this.client, this.code, this.callback);
}
