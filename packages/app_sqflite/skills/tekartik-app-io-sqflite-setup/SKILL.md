---
name: tekartik-app-io-sqflite-setup
description: >-
  Use when a Dart io program (command line tool, desktop app, server, test)
  needs a sqlite database through sqflite with tekartik_app_io_sqflite: the
  getDatabaseFactory(packageName:, rootPath:) and databaseFactory entry points
  that return a sqflite_common_ffi DatabaseFactory with its databases path set
  under userAppDataPath, sqfliteWindowsFfiInit(), the deprecated
  initDatabaseFactory, and the package:tekartik_app_io_sqflite/sqflite.dart
  import that re-exports sqflite_common (Database, DatabaseFactory,
  OpenDatabaseOptions, onCreate/onUpgrade, Batch, Transaction,
  ConflictAlgorithm, DatabaseException, inMemoryDatabasePath, query/insert/
  update/delete/rawQuery).
---

# Sqflite setup for io apps (tekartik_app_io_sqflite)

`tekartik_app_io_sqflite` is the one-import sqflite initialization for
`dart:io` programs: it returns a `sqflite_common_ffi` `DatabaseFactory`, runs
the ffi init for you, and points the databases path at the user application
data directory (or a directory you choose). It re-exports the whole
`sqflite_common` API so no other sqflite import is needed.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_io_sqflite:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_sqflite
      version: '>=0.5.0'
  ```
  It brings `sqflite_common`, `sqflite_common_ffi`, `process_run` and `path`.
* Import `package:tekartik_app_io_sqflite/sqflite.dart`. It re-exports
  `package:sqflite_common/sqlite_api.dart` (`Database`, `DatabaseFactory`,
  `DatabaseExecutor`, `Transaction`, `Batch`, `OpenDatabaseOptions`,
  `ConflictAlgorithm`, `DatabaseException`, `inMemoryDatabasePath`,
  `sqfliteLogLevelSql`, `sqfliteLogLevelVerbose`) and
  `package:sqflite_common/sqflite_dev.dart` (the deprecated dev-only
  `setLogLevel` / `setOptions` extension), and adds three entry points:
  - `getDatabaseFactory({String? packageName, String? rootPath})`: the factory
    to use in an application.
  - `databaseFactory`: the plain ffi factory (`databaseFactoryFfi`), with no
    ffi init and no databases path handling.
  - `sqfliteWindowsFfiInit()`: runs `sqfliteFfiInit()`, only needed on Windows
    during development so that the sqlite3 dll is found.
* `getDatabaseFactory` on Linux, Windows and macOS calls `sqfliteFfiInit()`
  and sets the databases path to `rootPath`, or to
  `<userAppDataPath>/<packageName>/databases` when only `packageName` is
  given (the directory is created if missing). On the other io platforms both
  parameters are ignored and the default ffi factory is returned.
  `userAppDataPath` (`process_run`) is `~/.config` on Linux and macOS,
  `%APPDATA%` on Windows.
* Always pass `packageName` (reverse dns, e.g. `com.example.my_tool`) in an
  application, or `rootPath` for a project local database (e.g. under
  `.dart_tool/`). With neither, `packageName` defaults to `'.'` and every
  program shares `<userAppDataPath>/databases`.
* Read the factory once and keep it: each `getDatabaseFactory` call re-runs
  the ffi init and re-sets the databases path (the path is global to the
  factory, so two different `packageName` values in one program fight each
  other; use absolute paths in `openDatabase` if you really need two
  locations). Open the database once and keep it open; `await db.close()`
  before exiting a CLI.
* A relative name passed to `openDatabase` is resolved against the databases
  path (`await factory.getDatabasesPath()`), so `openDatabase('data.db')` is
  what you want. `factory.deleteDatabase(name)` and
  `factory.databaseExists(name)` take the same kind of name.
* Declare the schema with `OpenDatabaseOptions(version: ..., onCreate: ...,
  onUpgrade: ...)` and create tables there, not on every start. `onCreate`
  runs for a new file, `onUpgrade(db, oldVersion, newVersion)` when the stored
  version is lower; both receive a `Database` already inside a transaction.
* Platform: io only. On the web `databaseFactory` and `getDatabaseFactory`
  throw `UnimplementedError`; a Flutter (mobile/desktop/web) application uses
  `tekartik_app_flutter_sqflite` instead.
  `initDatabaseFactory(packageName)` is deprecated, use `getDatabaseFactory`.
* Tests: open `inMemoryDatabasePath` on the plain `databaseFactory` (call
  `sqfliteWindowsFfiInit()` first so the ffi init has run), or use
  `getDatabaseFactory(rootPath: '.dart_tool/<pkg>/db')` plus
  `deleteDatabase` in `setUp` for a file based test. Type your own classes
  against `DatabaseFactory` / `Database` and inject the factory.
* `tekartik_app_io_sembast` (same repo, `packages/app_sembast`) builds on this
  package when you want the sembast NoSQL API instead of raw SQL.

## Examples

### Command line tool with a versioned schema

```dart
import 'package:tekartik_app_io_sqflite/sqflite.dart';

