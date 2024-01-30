import '../warp/action/action.dart';
import '../warp/uid/uid.dart';

// Reference
class AddNewRefItem extends Action {
  final Uid refItemId;
  final String title;
  AddNewRefItem(this.refItemId, this.title) : super("add_new_refitem");
}

class RemoveRefItem extends Action {
  final Uid refItemId;
  RemoveRefItem(this.refItemId) : super("remove_refitem");
}

class ChangeRefItemCategory extends Action {
  final Uid refItemId;
  final Uid categoryId;
  ChangeRefItemCategory(this.refItemId, this.categoryId) : super("change_refitem_category");
}

// Perform
class AddPerformItem extends Action {
  final String listName;
  final Uid itemId;
  final Uid refItemId;
  AddPerformItem(this.listName, this.itemId, this.refItemId) : super("add_performitem");
}

class RemovePerformItem extends Action {
  final String listName;
  final Uid itemId;
  RemovePerformItem(this.listName, this.itemId) : super("remove_performitem");
}

class CheckPerformItem extends Action {
  final String listName;
  final Uid itemId;
  final bool val;
  CheckPerformItem(this.listName, this.itemId, this.val) : super("check_performitem");
}

class RemovePerformDone extends Action {
  final String listName;
  RemovePerformDone(this.listName) : super("remove_performdone");
}

class RemovePerformAll extends Action {
  final String listName;
  RemovePerformAll(this.listName) : super("remove_performall");
}
