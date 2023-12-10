import 'dart:developer';
import 'package:flutter/material.dart';
import 'perform_vm.dart';
import 'perform_item.dart';
import '../../sync/view/sync_button.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListState();
}

class _ShopListState extends State<ShopListScreen> {
  final model = ShopListModel();

  @override
  void initState() {
    super.initState();
    model.onChanged = () {
      setState(() {});
    };
    model.init();
  }

  @override
  void dispose() {
    model.deinit();
    super.dispose();
  }

  void menuClicked(String val) {
    switch (val) {
      case 'edititems':
        Navigator.pushNamed(context, '/edititems');
        break;
      case 'remove_done':
        model.removeDone();
        break;
      case 'remove_all':
        model.removeAll();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = model.items();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoplist'),
        actions: [
          const SyncButton(),
          PopupMenuButton<String>(
            onSelected: (item) => menuClicked(item),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(value: 'edititems', child: Text('Изменить')),
              const PopupMenuItem<String>(value: 'remove_done', child: Text('Очистить выполненые')),
              const PopupMenuItem<String>(value: 'remove_all', child: Text('Очистить всё')),
            ],
          ),
        ],
      ),
      body: Center(
          child: ListView(
        children: [
          for (var item in items)
            ShopListItem(
                item: item,
                onCheckedChanged: (val) {
                  model.checkItem(item, val);
                }),
        ],
      )),
    );
  }
}
