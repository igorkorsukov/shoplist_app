import 'dart:async';

mixin Subscribable {
  List<StreamSubscription> subscriptions = [];

  void unsubscribe() {
    for (var s in subscriptions) {
      s.cancel();
    }
    subscriptions.clear();
  }
}
