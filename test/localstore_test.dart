import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter;

import 'package:shoplist/warp/db/internal/platform/general/localstore.dart';

void main() {
  final store = LocalStore();

  flutter.TestWidgetsFlutterBinding.ensureInitialized();

  test('put / get', () {
    // write value
    {
      store.put("key1", "value 1");
    }

    // read value
    {
      var val = store.get("key1");
      expect(val, "value 1");
    }
  });
}
