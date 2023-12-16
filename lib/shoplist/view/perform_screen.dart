import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shoplist/shoplist/actions.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import '../../sync/view/sync_button.dart';
import '../../appshell/view/main_drawer.dart';
import 'perform_model.dart';
import 'perform_item.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListState();
}

class _ShopListState extends State<ShopListScreen> {
  final model = ShopListModel();
  final dispatcher = Inject<ActionsDispatcher>();

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
      case 'edit_items':
        Navigator.pushNamed(context, '/edititems', arguments: <String, dynamic>{
          'listId': model.listId,
        });
        break;
      case 'remove_done':
        dispatcher().dispatch(removeDoneAction(model.listId));
        break;
      case 'remove_all':
        dispatcher().dispatch(removeAllAction(model.listId));
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
              const PopupMenuItem<String>(value: 'edit_items', child: Text('Изменить')),
              const PopupMenuItem<String>(value: 'remove_done', child: Text('Очистить выполненые')),
              const PopupMenuItem<String>(value: 'remove_all', child: Text('Очистить всё')),
            ],
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Center(
          child: ListView(
        children: [
          for (var item in items)
            ShopListItem(
                item: item,
                onCheckedChanged: (val) {
                  dispatcher().dispatch(checkItem(model.listId, item.id, val!));
                }),
        ],
      )),
    );
  }
}
