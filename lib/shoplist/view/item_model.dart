import '../../infrastructure/uid/uid.dart';

class ShopItemV {
  Uid id = Uid.invalid;
  String title = "";
  bool checked = false;
  ShopItemV(this.id, {this.title = "", this.checked = false});

  ShopItemV clone() {
    return ShopItemV(id, title: title, checked: checked);
  }
}
