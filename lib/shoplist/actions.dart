import '../infrastructure/action/action.dart';
import '../infrastructure/uid/uid.dart';

// Item
Action addItem(Uid listId, Uid itemId, String title, [bool checked = false]) =>
    makeAction("add_item", {"listId": listId, "itemId": itemId, "title": title, "checked": checked});

Action removeItem(Uid listId, Uid itemId) => makeAction("remove_item", {"listId": listId, "itemId": itemId});

Action checkItem(Uid listId, Uid itemId, bool val) =>
    makeAction("check_item", {"listId": listId, "itemId": itemId, "val": val});

Action setItemCategory(Uid listId, Uid itemId, Uid categoryId) =>
    makeAction("change_item_category", {"listId": listId, "itemId": itemId, "categoryId": categoryId});

// List
Action removeDoneAction(Uid listId) => makeAction("remove_done", {"listId": listId});

Action removeAllAction(Uid listId) => makeAction("remove_all", {"listId": listId});
