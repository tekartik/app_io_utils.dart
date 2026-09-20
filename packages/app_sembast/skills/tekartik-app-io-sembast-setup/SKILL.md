---
name: tekartik-app-io-sembast-setup
description: >-
  Use when a Dart io program (command line tool, desktop app, server, test)
  needs a sembast NoSQL database with tekartik_app_io_sembast: the
  app_io_sembast getDatabaseFactory(packageName:, rootPath:) entry point that
  returns a sembast_sqflite/sqflite_common_ffi backed DatabaseFactory storing
  under userAppDataPath, databaseFactoryMemory for unit tests,
  databaseFactorySqfliteFfi from setup/sembast_sqflite_ffi.dart, the
  package:tekartik_app_io_sembast/sembast.dart import that re-exports sembast
  (Database, DatabaseFactory, StoreRef, stringMapStoreFactory, Finder, Filter),
  and the deprecated initDatabaseFactory.
---

# Sembast database factory for io apps (tekartik_app_io_sembast)

`tekartik_app_io_sembast` picks and configures a sembast `DatabaseFactory` for
`dart:io` programs: sembast on top of `sembast_sqflite` / `sqflite_common_ffi`,
with the database files placed in the user application data directory (or a
directory you choose). It re-exports the whole sembast API so one import is
enough.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_io_sembast:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_sembast
      version: '>=0.5.0'
  ```
  It brings `sembast`, `sembast_sqflite`, `sqflite_common_ffi`, `path` and
  `tekartik_app_io_sqflite` (same repo, `packages/app_sqflite`).
* Import `package:tekartik_app_io_sembast/sembast.dart`. It re-exports
  `package:sembast/sembast.dart` (`Database`, `DatabaseFactory`, `StoreRef`,
  `RecordRef`, `stringMapStoreFactory`, `intMapStoreFactory`, `Finder`,
  `Filter`, `SortOrder`, `Transaction`, ...) and adds:
  - `getDatabaseFactory({String? packageName, String? rootPath})`: the factory
    to use in an application.
  - `databaseFactoryMemory`: the sembast in-memory-with-simulated-filesystem
    factory (`databaseFactoryMemoryFs`), for unit tests.
* `getDatabaseFactory` on Linux, Windows and macOS calls `sqfliteFfiInit()`
  and sets the sqflite databases path to `rootPath`, or to
  `<userAppDataPath>/<packageName>/databases` when only `packageName` is
  given. On the other io platforms the parameters are ignored and the default
  ffi factory / default databases path are used. `userAppDataPath`
  (`process_run`) is `~/.config` on Linux and macOS, `%APPDATA%` on Windows.
* Always pass `packageName` (reverse dns, e.g. `com.example.my_tool`) in an
  application, or `rootPath` for a project local database (e.g. under
  `.dart_tool/`). With neither, `packageName` defaults to `'.'` and every
  program shares `<userAppDataPath>/databases`.
* A database name passed to `openDatabase` is resolved relative to that
  databases path, so `factory.openDatabase('data.db')` is what you want;
  `db.path` gives the resolved location. `factory.deleteDatabase(name)`
  removes it.
* Read the factory once, keep it, and open the database once for the life of
  the program (`getDatabaseFactory` rebuilds and re-inits a factory at every
  call). Call `await db.close()` before exiting a CLI. Sembast/sqlite files
  are single process: do not open the same file from two programs at once.
* `package:tekartik_app_io_sembast/setup/sembast_sqflite_ffi.dart` exposes
  `databaseFactorySqfliteFfi`, the raw `sembast_sqflite` over
  `databaseFactoryFfi` factory, with no path handling at all. Use it only when
  you manage the location yourself (absolute paths) or in a test.
  `package:tekartik_app_io_sembast/setup/sembast_io.dart` only holds the
  deprecated `initDatabaseFactory({String? packageName})`; use
  `getDatabaseFactory` instead.
* Platform: io only. On the web `getDatabaseFactory` is a stub that throws
  `UnimplementedError`; a Flutter (mobile/desktop/web) application uses
  `tekartik_app_flutter_sembast` instead. `sqfliteWindowsFfiInit()` from
  `tekartik_app_io_sqflite` is not needed here, `getDatabaseFactory` already
  runs the ffi init.
* Tests and dependency injection: type your code against `DatabaseFactory` /
  `Database`, pass `getDatabaseFactory(packageName: ...)` in `main` and
  `databaseFactoryMemory` in tests. For a project local integration test, use
  `getDatabaseFactory(rootPath: '.dart_tool/<pkg>/db')` and delete the
  database in `setUp`.

## Examples

### Command line tool with a database in the user app data

```dart
import 'package:tekartik_app_io_sembast/sembast.dart';

