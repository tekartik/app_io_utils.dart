import 'package:tekartik_app_io_sembast/sembast.dart';
import 'package:test/test.dart';

void main() {
  var factory = getDatabaseFactory(
    packageName: 'com.tekartik.app_io_utils.sembast.exp',
  );
  group('sembast', () {
    test('factory', () {
      expect(getDatabaseFactory, isNotNull);
      expect(DatabaseFactory, isNotNull);
    });
    group('io', () {
      test('open', () async {
        var store = StoreRef<String, String>.main();
        await factory.deleteDatabase('test.db');
        Future<Database> open() async {
          var db = await factory.openDatabase('test.db');
          return db;
        }

        var db = await open();
        print(db.path);
        await store.record('k').put(db, 'v');
        await db.close();
        db = await open();
        expect(await store.record('k').get(db), 'v');
        await db.close();
      });
    });
  });
}
