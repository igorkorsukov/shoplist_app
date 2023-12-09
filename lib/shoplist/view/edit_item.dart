import 'package:flutter/material.dart';
import 'item_vm.dart';

class AddItem extends StatelessWidget {
  const AddItem({
    super.key,
    required this.item,
    required this.onCheckedChanged,
  });

  final ShopItemV item;
  final ValueChanged<bool?> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(
          item.title,
        ),
        value: item.checked,
        onChanged: (val) {
          Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(val));
        });
  }
}
