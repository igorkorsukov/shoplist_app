import 'package:flutter/material.dart';
import 'item_model.dart';

class ShopListItem extends StatelessWidget {
  const ShopListItem({
    super.key,
    required this.item,
    required this.onCheckedChanged,
  });

  final ShopItemV item;
  final ValueChanged<bool?> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    // return CheckboxListTile(
    //     controlAffinity: ListTileControlAffinity.leading,
    //     title: Text(
    //       item.title,
    //       style: TextStyle(
    //         decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
    //       ),
    //     ),
    //     value: item.checked,
    //     onChanged: (val) {
    //       Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(val));
    //     });

    return ListTile(
        //controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        //value: item.checked,
        onTap: () {
          Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(!item.checked));
        });
  }
}
