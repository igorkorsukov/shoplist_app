import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shoplist/warp/uid/uid.dart';
import 'categories_model.dart';
import '../types.dart';

Future<Uid> selectCategory(context) async {
  var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CategoriesPopup();
      });

  if (ret == null) {
    return Uid.invalid;
  }
  return ret as Uid;
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.title, required this.color, this.size = 60, required this.onClicked});

  final String title;
  final Color color;
  final double size;
  final Function onClicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClicked();
      },
      child: Container(
        //padding: const EdgeInsets.all(8),
        width: size,
        height: size,
        color: color,
        child: Text(title),
      ),
    );
  }
}

class CategoryItemNew extends StatelessWidget {
  const CategoryItemNew({super.key, required this.onClicked});

  final Function onClicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClicked();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CategoriesPopup extends StatefulWidget {
  const CategoriesPopup({super.key});

  @override
  State<CategoriesPopup> createState() => _CategoriesPopup();
}

class _CategoriesPopup extends State<CategoriesPopup> {
  final _model = CategoriesModel();

  @override
  void initState() {
    super.initState();
    _model.onChanged = () {
      setState(() {});
    };
    _model.init();
  }

  @override
  void dispose() {
    //_model.deinit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = _model.categories();
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            heightFactor: 1.0,
            alignment: Alignment.topCenter,
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 8.0, // gap between lines
              children: <Widget>[
                for (var item in items)
                  CategoryItem(
                      title: item.title,
                      color: item.color,
                      onClicked: () {
                        Navigator.pop(context, item.id);
                      }),
              ],
            ),
          ),
        )
        // child: SizedBox(
        //   height: 400 / screenSize.width * 154,
        //   width: 400,
        //   child: GridView.extent(
        //     primary: false,
        //     padding: const EdgeInsets.all(20),
        //     crossAxisSpacing: 10,
        //     mainAxisSpacing: 10,
        //     maxCrossAxisExtent: 60,
        //     children: <Widget>[
        //       for (var item in items)
        //         CategoryItem(
        //             item: item,
        //             onClicked: () {
        //               Navigator.pop(context, item.id);
        //             }),
        //       // CategoryItemNew(onClicked: () {
        //       //   Navigator.pop(context, Uid("new", "new"));
        //       // })
        //     ],
        //   ),
        // ),
        );
  }
}
