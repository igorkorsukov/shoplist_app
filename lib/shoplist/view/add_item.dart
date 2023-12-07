import 'package:flutter/material.dart';
import 'item_vm.dart';

class AddItem extends StatelessWidget {
  const AddItem({
    super.key,
    required this.item,
    required this.onCheckedChanged,
  });

  final ShopItem item;
  final ValueChanged<bool?> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(
          item.title,
        ),
        value: item.checked,
        onChanged: (val) {
          onCheckedChanged(val);
        });
  }
}
