import 'package:tekartik_app_io_sqflite/sqflite.dart';

Future<void> main() async {
  //devPrint('MAIN_');
  var sqfliteFactory = getDatabaseFactory(
    packageName: 'app_sqflite_test_app.tekartik.com',
  );
  var dbName = 'open_toggle_sqflite.db';
  // ignore: deprecated_member_use
  await sqfliteFactory.setLogLevel(sqfliteLogLevelVerbose);
  var prefs = await sqfliteFactory.openDatabase(
    dbName,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();
        batch.execute('DROP TABLE IF EXISTS Pref');
        batch.execute('''CREATE TABLE Pref (
  id TEXT PRIMARY KEY,
  value INTEGER NOT NULL
)''');
        batch.insert('Pref', {'id': 'toggle', 'value': 0});

        await batch.commit(noResult: true);
      },
    ),
  );
  var result = await prefs.query(
    'Pref',
    where: 'id = ?',
    whereArgs: ['toggle'],
  );

  var toggle = result.first['value'] == 1;

  print(result);
  print('toggle: $toggle');
  toggle = !toggle;
  await prefs.update(
    'Pref',
    {'value': toggle ? 1 : 0},
    where: 'id = ?',
    whereArgs: ['toggle'],
  );
  await prefs.close();
  print('set toogle to $toggle');
}
