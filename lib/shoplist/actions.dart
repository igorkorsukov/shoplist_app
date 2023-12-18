import '../infrastructure/action/action.dart';
import '../infrastructure/uid/uid.dart';

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
  final Uid listId;
  final Uid itemId;
  final Uid refItemId;
  AddPerformItem(this.listId, this.itemId, this.refItemId) : super("add_performitem");
}

class RemovePerformItem extends Action {
  final Uid listId;
  final Uid itemId;
  RemovePerformItem(this.listId, this.itemId) : super("remove_performitem");
}

class CheckPerformItem extends Action {
  final Uid listId;
  final Uid itemId;
  final bool val;
  CheckPerformItem(this.listId, this.itemId, this.val) : super("check_performitem");
}

class RemovePerformDone extends Action {
  final Uid listId;
  RemovePerformDone(this.listId) : super("remove_performdone");
}

class RemovePerformAll extends Action {
  final Uid listId;
  RemovePerformAll(this.listId) : super("remove_performall");
}
