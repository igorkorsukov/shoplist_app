import 'package:flutter/material.dart';
import 'package:shoplist/shoplist/actions.dart';
import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import '../../sync/view/sync_button.dart';
import 'edit_model.dart';
import 'categories_popup.dart';

class EditListScreen extends StatefulWidget {
  const EditListScreen({
    super.key,
    this.args,
  });

  final Map<String, dynamic>? args;

  @override
  State<EditListScreen> createState() => _AddItemScreen();
}

class _AddItemScreen extends State<EditListScreen> {
  final _model = EditItemModel();
  final dispatcher = Inject<ActionsDispatcher>();
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

    _model.performId = widget.args!["listId"] as Uid;
    _model.init();
  }

  @override
  void dispose() {
    _model.deinit();
    super.dispose();
  }

  bool isNeedAddNew(items) {
    if (_searchController.text.isEmpty) {
      return false;
    }

    if (items.length == 1 && items[0].title.toLowerCase() == _searchController.text.toLowerCase()) {
      return false;
    }

    return true;
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
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
            EditTile(
              title: item.title,
              checked: item.checked,
              categoryColor: item.color,
              onCheckedChanged: (val) {
                _model.checkPerformItem(item, val!);
                _searchController.clear();
              },
              onCategoryClicked: () {
                selectCategory(context).then((Uid catId) {
                  dispatcher().dispatch(ChangeRefItemCategory(item.refId, catId));
                });
              },
              onDeleteClicked: () {
                dispatcher().dispatch(RemoveRefItem(item.refId));
              },
            ),

          // add new
          if (isNeedAddNew(items))
            AddNewTile(
              title: _searchController.text,
              onCheckedChanged: (val) {
                _model.addNewItem(_searchController.text);
                _searchController.clear();
              },
            )
        ],
      ),
    );
  }
}

class EditTile extends StatelessWidget {
  const EditTile(
      {super.key,
      required this.title,
      required this.checked,
      required this.categoryColor,
      required this.onCheckedChanged,
      required this.onCategoryClicked,
      required this.onDeleteClicked});

  final String title;
  final bool checked;
  final Color categoryColor;
  final ValueChanged<bool?> onCheckedChanged;
  final Function onCategoryClicked;
  final Function onDeleteClicked;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      shape: Border(
        left: BorderSide(width: 10, color: categoryColor),
      ),
      title: Text(title),
      value: checked,
      onChanged: (val) {
        Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(val));
      },
      secondary: PopupMenuButton(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 'category',
              child: Text('Категория'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Удалить'),
            )
          ];
        },
        onSelected: (String value) {
          switch (value) {
            case 'category':
              onCategoryClicked();
              break;
            case 'delete':
              onDeleteClicked();
              break;
          }
        },
      ),
    );
  }
}

class AddNewTile extends StatelessWidget {
  const AddNewTile({
    super.key,
    required this.title,
    required this.onCheckedChanged,
  });

  final String title;
  final ValueChanged<bool?> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(title),
      value: false,
      onChanged: (val) {
        Future.delayed(const Duration(milliseconds: 250), () => onCheckedChanged(val));
      },
    );
  }
}
