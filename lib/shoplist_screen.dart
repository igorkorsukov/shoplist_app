import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shoplist/types.dart';
import 'shoplist_model.dart';

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

  @override
  Widget build(BuildContext context) {
    log("build");
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

class ShopListItem extends StatelessWidget {
  const ShopListItem({
    super.key,
    required this.item,
    required this.onCheckedChanged,
  });

  final Item item;
  final ValueChanged<bool?> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        value: item.checked,
        onChanged: (val) {
          onCheckedChanged(val);
        });
  }
}
