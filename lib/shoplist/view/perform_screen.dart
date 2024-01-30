import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shoplist/shoplist/actions.dart';
import '../../warp/modularity/inject.dart';
import '../../warp/action/dispatcher.dart';
import '../../sync/view/sync_button.dart';
import '../../appshell/view/main_drawer.dart';
import 'perform_model.dart';

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
          'performName': model.performName,
        });
        break;
      case 'remove_done':
        dispatcher().dispatch(RemovePerformDone(model.performName));
        break;
      case 'remove_all':
        dispatcher().dispatch(RemovePerformAll(model.performName));
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
            PerformTile(
                title: item.title,
                checked: item.checked,
                categoryColor: item.color,
                onCheckedChanged: (val) {
                  dispatcher().dispatch(CheckPerformItem(model.performName, item.id, val!));
                }),
        ],
      )),
    );
  }
}

class PerformTile extends StatelessWidget {
  const PerformTile({
    super.key,
    required this.title,
    required this.checked,
    required this.categoryColor,
    required this.onCheckedChanged,
  });

  final String title;
  final bool checked;
  final Color categoryColor;
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
        shape: Border(
          left: BorderSide(width: 10, color: categoryColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        onTap: () {
          Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(!checked));
        });
  }
}
