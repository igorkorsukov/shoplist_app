import 'dart:async';

import 'subscribable.dart';

class Channel<V> {
  final StreamController<V> _controller = StreamController<V>.broadcast();
  late final Stream<V> _stream = _controller.stream;

  void onReceive(Subscribable receiver, void Function(V v) f) {
    receiver.subscriptions.add(_stream.listen(f));
  }

  void send(V v) {
    _controller.add(v);
  }
}

class _Arg2<V1, V2> {
  V1? val1;
  V2? val2;
  _Arg2(this.val1, this.val2);
}

class Channel2<V1, V2> {
  final _ch = Channel<_Arg2>();

  void onReceive(Subscribable receiver, void Function(V1 v1, V2 v2) f) {
    _ch.onReceive(receiver, (a2) {
      f(a2.val1, a2.val2);
    });
  }

  void send(V1 v1, V2 v2) {
    _ch.send(_Arg2(v1, v2));
  }
}
