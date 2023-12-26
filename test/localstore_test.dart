import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter;

import 'package:shoplist/infrastructure/db/internal/platform/general/localstore.dart';

void main() {
  final store = LocalStore();

  flutter.TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await store.init('com.kors.test');
  });

  test('write / read', () {
    // write value
    {
      store.write("key1", "value 1");
    }

    // read value
    {
      var val = store.read("key1");
      expect(val, "value 1");
    }
  });
}
