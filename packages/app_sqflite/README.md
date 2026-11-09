# tekartik_app_io_sqflite

sqflite for `dart:io` programs (command line tools, desktop apps, servers,
tests) in one import: a [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)
`DatabaseFactory` whose databases directory is under the user application
data directory, plus the whole `sqflite_common` API (`Database`,
`OpenDatabaseOptions`, `Batch`...).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_io_sqflite:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_sqflite
```

```dart
import 'package:tekartik_app_io_sqflite/sqflite.dart';

Future<void> main() async {
  // Databases in <userAppDataPath>/com.example.my_tool/databases
  var factory = getDatabaseFactory(packageName: 'com.example.my_tool');
  var db = await factory.openDatabase(
    'notes.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE Note (id INTEGER PRIMARY KEY, title TEXT NOT NULL)',
      ),
    ),
  );
  await db.insert('Note', {'title': 'hello'});
  print(await db.query('Note'));
  await db.close();
}
```

`userAppDataPath` (from process_run) is `~/.config` on Linux and macOS,
`%APPDATA%` on Windows. Pass `rootPath:` instead of `packageName:` to choose
the directory (for example `.dart_tool/my_tool/db` in a test).

Platforms: Linux, macOS and Windows with the Dart VM (SQLite is bundled by
the `sqlite3` package build hooks). Not for Flutter mobile (use
`tekartik_app_flutter_sqflite`: there the ffi default directory is not
writable) nor the web (the functions throw `UnimplementedError`).

## API

| Name | What |
|---|---|
| `getDatabaseFactory({packageName, rootPath})` | the factory of an application: ffi, databases path set |
| `databaseFactory` | the same ffi factory object (`databaseFactoryFfi`), without setting a path |
| `sqfliteWindowsFfiInit()` | `sqfliteFfiInit()`: on Windows loads SQLite in the calling isolate, no-op elsewhere |

## Common pitfalls

- `getDatabaseFactory` returns the process-wide `databaseFactoryFfi` and sets
  its databases path: a second call with another `packageName` or `rootPath`
  moves the relative names of every factory got before (and of
  `databaseFactory`). Call it once and keep the factory, or open with
  absolute paths.
- Without `packageName` nor `rootPath`, every such program shares
  `<userAppDataPath>/databases`.
- Close the database before a command line tool exits.
