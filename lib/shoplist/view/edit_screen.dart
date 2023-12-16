import 'package:flutter/material.dart';
import 'package:shoplist/shoplist/actions.dart';
import '../../infrastructure/uid/uid.dart';
import '../../infrastructure/modularity/inject.dart';
import '../../infrastructure/action/dispatcher.dart';
import 'edit_model.dart';
import 'edit_item.dart';
import '../../sync/view/sync_button.dart';

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

    _model.editListId = widget.args!["listId"] as Uid;
    _model.init();
  }

  @override
  void dispose() {
    _model.deinit();
    super.dispose();
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
            AddItem(
              item: item,
              onCheckedChanged: (val) {
                _model.changeItem(item, val!);
                _searchController.clear();
              },
              onDeleteClicked: () {
                dispatcher().dispatch(removeItem(_model.referenceId, item.id));
              },
            ),
        ],
      ),
    );
  }
}
