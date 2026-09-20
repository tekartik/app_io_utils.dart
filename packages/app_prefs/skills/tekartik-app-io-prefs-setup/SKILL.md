---
name: tekartik-app-io-prefs-setup
description: >-
  Use when a Dart io application (command line tool, desktop, server) needs
  persistent key/value preferences with tekartik_app_io_prefs: prefsFactory,
  getPrefsFactory(packageName:), openPreferences(name, version:,
  onVersionChanged:), the Prefs API (getInt/setInt, getString/setString,
  getBool/setBool, getDouble/setDouble, getMap/setMap, getList/setList,
  containsKey, remove, clear, save, close), prefsFactoryMemory and
  newPrefsFactoryMemory for tests, the sembast files under userAppDataPath,
  and the app_prefs.dart import.
---

# Persistent preferences for io apps (tekartik_app_io_prefs)

`tekartik_app_io_prefs` gives `dart:io` programs a ready to use
`tekartik_prefs` `PrefsFactory` backed by sembast files in the user's
application data directory, and re-exports the whole `tekartik_prefs` API
(`Prefs`, `PrefsFactory`, memory factories) so that one import is enough.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_io_prefs:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_prefs
      version: '>=0.4.0'
  ```
  It brings `tekartik_prefs` and `tekartik_prefs_sembast` (repo
  `https://github.com/tekartik/prefs.dart`, paths `prefs` and
  `prefs_sembast`), `sembast`, `process_run` and `path`.
* Import `package:tekartik_app_io_prefs/app_prefs.dart`. It re-exports
  `package:tekartik_prefs/prefs.dart` (`Prefs`, `PrefsFactory`,
  `PrefsSyncRead`, `PrefsOnVersionChangedFunction`, `prefsFactoryMemory`,
  `newPrefsFactoryMemory`) and adds two entry points:
  - `getPrefsFactory(packageName: 'com.example.my_tool')`: the factory to
    use. On Linux and Windows it returns a factory (cached per
    `packageName`) storing under `<userAppDataPath>/<packageName>/prefs/`;
    on the other io platforms `packageName` is ignored and the default
    factory is returned.
  - `prefsFactory`: the default factory, same storage under the package
    name `com.tekartik.app_prefs`. Reading the getter builds a new factory
    every time: read it once and keep the instance.
  `userAppDataPath` (process_run) is `~/.config` on Linux and macOS,
  `%APPDATA%` on Windows; each prefs name is one sembast database file
  (`.../prefs/<name>`). Always pass a reverse-dns `packageName` in a real
  tool so that it does not share `com.tekartik.app_prefs` with others.
* Open: `var prefs = await factory.openPreferences('settings');` and keep
  the `Prefs` open for the life of the program. With `version` and
  `onVersionChanged`, `onVersionChanged(prefs, oldVersion, newVersion)`
  runs when the stored version (0 for a new store) differs from `version`,
  before the new version is recorded: migrate or `clear()` there.
  `factory.deletePreferences(name)` wipes a store; `factory.hasStorage` is
  false for the memory factory only.
* Reads are synchronous: `getInt`, `getString`, `getBool`, `getDouble`,
  `getMap`, `getList`, `containsKey`; they return null when the key is
  missing (maps and lists are stored as json text, `getString` returns that
  text). Writes are synchronous too: `setInt`, `setString`, `setBool`,
  `setDouble`, `setMap`, `setList` (a null value removes the key),
  `remove`, `clear`. Changes are flushed automatically in a microtask;
  `await prefs.save()` forces the write (do it before `exit()` in a CLI)
  and `await prefs.close()` releases the file.
* Keys must be non empty and must not start with `_` (reserved,
  `ArgumentError`).
* Platform: io only. There is no web implementation (the library does not
  compile for the web) and no sqflite one despite the pubspec dependency;
  Flutter apps use the `tekartik_prefs` implementation of their platform.
  Sembast is single process: do not open the same file from two programs
  at once.
