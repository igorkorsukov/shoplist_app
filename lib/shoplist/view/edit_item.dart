import 'package:flutter/material.dart';
import 'item_model.dart';

class AddItem extends StatelessWidget {
  const AddItem({super.key, required this.item, required this.onCheckedChanged, required this.onDeleteClicked});

  final ShopItemV item;
  final ValueChanged<bool?> onCheckedChanged;
  final Function onDeleteClicked;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        item.title,
      ),
      value: item.checked,
      onChanged: (val) {
        Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(val));
      },
      secondary: PopupMenuButton(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 'delete',
              child: Text('Удалить'),
            )
          ];
        },
        onSelected: (String value) {
          switch (value) {
            case 'delete':
              onDeleteClicked();
              break;
          }
        },
      ),
    );
  }
}
