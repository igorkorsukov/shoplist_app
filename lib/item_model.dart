class Item {
  String title = "";
  bool checked = false;
  bool isNew = false;
  Item({this.title = "", this.checked = false, this.isNew = false});

  Item clone() {
    return Item(title: title, checked: checked, isNew: isNew);
  }
}
