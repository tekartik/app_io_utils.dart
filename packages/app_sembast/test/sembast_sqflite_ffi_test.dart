import 'package:tekartik_app_io_sembast/setup/sembast_sqflite_ffi.dart';
import 'package:test/test.dart';

Future main() async {
  group('sembast', () {
    test('factory', () async {
      var factory = databaseFactorySqfliteFfi;
      var db = await factory.openDatabase('ffi_test.db');
      await stringMapStoreFactory
          .store('test')
          .record('my_key')
          .put(db, {'value': 1});
      await db.close();
    });
  });
}
