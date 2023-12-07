import 'subscribable.dart';
import 'channel.dart';

class Notification {
  final Channel<int> _ch = Channel<int>();

  void onNotify(Subscribable receiver, void Function() f) {
    _ch.onReceive(receiver, (dummy) {
      f();
    });
  }

  void notify() {
    _ch.send(0);
  }
}
