import 'dart:ui';
import '../../infrastructure/uid/uid.dart';

class ShopItemV {
  Uid id;
  String title;
  bool checked;
  Color color;
  ShopItemV(this.id, {required this.title, required this.checked, required this.color});
}
