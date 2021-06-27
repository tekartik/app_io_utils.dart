import 'package:tekartik_app_io_sembast/sembast.dart';
import 'package:test/test.dart';

void main() {
  var rootPath = '.dart_tool/tekartik_app_io_sembast/db';
  var factory = getDatabaseFactory(rootPath: rootPath);
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
        await store.record('k').put(db, 'v');
        await db.close();
        db = await open();
        expect(await store.record('k').get(db), 'v');
        await db.close();
      });
    });
  });
}
