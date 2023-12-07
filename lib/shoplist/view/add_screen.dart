import 'package:flutter/material.dart';
import 'add_vm.dart';
import 'add_item.dart';
import '../../sync/view/sync_button.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreen();
}

class _AddItemScreen extends State<AddItemScreen> {
  final _model = EditItemModel();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model.onChanged = () {
      setState(() {});
    };

    _searchController.addListener(() {
      _model.search(_searchController.text);
    });

    _model.init();
  }

  @override
  Widget build(BuildContext context) {
    var items = _model.items();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: const [SyncButton()],
      ),
      body: ListView(
        children: [
          for (var item in items)
            AddItem(
                item: item,
                onCheckedChanged: (val) {
                  _model.changeItem(item, val!);
                  _searchController.clear();
                }),
        ],
      ),
    );
  }
}