Future<void> main() async {
  var factory = getDatabaseFactory(packageName: 'com.example.my_tool');
  var db = await factory.openDatabase('data.db');

  var store = StoreRef<String, String>.main();
  var previous = await store.record('last_run').get(db);
  print('previous run: $previous (db: ${db.path})');
  await store.record('last_run').put(db, DateTime.now().toIso8601String());

  await db.close();
}
```

### Project local database, typed store, query and transaction

```dart
import 'package:tekartik_app_io_sembast/sembast.dart';

Future<void> main() async {
  // Database file under .dart_tool, not in the user app data
  var factory = getDatabaseFactory(rootPath: '.dart_tool/my_tool/db');
  var db = await factory.openDatabase('notes.db', version: 1);
  var store = stringMapStoreFactory.store('notes');

  await db.transaction((txn) async {
    await store.record('note_1').put(txn, {'title': 'Buy milk', 'done': false});
    await store.record('note_2').put(txn, {'title': 'Write doc', 'done': true});
  });

  var records = await store.find(
    db,
    finder: Finder(
      filter: Filter.equals('done', false),
      sortOrders: [SortOrder('title')],
    ),
  );
  for (var record in records) {
    print('${record.key}: ${record.value['title']}');
  }

  await db.close();
}
```

### Injectable service, real factory in main

```dart
import 'package:tekartik_app_io_sembast/sembast.dart';

class SettingsService {
  final DatabaseFactory factory;
  final _store = StoreRef<String, Object?>.main();
  Database? _db;

  SettingsService(this.factory);

  Future<Database> get _ready async =>
      _db ??= await factory.openDatabase('settings.db');

  Future<String> getLocale() async =>
      (await _store.record('locale').get(await _ready) as String?) ?? 'en';

  Future<void> setLocale(String locale) async =>
      _store.record('locale').put(await _ready, locale);

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

Future<void> main() async {
  // databaseFactoryMemory in tests, this one in production
  var service = SettingsService(
    getDatabaseFactory(packageName: 'com.example.my_tool'),
  );
  print(await service.getLocale());
  await service.setLocale('fr');
  await service.close();
}
```

### Unit test on the memory factory

```dart
import 'package:tekartik_app_io_sembast/sembast.dart';
import 'package:test/test.dart';

void main() {
  test('put/get', () async {
    var factory = databaseFactoryMemory;
    await factory.deleteDatabase('test.db');
    var db = await factory.openDatabase('test.db');
    var store = stringMapStoreFactory.store('notes');

    await store.record('note_1').put(db, {'title': 'Buy milk'});
    expect(await store.record('note_1').get(db), {'title': 'Buy milk'});
    expect(await store.count(db), 1);

    await db.close();
  });
}
```

### Raw sqflite ffi factory (you own the path)

```dart
import 'package:tekartik_app_io_sembast/setup/sembast_sqflite_ffi.dart';

Future<void> main() async {
  // No app data handling: the name is used as is by sqflite_common_ffi
  var factory = databaseFactorySqfliteFfi;
  var db = await factory.openDatabase('ffi_test.db');

  await stringMapStoreFactory.store('test').record('my_key').put(db, {
    'value': 1,
  });

  await db.close();
}
```

## Common mistakes

* Calling `getDatabaseFactory(...)` on every access: it re-inits ffi and
  re-sets the databases path each time. Call it once and keep the factory.
* Calling it with no argument in a real tool: the database then lands in the
  shared `<userAppDataPath>/databases`.
* Expecting `packageName` / `rootPath` to be honoured on Android or iOS: only
  Linux, Windows and macOS use them.
* Using this package in web or Flutter code: it is io only
  (`tekartik_app_flutter_sembast` covers Flutter and the web).
* Exiting a CLI without `await db.close()`.
