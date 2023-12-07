import 'dart:developer';
import 'package:flutter/material.dart';
import 'shoplist_vm.dart';
import 'shoplist_item.dart';
import '../../sync/view/sync_button.dart';

// class Wrap {
//   StatelessElement? element;
// }

// class ShopListScreen extends StatelessWidget {
//   ShopListScreen({super.key});

//   late final model = ShopListModel(onChanged: () {
//     log("ShopListModel changed");
//     wrap.element?.markNeedsBuild();
//   });

//   final Wrap wrap = Wrap();

//   @override
//   StatelessElement createElement() {
//     log("createElement");
//     wrap.element = StatelessElement(this);
//     return wrap.element!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     log("build");
//     var items = model.items();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shoplist'),
//       ),
//       body: Center(
//           child: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text('You have ${items.length} items:'),
//           ),
//           for (var item in items)
//             ListTile(
//               leading: const Icon(Icons.favorite),
//               title: Text(item),
//             ),
//         ],
//       )),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           //Navigator.pushNamed(context, '/additem');
//           model.addNew();
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

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
      log("onChanged");
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
      case 'additems':
        Navigator.pushNamed(context, '/additems');
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
              const PopupMenuItem<String>(value: 'additems', child: Text('Добавить')),
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
