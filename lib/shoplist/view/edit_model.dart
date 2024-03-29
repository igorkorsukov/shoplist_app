import 'dart:developer';
import 'dart:ui';
import 'package:shoplist/shoplist/actions.dart';
import '../../warp/async/subscribable.dart';
import '../../warp/uid/uid.dart';
import '../../warp/uid/uidgen.dart';
import '../../warp/modularity/inject.dart';
import '../../warp/action/dispatcher.dart';
import '../ishoplistservice.dart';
import '../types.dart';

class EditItem {
  Uid refId;
  Uid? performId;
  String title;
  bool checked;
  Color color;
  EditItem(this.refId, {required this.performId, required this.title, required this.checked, required this.color});
}

class EditItemModel with Subscribable {
  String performName = "";
  Function? onChanged;

  final serv = Inject<IShopListService>();
  final dispatcher = Inject<ActionsDispatcher>();
  Reference _reference = Reference();
  Categories _categories = Categories();
  Perform _perform = Perform("");
  final List<EditItem> _items = [];
  final List<EditItem> _filtered = [];
  String _searchString = "";

  void _makeItems(Reference ref, Categories cats, Perform perf) {
    _items.clear();

    Map<Uid, Uid> current = {};
    for (var i in perf.items) {
      current[i.refId] = i.id;
    }

    for (var it in ref.items()) {
      Category cat = cats.category(it.categoryId);
      _items.add(EditItem(it.id,
          performId: current[it.id], title: it.title, checked: current[it.id] != null, color: cat.color));
    }
  }

  void init() async {
    // load
    _reference = await serv().reference();
    _categories = await serv().categories();
    _perform = await serv().perform(performName);

    // update
    _makeItems(_reference, _categories, _perform);
    _update();

    // subscribe
    serv().referenceChanged().onReceive(this, (Reference ref) {
      _reference = ref;
      _makeItems(_reference, _categories, _perform);
      _update();
    });

    serv().categoriesChanged().onReceive(this, (Categories cats) async {
      _categories = cats;
      _makeItems(_reference, _categories, _perform);
      _update();
    });

    serv().performChanged().onReceive(this, (Perform perf) async {
      if (perf.name == performName) {
        _perform = perf;
        _makeItems(_reference, _categories, _perform);
        _update();
      }
    });
  }

  void deinit() {
    unsubscribe();
  }

  List<EditItem> items() {
    return _filtered;
  }

  void _resort(List<EditItem> l) {
    l.sort((a, b) {
      if (a.color != b.color) {
        return a.color.value.compareTo(b.color.value);
      }
      return a.title.compareTo(b.title);
    });
  }

  void _update() {
    _filtered.clear();

    for (var i in _items) {
      if (_searchString.isEmpty) {
        _filtered.add(i);
      } else {
        var t = i.title.toLowerCase();
        var s = _searchString.toLowerCase();
        if (t.contains(s)) {
          _filtered.add(i);
        }
      }
    }

    _resort(_filtered);

    onChanged!();
  }

  void search(String val) {
    _searchString = val;
    _update();
  }

  void checkPerformItem(EditItem item, bool isAdd) async {
    if (isAdd) {
      dispatcher().dispatch(AddPerformItem(performName, UIDGen.newID(), item.refId));
    } else {
      assert(item.performId!.isValid());
      dispatcher().dispatch(RemovePerformItem(performName, item.performId!));
    }
  }

  void addNewItem(String title) async {
    Uid refItemId = UIDGen.newID();
    dispatcher().dispatch(AddNewRefItem(refItemId, title));
    dispatcher().dispatch(AddPerformItem(performName, UIDGen.newID(), refItemId));
  }
}
