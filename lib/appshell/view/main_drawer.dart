import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // column holds all the widgets in the drawer
      child: Column(
        children: <Widget>[
          Expanded(
            // ListView contains a group of widgets that scroll inside the drawer
            child: ListView(
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.green,
                  ),
                  child: Text(""),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_basket),
                  title: const Text("Продукты"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/shoplist');
                  },
                ),
              ],
            ),
          ),
          const Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                children: <Widget>[
                  Divider(),
                  ListTile(leading: Icon(Icons.settings), title: Text('Настройка')),
                ],
              ))
        ],
      ),
    );
  }
}
