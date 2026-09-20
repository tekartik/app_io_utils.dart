---
name: tekartik-app-io-platform-setup
description: >-
  Use when Dart io code (command line, server, Flutter native) needs to know
  the operating system it runs on with tekartik_app_io_platform:
  platformContext (a tekartik_platform PlatformContext with io, platform,
  browser and toMap()), the isLinux / isWindows / isMacOS / isAndroid /
  isIOS getters of platform.dart, the deprecated platformInit(), the
  app_platform.dart vs platform.dart imports, and what happens on the web
  (UnsupportedError).
---

# Platform context for io apps (tekartik_app_io_platform)

`tekartik_app_io_platform` exposes the `tekartik_platform` `PlatformContext`
of the running program (`platformContextIo` from `tekartik_platform_io` on
the VM) plus `isXxx` convenience booleans, behind conditional imports so
that shared code compiles everywhere and only the VM branch reads it.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_io_platform:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_platform
      version: '>=0.3.1'
  ```
  It brings `tekartik_platform` and `tekartik_platform_io` (repo
  `https://github.com/tekartik/platform.dart`, paths `platform` and
  `platform_io`); declare `tekartik_platform` too when you name `Io`,
  `Browser` or `Platform` from `package:tekartik_platform/context.dart` in
  your own signatures.
* `package:tekartik_app_io_platform/app_platform.dart`:
  - `platformContext`: the `PlatformContext`. On the VM it is the io
    context: `platformContext.io` is non null (`isLinux`, `isMacOS`,
    `isWindows`, `isAndroid`, `isIOS`, `environment`), `platform` is the
    common io/node view of the same object, `browser` and `node` are null;
    `toMap()` dumps it for debugging.
  - `PlatformContext`, re-exported from `tekartik_platform/context.dart`.
  - `platformInit()`: deprecated no-op kept for old callers; nothing to
    call anymore.
* `package:tekartik_app_io_platform/platform.dart`: top-level `isIOS`,
  `isAndroid`, `isLinux`, `isWindows`, `isMacOS`, computed once from
  `platformContext.io!`. It does not re-export `platformContext`. Import it
  with a prefix (`as p`) as the package tests do: the short names clash
  with other libraries (the file comment warns against importing it next
  to `flutter_test`).
* Web and other platforms: the conditional import resolves to a web stub
  where `platformContext` throws `UnsupportedError` (this package provides
  no browser context) and to a generic stub throwing `UnimplementedError`
  (itself an `UnsupportedError`) elsewhere. The `platform.dart` getters are
  lazy finals: importing compiles everywhere, the first read throws off the
  VM. Guard with your own web check before touching them, or catch
  `UnsupportedError`.
* Prefer this over `dart:io` `Platform` when the code is written against
  the `tekartik_platform` abstractions (a `PlatformContext` can be passed
  around and swapped in tests) and in packages that must compile for the
  web while only running their platform branch on the VM.
* Tests: `dart test` on the VM; compare with `dart:io` `Platform.isXxx` as
  `test/platform_io_test.dart` does. `isAndroid` and `isIOS` are never true
  on a desktop host.

## Examples

### Per-OS behaviour with the prefixed getters

```dart
import 'package:path/path.dart';
import 'package:tekartik_app_io_platform/app_platform.dart';
import 'package:tekartik_app_io_platform/platform.dart' as p;

/// Where a command line tool keeps its configuration.
String configDirectory(String appName) {
  var env = platformContext.io!.environment;
  if (p.isWindows) {
    return join(env['APPDATA'] ?? env['USERPROFILE'] ?? '.', appName);
  }
  var home = env['HOME'] ?? '.';
  if (p.isMacOS) {
    return join(home, 'Library', 'Application Support', appName);
  }
  return join(home, '.config', appName);
}

void main() {
  print(configDirectory('my_tool'));
}
```

### Dump the context

```dart
import 'dart:convert';

import 'package:tekartik_app_io_platform/app_platform.dart';

void main() {
  print(const JsonEncoder.withIndent('  ').convert(platformContext.toMap()));
  var io = platformContext.io;
  if (io != null) {
    print('linux ${io.isLinux}, macOS ${io.isMacOS}, windows ${io.isWindows}');
  }
}
```

### Shared code that also compiles for the web

```dart
import 'package:tekartik_app_io_platform/app_platform.dart';

/// The context, or null on the web (UnsupportedError) and where nothing is
/// implemented (UnimplementedError, a subtype of UnsupportedError).
PlatformContext? get platformContextOrNull {
  try {
    return platformContext;
  } on UnsupportedError {
    return null;
  }
}

bool get runsOnWindows => platformContextOrNull?.io?.isWindows ?? false;

void main() {
  print('windows: $runsOnWindows');
}
```

### Test against dart:io

```dart
import 'dart:io';

import 'package:tekartik_app_io_platform/platform.dart' as p;
import 'package:test/test.dart';

void main() {
  test('platform', () {
    expect(p.isLinux, Platform.isLinux);
    expect(p.isMacOS, Platform.isMacOS);
    expect(p.isWindows, Platform.isWindows);
    expect(p.isAndroid, isFalse);
    expect(p.isIOS, isFalse);
  });
}
```

## Common mistakes

* Reading `platformContext` or a `platform.dart` getter in code that runs
  on the web: it throws, there is no browser context here.
* Importing `platform.dart` without a prefix next to libraries that define
  `isLinux`-like names.
* Calling `platformInit()` and expecting it to do something: it is a no-op.
* Expecting `platformContext.browser` to be set in a browser: it throws
  before that; use the `tekartik_platform` browser context directly.
