import '../infrastructure/action/action.dart';
import '../infrastructure/uid/id.dart';

Action addItem(Id listId, Id itemId, String title, [bool checked = false]) =>
    makeAction("add_item", {"listId": listId, "itemId": itemId, "title": title, "checked": checked});

Action removeItem(Id listId, Id itemId) => makeAction("remove_item", {"listId": listId, "itemId": itemId});

Action checkItem(Id listId, Id itemId, bool val) =>
    makeAction("check_item", {"listId": listId, "itemId": itemId, "val": val});

Action removeDoneAction(Id listId) => makeAction("remove_done", {"listId": listId});

Action removeAllAction(Id listId) => makeAction("remove_all", {"listId": listId});
