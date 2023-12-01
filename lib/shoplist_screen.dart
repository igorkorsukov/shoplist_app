import 'dart:developer';
import 'package:flutter/material.dart';
import 'item_model.dart';
import 'shoplist_model.dart';
import 'shoplist_item.dart';
import 'sync_model.dart';

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
  final syncModel = SyncModel();

  @override
  void initState() {
    super.initState();
    model.onChanged = () {
      log("onChanged");
      setState(() {});
    };
    model.init();

    syncModel.init();
  }

  @override
  void dispose() {
    model.deinit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = model.items();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoplist'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/additem');
          //model.addNew();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
