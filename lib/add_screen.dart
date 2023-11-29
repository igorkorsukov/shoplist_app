import 'package:flutter/material.dart';
import 'add_model.dart';
import 'add_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreen();
}

class _AddItemScreen extends State<AddItemScreen> {
  final model = EditItemModel();

  @override
  void initState() {
    super.initState();
    model.onChanged = () {
      setState(() {});
    };
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    var items = model.items();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(),
              onChanged: (val) => model.search(val),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (var item in items)
                    AddItem(
                        item: item,
                        onCheckedChanged: (val) {
                          model.changeItem(item, val);
                        }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
