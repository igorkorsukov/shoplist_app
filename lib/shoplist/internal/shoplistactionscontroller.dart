import '../../warp/modularity/inject.dart';
import '../../warp/action/dispatcher.dart';
import '../ishoplistservice.dart';
import '../types.dart';
import '../actions.dart';

class ShopListActionsController with Actionable {
  final dispatcher = Inject<ActionsDispatcher>();
  final serv = Inject<IShopListService>();

  void init() {
    Map<ActionCode, ActionCallBack> calls = {
      // Reference
      "add_new_refitem": (Action a) {
        var act = a as AddNewRefItem;
        serv().addReferenceItem(ReferenceItem(act.refItemId, title: act.title));
      },
      "remove_refitem": (Action a) {
        serv().removeRefItem((a as RemoveRefItem).refItemId);
      },
      "change_refitem_category": (Action a) {
        var act = a as ChangeRefItemCategory;
        serv().changeItemCategory(act.refItemId, act.categoryId);
      },

      // Perform
      "add_performitem": (Action a) {
        var act = a as AddPerformItem;
        serv().addPerformItem(act.listName, PerformItem(act.itemId, act.refItemId));
      },
      "remove_performitem": (Action a) {
        var act = a as RemovePerformItem;
        serv().removePerformItem(act.listName, act.itemId);
      },
      "check_performitem": (Action a) {
        var act = a as CheckPerformItem;
        serv().checkPerformItem(act.listName, act.itemId, act.val);
      },
      "remove_performdone": (Action a) {
        var act = a as RemovePerformDone;
        serv().removePerformDone(act.listName);
      },
      "remove_performall": (Action a) {
        var act = a as RemovePerformAll;
        serv().removePerformAll(act.listName);
      },
    };

    dispatcher().regMap(this, calls);
  }
}
