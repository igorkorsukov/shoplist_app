import 'dart:async';

import 'subscribable.dart';

class Channel<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();
  late final Stream<T> _stream = _controller.stream;

  void onReceive(Subscribable receiver, void Function(T v) f) {
    receiver.subscriptions.add(_stream.listen(f));
  }

  void send(T v) {
    _controller.add(v);
  }
}
