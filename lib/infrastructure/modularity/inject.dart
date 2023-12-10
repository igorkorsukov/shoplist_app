import 'ioc.dart';

class Inject<T> {
  T? _val;

  void set(T v) {
    _val = v;
  }

  T get() {
    if (_val != null) {
      return _val!;
    }
    _val = IoC.instance().get<T>();
    return _val!;
  }

  T call() => get();
  T get i => get();
}
