import 'package:sqflite_common/sqflite_dev.dart';
import 'package:tekartik_app_io_platform/app_platform.dart';
import 'package:tekartik_app_io_sqflite/sqflite.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

void defineMenu() {
  menu('sqflite', () {
    //devPrint('MAIN_');
    var sqfliteFactory =
        getDatabaseFactory(packageName: 'app_sqflite_test_app.tekartik.com');
    var dbName = 'open_toggle_sqflite.db';
    item('delete database', () async {
      await sqfliteFactory.deleteDatabase(dbName);
    });

    item('open and toggle value', () async {
      // ignore: deprecated_member_use
      await sqfliteFactory.setLogLevel(sqfliteLogLevelVerbose);
      var prefs = await sqfliteFactory.openDatabase(dbName,
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
              }));
      var result =
          await prefs.query('Pref', where: 'id = ?', whereArgs: ['toggle']);

      var toggle = result.first['value'] == 1;

      write(result);
      write('toggle: $toggle');
      toggle = !toggle;
      await prefs.update('Pref', {'value': toggle ? 1 : 0},
          where: 'id = ?', whereArgs: ['toggle']);
      await prefs.close();
      write('set toogle to $toggle');
    });
  });
}

Future<void> main(List<String> arguments) async {
  platformInit();
  mainMenu(arguments, () {
    defineMenu();
  });
}