Future<Database> openAppDatabase() async {
  var factory = getDatabaseFactory(packageName: 'com.example.my_tool');
  return factory.openDatabase(
    'data.db',
    options: OpenDatabaseOptions(
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE Note (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  done INTEGER NOT NULL DEFAULT 0
)''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE Note ADD COLUMN done INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    ),
  );
}

Future<void> main() async {
  var db = await openAppDatabase();
  print('database: ${db.path}');
  await db.close();
}
```

### Insert, query, update in a project local database

```dart
import 'package:tekartik_app_io_sqflite/sqflite.dart';

Future<void> main() async {
  // Database file under .dart_tool, not in the user app data
  var factory = getDatabaseFactory(rootPath: '.dart_tool/my_tool/db');
  var db = await factory.openDatabase(
    'notes.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Note (id INTEGER PRIMARY KEY, title TEXT, done INTEGER)',
        );
      },
    ),
  );

  var id = await db.insert('Note', {
    'title': 'Buy milk',
    'done': 0,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  var rows = await db.query(
    'Note',
    where: 'done = ?',
    whereArgs: [0],
    orderBy: 'title',
  );
  print(rows);

  await db.update('Note', {'done': 1}, where: 'id = ?', whereArgs: [id]);
  print(await db.rawQuery('SELECT COUNT(*) AS count FROM Note'));

  await db.close();
}
```

### Batch and transaction

```dart
import 'package:tekartik_app_io_sqflite/sqflite.dart';

Future<void> importNotes(Database db, List<String> titles) async {
  await db.transaction((txn) async {
    var batch = txn.batch();
    for (var title in titles) {
      batch.insert('Note', {'title': title, 'done': 0});
    }
    await batch.commit(noResult: true);
  });
}

Future<void> main() async {
  var factory = getDatabaseFactory(packageName: 'com.example.my_tool');
  var db = await factory.openDatabase(
    'data.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE Note (id INTEGER PRIMARY KEY, title TEXT, done INTEGER)',
      ),
    ),
  );
  await importNotes(db, ['One', 'Two', 'Three']);
  await db.close();
}
```

### Injectable repository

```dart
import 'package:tekartik_app_io_sqflite/sqflite.dart';

class NoteRepository {
  final DatabaseFactory factory;
  final String name;
  Database? _db;

  NoteRepository(this.factory, {this.name = 'data.db'});

  Future<Database> get _ready async =>
      _db ??= await factory.openDatabase(
        name,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) =>
              db.execute('CREATE TABLE Note (id INTEGER PRIMARY KEY, title TEXT)'),
        ),
      );

  Future<int> add(String title) async =>
      (await _ready).insert('Note', {'title': title});

  Future<List<String>> titles() async => (await _ready)
      .query('Note', columns: ['title'], orderBy: 'title')
      .then((rows) => rows.map((row) => row['title'] as String).toList());

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

Future<void> main() async {
  var repository = NoteRepository(
    getDatabaseFactory(packageName: 'com.example.my_tool'),
  );
  await repository.add('Buy milk');
  print(await repository.titles());
  await repository.close();
}
```

### In memory database in a test

```dart
import 'package:tekartik_app_io_sqflite/sqflite.dart';
import 'package:test/test.dart';

void main() {
  late Database db;

  setUp(() async {
    // Needed on Windows to locate the sqlite3 dll
    sqfliteWindowsFfiInit();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) =>
            db.execute('CREATE TABLE Note (id INTEGER PRIMARY KEY, title TEXT)'),
      ),
    );
  });
  tearDown(() async => db.close());

  test('insert/query', () async {
    var id = await db.insert('Note', {'title': 'Buy milk'});
    var rows = await db.query('Note', where: 'id = ?', whereArgs: [id]);
    expect(rows.first['title'], 'Buy milk');
  });

  test('databases path', () async {
    var factory = getDatabaseFactory(packageName: 'com.example.my_tool');
    expect(await factory.getDatabasesPath(), contains('com.example.my_tool'));
  });
}
```

## Common mistakes

* Calling `getDatabaseFactory(...)` on every access: it re-inits ffi and
  re-sets the (global) databases path. Call it once and keep the factory.
* Calling it with no argument in a real tool: the database then lands in the
  shared `<userAppDataPath>/databases`.
* Using `databaseFactory` directly for an application file: it does no ffi
  init and no path setup. Use it only for `inMemoryDatabasePath` or absolute
  paths.
* Expecting `packageName` / `rootPath` to be honoured on Android or iOS: only
  Linux, Windows and macOS use them.
* Creating tables at every start instead of in `onCreate` / `onUpgrade`.
* Using this package in web or Flutter code: it is io only
  (`tekartik_app_flutter_sqflite` covers Flutter and the web).