* Tests and dependency injection: write classes against `PrefsFactory` (or
  `Prefs`), give them `getPrefsFactory(...)` in `main` and
  `newPrefsFactoryMemory()` (or the shared `prefsFactoryMemory`) in tests;
  a memory factory keeps one store per name for as long as it lives.

## Examples

### Command line tool remembering its last run

```dart
import 'package:tekartik_app_io_prefs/app_prefs.dart';

Future<void> main() async {
  var factory = getPrefsFactory(packageName: 'com.example.my_tool');
  var prefs = await factory.openPreferences('state');

  var runCount = (prefs.getInt('run_count') ?? 0) + 1;
  var lastRun = prefs.getString('last_run');
  print('run #$runCount${lastRun == null ? '' : ', last run $lastRun'}');

  prefs.setInt('run_count', runCount);
  prefs.setString('last_run', DateTime.now().toIso8601String());
  prefs.setMap('last_options', {'verbose': true, 'jobs': 4});
  await prefs.save();
  await prefs.close();
}
```

### Versioned prefs with a migration

```dart
import 'package:tekartik_app_io_prefs/app_prefs.dart';

Future<Prefs> openSettings(PrefsFactory factory) => factory.openPreferences(
  'settings',
  version: 2,
  onVersionChanged: (prefs, oldVersion, newVersion) {
    if (oldVersion < 1) {
      // Brand new store (oldVersion is 0): nothing to migrate
      return;
    }
    if (oldVersion < 2) {
      // v1 stored a single 'server' string, v2 stores a map
      var server = prefs.getString('server');
      prefs.remove('server');
      if (server != null) {
        prefs.setMap('server', {'host': server, 'port': 443});
      }
    }
  },
);

Future<void> main() async {
  var factory = getPrefsFactory(packageName: 'com.example.app');
  var prefs = await openSettings(factory);
  print(prefs.getMap('server'));
  await prefs.close();
}
```

### Injectable settings class

```dart
import 'package:tekartik_app_io_prefs/app_prefs.dart';

class Settings {
  final PrefsFactory factory;
  Prefs? _prefs;

  Settings(this.factory);

  Future<Prefs> get _ready async =>
      _prefs ??= await factory.openPreferences('settings');

  Future<String> get locale async =>
      (await _ready).getString('locale') ?? 'en';

  Future<void> setLocale(String locale) async =>
      (await _ready).setString('locale', locale);

  Future<void> close() async {
    await _prefs?.close();
    _prefs = null;
  }
}

Future<void> main() async {
  // Real storage in main, newPrefsFactoryMemory() in tests
  var settings = Settings(getPrefsFactory(packageName: 'com.example.app'));
  print(await settings.locale);
  await settings.setLocale('fr');
  await settings.close();
}
```

### Memory factory in a test

```dart
import 'package:tekartik_app_io_prefs/app_prefs.dart';
import 'package:test/test.dart';

void main() {
  test('memory prefs', () async {
    var factory = newPrefsFactoryMemory();
    expect(factory.hasStorage, isFalse);
    var prefs = await factory.openPreferences('settings');
    expect(prefs.getString('locale'), isNull);
    prefs.setString('locale', 'fr');
    prefs.setList('recent', ['a', 'b']);
    expect(prefs.getString('locale'), 'fr');
    expect(prefs.getList('recent'), ['a', 'b']);
    expect(prefs.containsKey('locale'), isTrue);
    prefs.remove('locale');
    expect(prefs.containsKey('locale'), isFalse);
    await prefs.close();
  });
}
```

## Common mistakes

* Reading `prefsFactory` repeatedly (a new factory each time) instead of
  keeping one `getPrefsFactory(packageName:)` result.
* Exiting a CLI right after a `setXxx` without `await prefs.save()` (or
  `close()`): the microtask flush may not have run.
* Expecting `getPrefsFactory(packageName:)` to isolate data on macOS,
  Android or iOS: only Linux and Windows honour `packageName`.
* Using this package in web code: it is io only.
