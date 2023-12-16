import '../../infrastructure/uid/id.dart';

class ShopItemV {
  Id id = Id.invalid;
  String title = "";
  bool checked = false;
  ShopItemV(this.id, {this.title = "", this.checked = false});

  ShopItemV clone() {
    return ShopItemV(id, title: title, checked: checked);
  }
}
