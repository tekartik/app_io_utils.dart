# tekartik_app_io_prefs

Persistent key/value preferences for Dart io programs (command line tools,
desktop apps, servers): a ready to use
[tekartik_prefs](https://github.com/tekartik/prefs.dart) `PrefsFactory`
storing each prefs in a sembast file of the user data folder.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_io_prefs:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_prefs
```

```dart
import 'package:tekartik_app_io_prefs/app_prefs.dart';

Future<void> main() async {
  // One factory per package name, the same instance at every call.
  var prefsFactory = getPrefsFactory(packageName: 'com.example.my_tool');
  var prefs = await prefsFactory.openPreferences('settings');

  var runCount = (prefs.getInt('run_count') ?? 0) + 1;
  print('run #$runCount, title ${prefs.getString('title')}');

  // Writes are synchronous, saved in the background: save (or close)
  // before the program exits.
  prefs.setInt('run_count', runCount);
  await prefs.close();
}
```

Example: [example/main.dart](example/main.dart).

In tests, use the memory factory of tekartik_prefs (re-exported):

```dart
var prefsFactory = newPrefsFactoryMemory();
```

## Platforms and storage

* io only (Dart VM, command line, desktop): sembast files under
  `<userAppDataPath>/<packageName>/prefs/<name>`, `userAppDataPath` being
  `~/.config` on Linux and macOS and `%APPDATA%` on Windows (process_run).
* `packageName` is used on Linux and Windows only. On the other io
  platforms (macOS...) every program shares the default folder
  `com.tekartik.app_prefs`, as `prefsFactory` does.
* Web: not supported, the library does not compile for the web. A Flutter
  app uses the tekartik_prefs implementation of its platform
  (tekartik_prefs_flutter).

## Entry points

`package:tekartik_app_io_prefs/app_prefs.dart` re-exports the whole
`package:tekartik_prefs/prefs.dart` API (`Prefs`, `PrefsFactory`,
`prefsFactoryMemory`, `newPrefsFactoryMemory`) and adds:

* `getPrefsFactory(packageName: ...)`: the factory to use, cached per
  package name.
* `prefsFactory`: the default factory (`com.tekartik.app_prefs`), the same
  as `getPrefsFactory()`.

## Common pitfalls

* Exiting right after a `setXxx`: the background save may not have run,
  `await prefs.save()` or `await prefs.close()` first.
* Keys must not be empty nor start with `_` (reserved).
* Sembast is single process: do not open the same prefs from two programs
  at once.

Agent skill: [skills/tekartik-app-io-prefs-setup](skills/tekartik-app-io-prefs-setup/SKILL.md).
