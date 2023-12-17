import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import '../../infrastructure/uid/uid.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class ShopListActionsController with Actionable {
  final dispatcher = Inject<ActionsDispatcher>();
  final serv = Inject<IShopListService>();

  void init() {
    // Item
    dispatcher().reg(this, "add_item", (Action act) {
      serv().addItem(act.args["listId"] as Uid,
          ShopItem(act.args["itemId"] as Uid, title: act.args["title"], checked: act.args["checked"]));
    });

    dispatcher().reg(this, "remove_item", (Action act) {
      serv().removeItem(act.args["listId"] as Uid, act.args["itemId"] as Uid);
    });

    dispatcher().reg(this, "check_item", (Action act) {
      serv().checkItem(act.args["listId"] as Uid, act.args["itemId"] as Uid, act.args["val"] as bool);
    });

    dispatcher().reg(this, "change_item_category", (Action act) {
      serv().changeItemCategory(
          act.args["listId"] as Uid, act.args["liitemIdstId"] as Uid, act.args["categoryId"] as Uid);
    });

    // List
    dispatcher().reg(this, "remove_done", (Action act) {
      serv().removeDone(act.args["listId"] as Uid);
    });

    dispatcher().reg(this, "remove_all", (Action act) {
      serv().removeAll(act.args["listId"] as Uid);
    });
  }
}
