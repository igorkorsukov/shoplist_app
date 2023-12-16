import '../infrastructure/action/action.dart';
import '../infrastructure/uid/uid.dart';

Action addItem(Uid listId, Uid itemId, String title, [bool checked = false]) =>
    makeAction("add_item", {"listId": listId, "itemId": itemId, "title": title, "checked": checked});

Action removeItem(Uid listId, Uid itemId) => makeAction("remove_item", {"listId": listId, "itemId": itemId});

Action checkItem(Uid listId, Uid itemId, bool val) =>
    makeAction("check_item", {"listId": listId, "itemId": itemId, "val": val});

Action removeDoneAction(Uid listId) => makeAction("remove_done", {"listId": listId});

Action removeAllAction(Uid listId) => makeAction("remove_all", {"listId": listId});
