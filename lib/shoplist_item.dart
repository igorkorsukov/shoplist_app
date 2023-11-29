import 'package:flutter/material.dart';
import 'item_model.dart';

class ShopListItem extends StatelessWidget {
  const ShopListItem({
    super.key,
    required this.item,
    required this.onCheckedChanged,
  });

  final Item item;
  final ValueChanged<bool?> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        value: item.checked,
        onChanged: (val) {
          onCheckedChanged(val);
        });
  }
}
