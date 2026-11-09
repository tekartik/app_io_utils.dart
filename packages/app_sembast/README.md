# tekartik_app_io_sembast

A [sembast](https://pub.dev/packages/sembast) `DatabaseFactory` for `dart:io`
programs (command line tools, servers, desktop tools, tests): sembast stored
in SQLite through [sembast_sqflite](https://pub.dev/packages/sembast_sqflite)
and [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi), with
the database files in the user application data folder. The library
re-exports the sembast API.

A Flutter application (mobile, desktop or web) uses
[tekartik_app_flutter_sembast](https://github.com/tekartik/app_flutter_utils.dart/tree/master/app_sembast)
instead.

## Getting started

The package is not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_io_sembast:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_sembast
    version: '>=0.5.0'
```

```dart
import 'package:tekartik_app_io_sembast/sembast.dart';

Future<void> main() async {
  // Databases in <userAppDataPath>/com.example.my_tool/databases
  // (~/.config/... on Linux and macOS, %APPDATA% on Windows).
  var factory = getDatabaseFactory(packageName: 'com.example.my_tool');
  var db = await factory.openDatabase('data.db');

  var store = StoreRef<String, String>.main();
  await store.record('last_run').put(db, DateTime.now().toIso8601String());
  print(await store.record('last_run').get(db));

  await db.close();
}
```

`getDatabaseFactory(rootPath: '.dart_tool/my_tool/db')` puts the databases in
a folder of your choice instead. In unit tests use `databaseFactoryMemory`
(nothing written on disk).

## Platforms

| Platform | Factory |
|---|---|
| Linux, macOS, Windows (Dart VM) | sembast_sqflite on sqflite_common_ffi, path from `packageName` or `rootPath` |
| Android, iOS (`dart:io`) | same ffi factory, `packageName` and `rootPath` ignored: use the Flutter package |
| Web | not supported, `getDatabaseFactory` throws `UnimplementedError` |

SQLite comes with `package:sqlite3` (build hooks), nothing to install.

## Common pitfalls

* Call `getDatabaseFactory` once and keep the factory. Every factory it
  returns uses the same process-wide `databaseFactoryFfi`: each call moves the
  folder of all of them, and a factory kept from an earlier call then opens
  its relative names in the last folder.
* Without `packageName` nor `rootPath`, every such program shares
  `<userAppDataPath>/databases`.
* `databaseFactorySqfliteFfi` (`setup/sembast_sqflite_ffi.dart`) is that same
  shared ffi factory: its relative names follow the last `getDatabaseFactory`
  call (`.dart_tool/sqflite_common_ffi/databases` before any call).
* A sembast database file is used by one process at a time.

The [package skill](skills/tekartik-app-io-sembast-setup/SKILL.md) has more
examples (typed store, service with an injected factory, unit test).
