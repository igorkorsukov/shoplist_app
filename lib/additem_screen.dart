import 'package:flutter/material.dart';
import "additem_model.dart";

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreen createState() => _AddItemScreen();
}

class _AddItemScreen extends State<AddItemScreen> {
  final model = EditItemModel();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // model.onChanged = () {
    //   log("onChanged");
    //   setState(() {});
    // };
    // model.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter value'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          model.addItem(controller.text);
          Navigator.pop(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
