import 'injectable.dart';

IoC ioc() => IoC.instance();

class IoC {
  static IoC instance() => IoC._instance;

  void reg<T>(T p) {
    _doReg(T, p as Injectable);
  }

  void unreg<T>() {
    _doUnReg(T);
  }

  T get<T>() {
    Injectable? p = _doGet(T);
    return p as T;
  }

  void reset() {
    _map.clear();
  }

// private:

  IoC._internal();
  static final IoC _instance = IoC._internal();

  void _doReg(Type t, Injectable p) {
    var cp = _map[t];
    assert(cp == null, 'already registered');
    _map[t] = p;
  }

  void _doUnReg(Type t) {
    _map[t] = null;
  }

  Injectable? _doGet(Type t) {
    return _map[t];
  }

  final Map<Type, Injectable?> _map = {};
}
